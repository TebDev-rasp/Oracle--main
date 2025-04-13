import 'package:image_picker/image_picker.dart';
import 'package:logging/logging.dart';

class ImagePickerService {
  final _logger = Logger('ImagePickerService');
  final _picker = ImagePicker();

  Future<XFile?> pickImageFromGallery() async {
    _logger.info('Opening gallery...');
    final image = await _picker.pickImage(source: ImageSource.gallery);
    _logger.info('Selected image: ${image?.path}');
    return image;
  }

  Future<XFile?> takePhoto() async {
    _logger.info('Opening camera...');
    final photo = await _picker.pickImage(source: ImageSource.camera);
    _logger.info('Captured photo: ${photo?.path}');
    return photo;
  }
}