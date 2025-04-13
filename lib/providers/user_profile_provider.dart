import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:logging/logging.dart';
import '../services/image_service.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileProvider with ChangeNotifier {
  final _logger = Logger('UserProfileProvider');
  String _username = 'User';
  File? _profileImage;
  bool _isInitialized = false;
  final _database = FirebaseDatabase.instance.ref();
  final _authService = AuthService();

  String get username => _username;
  File? get profileImage => _profileImage;
  bool get isInitialized => _isInitialized;
  bool get isLoggedIn => FirebaseAuth.instance.currentUser != null;

  Future<void> initializeProfile(String userId) async {
    if (_isInitialized) return;
    
    try {
      final snapshot = await _database.child('usernames').child(userId).get();
      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map;
        _username = data['username'] as String;
        notifyListeners();
      }

      final imageService = ImageService();
      final base64Image = await imageService.getImageBase64(userId);
      
      if (base64Image != null) {
        final appDir = await getApplicationDocumentsDirectory(); // Changed from getTemporaryDirectory
        final tempFile = File('${appDir.path}/profile_image_$userId.jpg');
        await tempFile.writeAsBytes(base64Decode(base64Image));
        _profileImage = tempFile;
      }
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _logger.warning('Error initializing profile', e);
      _isInitialized = true; // Set to true even on error to prevent repeated fetching
      notifyListeners();
      // Reset to default state on error
      reset();
    }
  }

  Future<void> loadUserProfile() async {
    if (FirebaseAuth.instance.currentUser != null) {
      try {
        final username = await _authService.getUsername();
        _username = username;
        _isInitialized = true;
        notifyListeners();
      } catch (e) {
        _logger.warning('Error loading user profile', e);
        reset();
      }
    }
  }

  Future<void> loadSavedProfileImage(String path) async {
    final file = File(path);
    if (await file.exists()) {
      _profileImage = file;
      notifyListeners();
    }
  }

  Future<void> updateProfileImage(File newImage) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final bytes = await newImage.readAsBytes();
      final base64Image = base64Encode(bytes);
      
      // Check size limit (5MB)
      if (base64Image.length > 5242880) {
        throw Exception('Image size exceeds 5MB limit');
      }

      await _database
          .child('user_images')
          .child(user.uid)
          .set({
            'imageData': base64Image,
            'timestamp': ServerValue.timestamp
          });

      _profileImage = newImage;
      notifyListeners();
    } catch (e) {
      _logger.warning('Error updating profile image', e);
      rethrow;
    }
  }

  Future<void> clearProfileImage() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Remove from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('profile_image_${user.uid}');

      // Delete the file if it exists
      if (_profileImage != null && await _profileImage!.exists()) {
        await _profileImage!.delete();
      }

      _profileImage = null;
      notifyListeners();
    } catch (e) {
      _logger.warning('Error clearing profile image', e);
    }
  }

  void updateUsername(String username) {
    _username = username;
    notifyListeners();
  }

  void reset() {
    _username = 'User';  // Changed from null to default value
    _profileImage = null;
    _isInitialized = false;
    notifyListeners();
  }

  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final updates = <String, dynamic>{};
      
      if (displayName != null) {
        if (displayName.isEmpty || displayName.length > 50) {
          throw Exception('Display name must be between 1 and 50 characters');
        }
        updates['profile/displayName'] = displayName;
      }

      if (photoURL != null) {
        if (!RegExp(r'^https?:\/\/.+$').hasMatch(photoURL)) {
          throw Exception('Invalid photo URL format');
        }
        updates['profile/photoURL'] = photoURL;
      }

      if (updates.isNotEmpty) {
        await _database
            .child('users')
            .child(user.uid)
            .update(updates);
        
        notifyListeners();
      }
    } catch (e) {
      _logger.warning('Error updating profile', e);
      rethrow;
    }
  }
}