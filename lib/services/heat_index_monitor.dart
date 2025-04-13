import 'dart:async';
import 'package:logging/logging.dart';
import 'package:firebase_database/firebase_database.dart';
import 'notification_service.dart';

class HeatIndexMonitor {
  static final _logger = Logger('HeatIndexMonitor');
  static bool _isMonitoring = false;
  static StreamSubscription<DatabaseEvent>? _subscription;
  static final DatabaseReference _database = FirebaseDatabase.instance.ref();
  static final _notificationService = NotificationService();

  static Future<void> startMonitoring() async {
    if (_isMonitoring) {
      _logger.info('Heat index monitoring already active');
      return;
    }

    _logger.info('Starting heat index monitoring');
    
    _subscription = _database
        .child('sensor_data/smooth/heat_index/celsius')
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        final heatIndex = double.tryParse(event.snapshot.value.toString());
        if (heatIndex != null) {
          _logger.info('Received heat index update: $heatIndex°C');
          checkHeatIndex(heatIndex);
        }
      }
    }, onError: (error) {
      _logger.severe('Error monitoring heat index: $error');
    });

    _isMonitoring = true;
    _logger.info('Heat index monitoring started');
  }

  static Future<void> stopMonitoring() async {
    if (!_isMonitoring) return;

    await _subscription?.cancel();
    _subscription = null;
    _isMonitoring = false;
    _logger.info('Heat index monitoring stopped');
  }

  static Future<void> checkHeatIndex(double heatIndex) async {
    _logger.info('Checking heat index: $heatIndex');
    
    // Use NotificationService instead of direct notification
    await _notificationService.showHeatIndexNotification(heatIndex);
  }
}

class DataService {
  Future<void> processNewData(Map<String, dynamic> data) async {
    if (data.containsKey('heat_index')) {
      final heatIndex = double.tryParse(data['heat_index'].toString());
      if (heatIndex != null) {
        await HeatIndexMonitor.checkHeatIndex(heatIndex);
      }
    }
  }
}