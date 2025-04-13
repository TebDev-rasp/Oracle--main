import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../services/image_picker_service.dart';
import '../services/image_service.dart';
import '../providers/user_profile_provider.dart';

class UserAvatarEdit extends StatelessWidget {
  const UserAvatarEdit({super.key});

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<UserProfileProvider>(context);

    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              profileProvider.profileImage != null
                  ? CircleAvatar(
                      radius: 60,
                      backgroundImage: FileImage(profileProvider.profileImage!),
                    )
                  : Icon(
                      Icons.account_circle_outlined,
                      size: 120,
                      color: Colors.grey,
                    ),
            ],
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: AvatarEditMenu(),
        ),
      ],
    );
  }
}

class AvatarEditMenu extends StatefulWidget {
  const AvatarEditMenu({super.key});

  @override
  State<AvatarEditMenu> createState() => _AvatarEditMenuState();
}

class _AvatarEditMenuState extends State<AvatarEditMenu> {
  final _imageService = ImageService();
  final _picker = ImagePickerService();

  Future<void> handleImageOperation(BuildContext contextFromBuild, Future<void> Function() operation) async {
    if (!mounted) return;
  
    final dialogContext = contextFromBuild;
    if (!contextFromBuild.mounted) return;
  
    showDialog(
      context: dialogContext,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 16),
              const Text(
                'Processing...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        );
      },
    );

    await operation();

    if (!contextFromBuild.mounted) return;
    Navigator.pop(dialogContext);
  }
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final profileProvider = Provider.of<UserProfileProvider>(context);
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return PopupMenuButton<String>(
      icon: Icon(
        Icons.edit,
        size: 16,
        color: isDarkMode ? Colors.white70 : const Color(0xFF1A1A1A),
      ),
      offset: const Offset(0, 40),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      position: PopupMenuPosition.under,
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem<String>(
          value: 'gallery',
          child: Row(
            children: [
              Icon(Icons.photo_library_outlined),
              SizedBox(width: 8),
              Text('Choose from Gallery'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'camera',
          child: Row(
            children: [
              Icon(Icons.camera_alt_outlined),
              SizedBox(width: 8),
              Text('Take a Photo'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'remove',
          child: Row(
            children: [
              Icon(Icons.delete_outline),
              SizedBox(width: 8),
              Text('Remove Photo'),
            ],
          ),
        ),
      ],
      onSelected: (String value) async {
        final contextFromBuild = context;
        
        switch (value) {
          case 'gallery':
            await handleImageOperation(contextFromBuild, () async {
              final image = await _picker.pickImageFromGallery();
              if (image != null) {
                final file = File(image.path);
                // First update the UI
                profileProvider.updateProfileImage(file);
                // Then upload to storage
                await _imageService.uploadImageAsBase64(file, userId);
              }
            });
            break;
            
          case 'camera':
            await handleImageOperation(contextFromBuild, () async {
              final photo = await _picker.takePhoto();
              if (photo != null) {
                final file = File(photo.path);
                // First update the UI
                profileProvider.updateProfileImage(file);
                // Then upload to storage
                await _imageService.uploadImageAsBase64(file, userId);
              }
            });
            break;
            
          case 'remove':
            await handleImageOperation(contextFromBuild, () async {
              await _imageService.deleteImageBase64(userId);
              await profileProvider.clearProfileImage(); // Changed from updateProfileImage(null)
            });
            break;
        }
      },
    );
  }
}