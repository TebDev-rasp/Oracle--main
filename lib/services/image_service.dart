import 'package:firebase_database/firebase_database.dart';
import 'dart:io';
import '../utils/image_utils.dart';

class ImageService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  
  Future<void> uploadImageAsBase64(File imageFile, String userId) async {
    try {
      String base64Image = ImageUtils.convertImageToBase64(imageFile);
      
      await _dbRef.child('user_images').child(userId).set({
        'imageData': base64Image,
        'timestamp': ServerValue.timestamp,
      });
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<String?> getImageBase64(String userId) async {
    try {
      DatabaseEvent event = await _dbRef
          .child('user_images')
          .child(userId)
          .once();
          
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> data = event.snapshot.value as Map;
        return data['imageData'] as String;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get image: $e');
    }
  }

  Future<void> deleteImageBase64(String userId) async {
    try {
      await _dbRef.child('user_images').child(userId).remove();
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }
}