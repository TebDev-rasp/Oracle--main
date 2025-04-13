import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'sign_out_tile.dart';
import 'user_avatar_edit.dart';
import '../providers/user_profile_provider.dart';

class SidebarMenu extends StatelessWidget {
  const SidebarMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final profileProvider = Provider.of<UserProfileProvider>(context);
    
    return Drawer(
      backgroundColor: isDarkMode ? const Color(0xFF0F0F0F) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(2)),
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFFAFAFA),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: profileProvider.profileImage != null
                            ? CircleAvatar(
                                radius: 32,
                                backgroundImage: FileImage(profileProvider.profileImage!),
                              )
                            : const Icon(
                                Icons.account_circle_outlined,
                                size: 64,
                                color: Colors.grey,
                              ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: AvatarEditMenu(),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.home_outlined),
                  title: const Text('Home'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text('Settings'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('About'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          const SignOutTile(),
        ],
      ),
    );
  }
}