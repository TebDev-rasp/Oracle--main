import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';
import 'dart:convert';

class AuthStateTracker {
  static final _logger = Logger('AuthStateTracker');

  // Keys for storage
  static const String _authStateKey = 'auth_state';
  static const String _lastActiveTimeKey = 'last_active_time';

  // Constants
  static const int _logoutCooldownMs = 30000; // 30 seconds cooldown
  static const int _reloadDetectionWindowMs = 10000; // 10 seconds window

  // In-memory state
  bool _recentlyReloaded = false;

  // Singleton pattern
  static final AuthStateTracker _instance = AuthStateTracker._internal();
  factory AuthStateTracker() => _instance;
  AuthStateTracker._internal();

  // Current Authentication State
  Future<Map<String, dynamic>> _getAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    final stateString = prefs.getString(_authStateKey);

    if (stateString == null) {
      return {
        'isLoggedIn': false,
        'lastLogoutTime': null,
        'lastLoginTime': null,
        'lastKnownMethod': null,
        'wasExplicitLogin': false,
      };
    }

    try {
      return Map<String, dynamic>.from(json.decode(stateString));
    } catch (e) {
      _logger.warning('Failed to parse auth state: $e');
      return {
        'isLoggedIn': false,
        'lastLogoutTime': null,
        'lastLoginTime': null,
        'lastKnownMethod': null,
        'wasExplicitLogin': false,
      };
    }
  }

  // Save authentication state
  Future<void> _saveAuthState(Map<String, dynamic> state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authStateKey, json.encode(state));
  }

  // Mark app as recently reloaded
  Future<void> markAppReloaded() async {
    _recentlyReloaded = true;
    await _updateLastActiveTime();

    // Reset the reload flag after window expires
    Future.delayed(Duration(milliseconds: _reloadDetectionWindowMs), () {
      _recentlyReloaded = false;
    });

    _logger.info('App marked as recently reloaded');
  }

  // Track app active time
  Future<void> _updateLastActiveTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
        _lastActiveTimeKey, DateTime.now().millisecondsSinceEpoch);
  }

  // Check if app was recently active (restarted vs cold start)
  Future<bool> wasRecentlyActive() async {
    final prefs = await SharedPreferences.getInstance();
    final lastActiveTime = prefs.getInt(_lastActiveTimeKey);

    if (lastActiveTime == null) return false;

    final now = DateTime.now().millisecondsSinceEpoch;
    final timeSinceActive = now - lastActiveTime;

    // If app was active in the last 5 minutes, consider it a restart not a cold start
    return timeSinceActive < 300000; // 5 minutes
  }

  // Record logout event
  Future<void> handleLogout() async {
    final state = await _getAuthState();

    state['isLoggedIn'] = false;
    state['lastLogoutTime'] = DateTime.now().millisecondsSinceEpoch;

    await _saveAuthState(state);
    await _updateLastActiveTime();

    _logger.info('Logout recorded');
  }

  // Record login event
  Future<void> handleLogin({
    required String loginMethod,
    required bool isExplicitUserAction,
  }) async {
    final state = await _getAuthState();

    final now = DateTime.now().millisecondsSinceEpoch;

    // Update state
    state['isLoggedIn'] = true;
    state['lastLoginTime'] = now;
    state['lastKnownMethod'] = loginMethod;
    state['wasExplicitLogin'] = isExplicitUserAction;

    await _saveAuthState(state);
    await _updateLastActiveTime();

    _logger.info(
        'Login recorded: method=$loginMethod, explicit=$isExplicitUserAction');
  }

  // Check if notification should be shown
  Future<bool> shouldNotifyForLogin({
    required String loginMethod,
    required bool isExplicitUserAction,
    required bool isKnownDevice,
  }) async {
    if (_recentlyReloaded) {
      _logger.info('Not sending notification: App was recently reloaded');
      return false;
    }

    // Get the current state
    final state = await _getAuthState();
    final wasRecentRestart = await wasRecentlyActive();

    // Don't notify if app was recently active (likely a restart)
    if (wasRecentRestart && !isExplicitUserAction) {
      _logger.info(
          'Not sending notification: App was recently active without explicit login');
      return false;
    }

    // Check if within cooldown period after logout
    final lastLogoutTime = state['lastLogoutTime'];
    if (lastLogoutTime != null) {
      final timeSinceLogout =
          DateTime.now().millisecondsSinceEpoch - lastLogoutTime;
      if (timeSinceLogout < _logoutCooldownMs) {
        _logger.info('Not sending notification: Within logout cooldown period');
        return false;
      }
    }

    // Don't notify if user was already logged in (session refresh)
    if (state['isLoggedIn'] == true) {
      _logger.info('Not sending notification: User was already logged in');
      return false;
    }

    // Send notification only for explicit user actions on mobile with supported login methods
    final isValidLoginMethod =
        ['password', 'biometric', 'social'].contains(loginMethod);

    final shouldNotify = isValidLoginMethod &&
        isExplicitUserAction &&
        !isKnownDevice &&
        state['isLoggedIn'] == false; // Was previously logged out

    if (shouldNotify) {
      _logger.info('Will send login notification');
    } else {
      _logger.info('Not sending notification: Does not meet criteria');
    }

    return shouldNotify;
  }
}
