import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:logging/logging.dart';
import 'device_tracking_service.dart';
import 'notification_service.dart';
import 'auth_state_tracker.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final _logger = Logger('AuthService');
  final _deviceTrackingService = DeviceTrackingService();
  final _notificationService = NotificationService();
  final _authStateTracker = AuthStateTracker();

  Future<String> getUsername() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        final snapshot =
            await _database.child('users').child(uid).child('username').get();
        if (snapshot.exists && snapshot.value != null) {
          return snapshot.value.toString();
        }
      }
      return 'User';
    } catch (e) {
      _logger.warning('Error fetching username', e);
      return 'User';
    }
  }

  bool isEmail(String input) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(input);
  }

  Future<UserCredential> login(String emailOrUsername, String password) async {
    try {
      String email = emailOrUsername.trim();

      // Is this an explicit user login with credentials
      final isExplicitLogin = true;
      final loginMethod = 'password';

      if (!isEmail(email)) {
        // Get email from username mapping
        final usernameSnapshot = await _database
            .child('usernames')
            .orderByChild('username')
            .equalTo(emailOrUsername)
            .get();

        if (!usernameSnapshot.exists || usernameSnapshot.value == null) {
          _logger.warning('Username not found: $emailOrUsername');
          throw FirebaseAuthException(
            code: 'user-not-found',
            message: 'No user found with this username',
          );
        }

        final Map<dynamic, dynamic> data = usernameSnapshot.value as Map;
        if (data.isEmpty) {
          throw FirebaseAuthException(
            code: 'user-not-found',
            message: 'No user found with this username',
          );
        }

        // Get the first (and should be only) entry
        final userData = data.values.first as Map<dynamic, dynamic>;
        email = userData['email'] as String;

        _logger.info('Found email for username: $emailOrUsername');
      }

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        // Check if this is a new device
        final isNewDevice = await _deviceTrackingService.isNewDevice(user.uid);
        final isPrimaryDevice =
            await _deviceTrackingService.isPrimaryDevice(user.uid);

        // Update last login timestamp
        await _database
            .child('users')
            .child(user.uid)
            .update({'lastLogin': ServerValue.timestamp});

        // Save this device info
        await _deviceTrackingService.saveDeviceAsKnown(user.uid);
        await _deviceTrackingService.updateDeviceWithLoginInfo(
            user.uid, loginMethod);

        // Record login in auth state tracker
        await _authStateTracker.handleLogin(
          loginMethod: loginMethod,
          isExplicitUserAction: isExplicitLogin,
        );

        // Check if we should send a notification
        final shouldNotify = await _authStateTracker.shouldNotifyForLogin(
          loginMethod: loginMethod,
          isExplicitUserAction: isExplicitLogin,
          isKnownDevice: !isNewDevice || isPrimaryDevice,
        );

        // Only send notification if we should
        if (shouldNotify) {
          _logger.info('New device login detected for user: ${user.uid}');

          // Get device info
          final deviceInfo =
              await _deviceTrackingService.getCurrentDeviceInfo();
          final deviceDisplayName =
              _deviceTrackingService.formatDeviceInfoForDisplay(deviceInfo);

          // Try to get location
          final location =
              await _deviceTrackingService.getApproximateLocation();

          // Send notification
          await _notificationService.showLoginNotification(
            deviceInfo: deviceDisplayName,
            location: location,
            loginTime: DateTime.now(),
          );
        } else {
          // Just update the last seen timestamp
          await _deviceTrackingService.updateDeviceLastSeen(user.uid);
        }
      }

      return userCredential;
    } catch (e) {
      _logger.severe('Login error', e);
      rethrow;
    }
  }

  Future<UserCredential> register(
      String email, String username, String password) async {
    try {
      // Validate username format
      if (!RegExp(r'^[a-zA-Z0-9_-]{3,30}$').hasMatch(username)) {
        throw FirebaseAuthException(
          code: 'invalid-username',
          message:
              'Username must be 3-30 characters and contain only letters, numbers, underscores, and hyphens',
        );
      }

      // Validate email format
      if (!RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
          .hasMatch(email)) {
        throw FirebaseAuthException(
          code: 'invalid-email',
          message: 'Please enter a valid email address',
        );
      }

      // Create auth user first (this sets auth != null)
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        final uid = userCredential.user!.uid;

        // Create username mapping first (requires auth != null)
        await _database
            .child('usernames')
            .child(username)
            .set({'uid': uid, 'email': email, 'username': username});

        // Then create user data (requires auth.uid === $uid)
        await _database.child('users').child(uid).set({
          'username': username,
          'email': email,
          'profile': {'displayName': username, 'role': 'user'},
          'createdAt': ServerValue.timestamp,
          'lastLogin': ServerValue.timestamp
        });

        return userCredential;
      }

      throw FirebaseAuthException(
        code: 'registration-failed',
        message: 'Failed to complete registration',
      );
    } catch (e) {
      _logger.severe('Error during registration', e);

      // If registration fails, clean up any partial data
      if (_auth.currentUser != null) {
        try {
          await _auth.currentUser!.delete();
        } catch (deleteError) {
          _logger.warning('Error cleaning up failed registration', deleteError);
        }
      }

      rethrow;
    }
  }

  Future<String> getEmailFromUsername(String username) async {
    try {
      final usernameSnapshot = await _database
          .child('usernames')
          .orderByChild('username')
          .equalTo(username)
          .get();

      if (!usernameSnapshot.exists) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'No user found with this username',
        );
      }

      final Map<dynamic, dynamic> data = usernameSnapshot.value as Map;
      final Map<dynamic, dynamic> userEntry = data.values.first as Map;
      return userEntry['email'] as String;
    } catch (e) {
      _logger.warning('Error getting email from username', e);
      rethrow;
    }
  }

  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Update profile in users node
        final updates = <String, dynamic>{};
        if (displayName != null) {
          updates['displayName'] = displayName;
        }
        if (photoURL != null) {
          updates['photoURL'] = photoURL;
        }

        if (updates.isNotEmpty) {
          await _database
              .child('users')
              .child(user.uid)
              .child('profile')
              .update(updates);
        }
      }
    } catch (e) {
      _logger.warning('Error updating profile', e);
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      _logger.info('Password reset email sent');
    } catch (e) {
      _logger.warning('Password reset error', e);
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      // Record the logout in our state tracker
      await _authStateTracker.handleLogout();

      // Perform the actual signout
      await _auth.signOut();
      _logger.info('User signed out successfully');
    } catch (e) {
      _logger.warning('Sign out error', e);
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Delete user data
        await _database.child('users').child(user.uid).remove();
        // Delete username mapping
        await _database.child('usernames').child(user.uid).remove();
        // Delete authentication account
        await user.delete();

        _logger.info('Account deleted successfully');
      }
    } catch (e) {
      _logger.severe('Delete account error', e);
      rethrow;
    }
  }

  Future<UserCredential> loginWithProvider(String provider) async {
    try {
      // Is this an explicit user login?

      // Handle different provider types
      if (provider == 'google') {
        // Google sign in logic would go here
        throw UnimplementedError('Google sign in not implemented');
      } else if (provider == 'biometric') {
        // Biometric sign in logic would go here
        throw UnimplementedError('Biometric sign in not implemented');
      } else {
        throw ArgumentError('Unsupported login provider: $provider');
      }

      // After getting userCredential, the same login notification logic would apply
      // Code omitted for brevity as it would be similar to the password login flow
    } catch (e) {
      _logger.severe('Login with provider error', e);
      rethrow;
    }
  }

  Future<bool> restoreSession() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return false;
      }

      // This is not an explicit login, it's a session restoration
      await _authStateTracker.handleLogin(
        loginMethod: 'session_restore',
        isExplicitUserAction: false,
      );

      // Update the device last seen
      await _deviceTrackingService.updateDeviceLastSeen(currentUser.uid);

      _logger.info('Session restored for user: ${currentUser.uid}');
      return true;
    } catch (e) {
      _logger.warning('Session restoration error', e);
      return false;
    }
  }

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
