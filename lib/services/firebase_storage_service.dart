import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logging/logging.dart';

class FirebaseStorageService {
  final _logger = Logger('FirebaseStorageService');
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> uploadProfileImage(File imageFile) async {
    try {
      _logger.info('Starting Firebase upload');
      String userId = _auth.currentUser!.uid;
      String path = 'profile_images/$userId.jpg';
      
      final ref = _storage.ref().child(path);
      _logger.info('Uploading file...');
      await ref.putFile(imageFile);
      
      _logger.info('Getting download URL...');
      final url = await ref.getDownloadURL();
      _logger.info('Upload complete: $url');
      return url;
    } catch (e) {
      _logger.severe('Error uploading profile image', e);
      return null;
    }
  }

  Future<String?> getProfileImageUrl() async {
    try {
      String userId = _auth.currentUser!.uid;
      String path = 'profile_images/$userId.jpg';
      final ref = _storage.ref().child(path);
      return await ref.getDownloadURL();
    } catch (e) {
      _logger.warning('Error getting profile image URL', e);
      return null;
    }
  }

  Future<void> deleteProfileImage() async {
    try {
      String userId = _auth.currentUser!.uid;
      String path = 'profile_images/$userId.jpg';
      final ref = _storage.ref().child(path);
      await ref.delete();
    } catch (e) {
      _logger.warning('Error deleting profile image', e);
    }
  }
}