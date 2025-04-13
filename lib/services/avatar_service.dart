import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class AvatarService {
  static const _baseUrl = 'https://api.dicebear.com/7.x/identicon/svg';

  Future<File?> generateRandomAvatar(String userId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl?seed=$userId'));
      
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/avatar_$userId.svg');
        await file.writeAsBytes(response.bodyBytes);
        return file;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}