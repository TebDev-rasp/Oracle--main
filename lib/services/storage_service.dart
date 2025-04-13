import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final storage = FirebaseStorage.instance;
  final picker = ImagePicker();

  Future<String?> uploadProfileImage(String userId) async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;

    final File imageFile = File(image.path);
    final storageRef = storage.ref().child('profile_images/$userId.jpg');
    
    await storageRef.putFile(imageFile);
    final downloadUrl = await storageRef.getDownloadURL();
    
    return downloadUrl;
  }
}
