import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firebase_service.dart';
import '../../models/hourly_record.dart';
import 'heat_index_table.dart';
import '../../widgets/record_settings_buttons.dart';

class HourlyRecordView extends StatefulWidget {
  const HourlyRecordView({super.key});

  @override
  State<HourlyRecordView> createState() => _HourlyRecordViewState();
}

class _HourlyRecordViewState extends State<HourlyRecordView> {
  bool _isCelsius = true;
  String _timeFilter = 'All';
  final ScrollController _scrollController = ScrollController();
  final FirebaseService _firebaseService = FirebaseService();

  TextStyle _createTextStyle({
    required double fontSize,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      // Use theme color instead of hardcoded color
      color: Theme.of(context).textTheme.titleLarge?.color,
    );
  }

  @override
  void initState() {
    super.initState();
    // Remove direct call to _scrollToCurrentTime
  }


  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<HourlyRecord> _getFilteredRecords(List<HourlyRecord> records) {
    if (_timeFilter == 'All') return records;
    
    return records.where((record) {
      final hour = int.parse(record.time.split(':')[0]);
      switch (_timeFilter) {
        case 'Morning':
          return hour >= 6 && hour < 12;
        case 'Afternoon':
          return hour >= 12 && hour < 17;
        case 'Evening':
          return hour >= 17 && hour < 20;
        case 'Night':
          return hour >= 20 || hour < 6;
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Adjust these values to make buttons smaller
    final buttonSize = screenWidth * 0.035;      // Decreased from 0.045
    final buttonPadding = screenWidth * 0.015;   // Decreased from 0.02
    final buttonSpacing = screenWidth * 0.015;   // Space between buttons
    final titleFontSize = screenWidth * 0.05;    // Keep title size same

    final headerPadding = EdgeInsets.fromLTRB(
      screenWidth * 0.04,
      screenHeight * 0.02,
      screenWidth * 0.04,
      screenHeight * 0.01
    );

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!authSnapshot.hasData) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Please login to view records'),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  child: const Text('Login'),
                ),
              ],
            ),
          );
        }

        return StreamBuilder<List<HourlyRecord>>(
          stream: _firebaseService.getHourlyRecords(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading records: ${snapshot.error}',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final records = snapshot.data ?? [];
            final filteredRecords = _getFilteredRecords(records);

            return Container(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? const Color(0xFF1A1A1A)
                  : Colors.white,
              child: Column(
                children: [
                  Padding(
                    padding: headerPadding,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Hourly Records',
                          style: _createTextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        RecordSettingsButtons(
                          isCelsius: _isCelsius,
                          onTemperatureUnitChanged: () {
                            setState(() {
                              _isCelsius = !_isCelsius;
                            });
                          },
                          records: filteredRecords,
                          currentTimeFilter: _timeFilter,
                          onTimeFilterChanged: (value) {
                            setState(() {
                              _timeFilter = value;
                            });
                          },
                          // Add these new properties
                          buttonSize: buttonSize,
                          buttonPadding: buttonPadding,
                          buttonSpacing: buttonSpacing,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: HeatIndexTable(
                      records: filteredRecords,
                      isCelsius: _isCelsius,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}