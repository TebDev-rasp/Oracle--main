import 'package:flutter/material.dart';
import 'package:oracle/services/heat_index_monitor.dart';
import '../widgets/sidebar_menu.dart';
import 'record/hourly_record.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    HeatIndexMonitor.startMonitoring();
  }

  @override
  void dispose() {
    HeatIndexMonitor.stopMonitoring();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        HeatIndexMonitor.startMonitoring();
        break;
      case AppLifecycleState.paused:
        // Keep monitoring in background
        break;
      case AppLifecycleState.detached:
        HeatIndexMonitor.stopMonitoring();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      drawer: const SidebarMenu(),
      appBar: AppBar(
        title: const Text(
          'Record',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold
          ),
        ),
        centerTitle: true,
        backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        elevation: 0,
        toolbarHeight: 65,
        leadingWidth: 65,
        titleSpacing: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),  // Height of the divider
          child: Container(
            color: isDarkMode ? Colors.grey[900] : Colors.grey[300],
            height: 2.0,  // Thickness of the divider
          ),
        ),
      ),
      body: const HourlyRecordView(),
    );
  }
}