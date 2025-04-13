import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_profile_provider.dart';
import 'user_avatar_edit.dart';

class UserAvatar extends StatelessWidget {
  final double size;
  final VoidCallback? onTap;
  final bool isEditable;
  final bool inAppBar;

  const UserAvatar({
    super.key,
    required this.size,
    this.onTap,
    this.isEditable = false,
    this.inAppBar = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final profileProvider = Provider.of<UserProfileProvider>(context);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
      ),
      clipBehavior: Clip.antiAlias, // Add this to ensure proper clipping
      child: Center(
        child: profileProvider.profileImage != null
            ? AspectRatio( // Added AspectRatio widget
                aspectRatio: 1, // Force 1:1 aspect ratio
                child: Image.file(
                  profileProvider.profileImage!,
                  fit: BoxFit.cover,
                ),
              )
            : Icon(
                Icons.person,
                size: size * 0.5,
                color: isDarkMode ? Colors.white54 : Colors.black26,
              ),
      ),
    );
  }

  Widget buildAvatarStack(BuildContext context, Widget avatarWidget) {
    Widget stack = Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onTap: onTap,
          child: avatarWidget,
        ),
        if (isEditable)
          Positioned(
            right: -20,
            bottom: -20,
            child: Material(
              color: Colors.transparent,
              child: AvatarEditMenu(),
            ),
          ),
      ],
    );

    if (!inAppBar) {
      stack = Center(
        child: SizedBox(
          width: size + 200,
          height: size + 60,
          child: stack,
        ),
      );
    }

    return stack;
  }
}