import 'package:flutter/material.dart';
import '../widgets/sidebar_menu.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        leading: Builder(  // Wrap IconButton with Builder
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();  // Now this will work
              },
            );
          },
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 16.0, // Reduced from default 20
            fontWeight: FontWeight.bold
          ),
        ),
        centerTitle: true, // Center the title
        backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        elevation: 0,
        toolbarHeight: 65, // Increased from default 56
        leadingWidth: 65, // Increased from default
        titleSpacing: 0, // Adjust title spacing
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),  // Increased from 1.0 to 2.0
          child: Container(
            color: isDarkMode ? Colors.grey[900] : Colors.grey[300],
            height: 2.0,  // Increased from 1.0 to 2.0
          ),
        ),
      ),
      drawer: const SidebarMenu(),
      backgroundColor: isDarkMode ? const Color(0xFF111111) : Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'General',
              style: TextStyle(
                fontSize: 21.0,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? const Color.fromARGB(255, 255, 255, 255) : const Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}