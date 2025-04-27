import 'package:flutter/material.dart';
import '../widgets/sidebar_menu.dart';
import '../services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _voiceNotificationsEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _voiceNotificationsEnabled =
            prefs.getBool('voice_notifications_enabled') ?? true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          // Wrap IconButton with Builder
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer(); // Now this will work
              },
            );
          },
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
              fontSize: 16.0, // Reduced from default 20
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true, // Center the title
        backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        elevation: 0,
        toolbarHeight: 65, // Increased from default 56
        leadingWidth: 65, // Increased from default
        titleSpacing: 0, // Adjust title spacing
        bottom: PreferredSize(
          preferredSize:
              const Size.fromHeight(2.0), // Increased from 1.0 to 2.0
          child: Container(
            color: isDarkMode ? Colors.grey[900] : Colors.grey[300],
            height: 2.0, // Increased from 1.0 to 2.0
          ),
        ),
      ),
      drawer: const SidebarMenu(),
      backgroundColor: isDarkMode ? const Color(0xFF111111) : Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'General',
                    style: TextStyle(
                      fontSize: 21.0,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode
                          ? const Color.fromARGB(255, 255, 255, 255)
                          : const Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // Voice Notification Toggle
                  Card(
                    elevation: 2.0,
                    margin: const EdgeInsets.only(bottom: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: isDarkMode ? const Color(0xFF222222) : Colors.white,
                    child: SwitchListTile(
                      title: const Text(
                        'Voice Notifications',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: const Text(
                          'Play voice alerts for heat index danger levels'),
                      value: _voiceNotificationsEnabled,
                      activeColor: Colors.blue,
                      onChanged: (value) async {
                        setState(() {
                          _voiceNotificationsEnabled = value;
                        });
                        await NotificationService()
                            .setVoiceNotificationsEnabled(value);
                      },
                    ),
                  ),
                  // Heat Index Alert Levels (Information)
                  Card(
                    elevation: 2.0,
                    margin: const EdgeInsets.only(bottom: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: isDarkMode ? const Color(0xFF222222) : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(
                                left: 16.0, top: 8.0, bottom: 8.0),
                            child: Text(
                              'Heat Index Alert Levels',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                          const Divider(),
                          ListTile(
                            leading: Container(
                              height: 24,
                              width: 24,
                              decoration: const BoxDecoration(
                                color: Colors.yellow,
                                shape: BoxShape.circle,
                              ),
                            ),
                            title: const Text('Caution'),
                            subtitle: const Text('Heat index ≥ 27°C'),
                            dense: true,
                          ),
                          ListTile(
                            leading: Container(
                              height: 24,
                              width: 24,
                              decoration: const BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                              ),
                            ),
                            title: const Text('Extreme Caution'),
                            subtitle: const Text('Heat index ≥ 32°C'),
                            dense: true,
                          ),
                          ListTile(
                            leading: Container(
                              height: 24,
                              width: 24,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            title: const Text('Danger'),
                            subtitle: const Text('Heat index ≥ 41°C'),
                            dense: true,
                          ),
                          ListTile(
                            leading: Container(
                              height: 24,
                              width: 24,
                              decoration: const BoxDecoration(
                                color: Colors.purple,
                                shape: BoxShape.circle,
                              ),
                            ),
                            title: const Text('Extreme Danger'),
                            subtitle: const Text('Heat index ≥ 54°C'),
                            dense: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
