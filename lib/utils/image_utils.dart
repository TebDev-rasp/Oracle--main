import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';

class ImageUtils {
  static String convertImageToBase64(File imageFile) {
    List<int> imageBytes = imageFile.readAsBytesSync();
    String base64Image = base64Encode(imageBytes);
    return base64Image;
  }

  static Image base64ToImage(String base64String) {
    Uint8List bytes = base64Decode(base64String);
    return Image.memory(bytes);
  }
}