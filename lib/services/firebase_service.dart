import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import '../models/hourly_record.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'heat_index_monitor.dart';

class FirebaseService {
  static final _logger = Logger('FirebaseService');
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static bool _isInitialized = false;

  Stream<List<HourlyRecord>> getHourlyRecords() {
    return _auth.authStateChanges().switchMap((user) {
      if (user == null) {
        _logger.warning('No authenticated user');
        return Stream.value(<HourlyRecord>[]);
      }

      return _database
          .child('hourly_records')  // Fixed path to match rules
          .onValue
          .map((event) {
            if (event.snapshot.value == null) return <HourlyRecord>[];

            try {
              final Map<dynamic, dynamic> data = 
                  event.snapshot.value as Map<dynamic, dynamic>;
               
              final records = <HourlyRecord>[];
              
              data.forEach((time, value) {
                if (value is Map) {
                  try {
                    records.add(HourlyRecord.fromMap(time.toString(), 
                      Map<String, dynamic>.from(value)));
                  } catch (e) {
                    _logger.warning('Error parsing record for time $time: $e');
                  }
                }
              });

              return records..sort((a, b) => a.time.compareTo(b.time));
            } catch (e) {
              _logger.severe('Error parsing hourly records', e);
              return <HourlyRecord>[];
            }
          });
    });
  }

  // Method to get a specific hour's record
  Future<HourlyRecord?> getHourlyRecord(String time) async {
    try {
      final event = await _database.child('hourly_records/$time').once();
      final data = event.snapshot.value;
      
      if (data == null || data is! Map) {
        _logger.warning('No data found for time: $time');
        return null;
      }

      return HourlyRecord.fromMap(time, Map<String, dynamic>.from(data));
    } catch (e) {
      _logger.severe('Error fetching record for time $time: $e');
      rethrow;
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    if (!Firebase.apps.isNotEmpty) {
      await Firebase.initializeApp();
    }

    if (message.data.containsKey('heat_index')) {
      final heatIndex = double.tryParse(message.data['heat_index']);
      if (heatIndex != null) {
        await HeatIndexMonitor.checkHeatIndex(heatIndex);
      }
    }
  }

  // Convert static methods to instance methods
  Future<void> initialize() async {
    _logger.info('Initializing Firebase connection...');
    
    // Monitor heat index path
    _database.child('sensor_data/smooth/heat_index/celsius').onValue.listen(
      (event) {
        _logger.info('Received heat index: ${event.snapshot.value}');
        if (event.snapshot.value != null) {
          final heatIndex = double.tryParse(event.snapshot.value.toString());
          if (heatIndex != null) {
            _logger.info('Processing heat index: $heatIndex°C');
            HeatIndexMonitor.checkHeatIndex(heatIndex);
          }
        }
      },
      onError: (error) {
        _logger.severe('Database error: $error');
      }
    );

    if (_isInitialized) return;

    try {
      // Initialize Firebase features
      await _initializeFirebaseFeatures();
      
      _isInitialized = true;
      _logger.info('Firebase service initialized successfully');
    } catch (e) {
      _logger.severe('Failed to initialize Firebase service: $e');
    }
  }

  Future<void> _initializeFirebaseFeatures() async {
    FirebaseDatabase.instance.setPersistenceEnabled(true);

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: false,
      criticalAlert: true,
    );

    final token = await FirebaseMessaging.instance.getToken();
    _logger.info('FCM Token: $token');

    await FirebaseMessaging.instance.setAutoInitEnabled(true);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await FirebaseMessaging.instance.subscribeToTopic('heat_index_updates');
  }

  Future<void> testConnection() async {
    try {
      final snapshot = await _database
          .child('sensor_data/smooth/heat_index/celsius')
          .get();
      
      _logger.info('Test connection value: ${snapshot.value}');
      
      if (snapshot.value != null) {
        final heatIndex = double.tryParse(snapshot.value.toString());
        if (heatIndex != null) {
          _logger.info('Test heat index: $heatIndex°C');
          await HeatIndexMonitor.checkHeatIndex(heatIndex);
        }
      }
    } catch (e) {
      _logger.severe('Test connection failed: $e');
    }
  }

  // Initialize logging
  static void initializeLogging() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      // Use logger instead of print
      _logger.log(record.level, 
          '${record.loggerName}: ${record.time}: ${record.message}');
    });
  }
}