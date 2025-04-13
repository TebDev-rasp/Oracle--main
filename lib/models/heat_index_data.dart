import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:oracle/services/notification_service.dart';

class HeatIndex extends ChangeNotifier {
  double value;    // This will store Fahrenheit
  double celsius;
  final DatabaseReference _dbRef;
  final NotificationService _notificationService;

  HeatIndex({
    this.value = 00.0,     // Fahrenheit value
    this.celsius = 00.0,   // Celsius value
  }) : _dbRef = FirebaseDatabase.instance.ref().child('sensor_data/smooth/heat_index'),
       _notificationService = NotificationService() {
    _startListening();
  }

  void _startListening() {
    _dbRef.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        value = (data['fahrenheit'] as num).toDouble();    // Store Fahrenheit in value
        celsius = (data['celsius'] as num).toDouble();     // Store Celsius in celsius
        notifyListeners();
        _processHeatIndex(value);
      }
    });
  }

  void _processHeatIndex(double heatIndex) {
    // Process heat index logic here
    
    // Show notification with Celsius value using instance method
    _notificationService.showHeatIndexNotification(celsius);
  }

  String get formattedValue => '${value.toStringAsFixed(1)}°F';
}
