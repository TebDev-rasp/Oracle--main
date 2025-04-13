import 'package:firebase_database/firebase_database.dart';
import 'package:logging/logging.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/weather_data_point.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Rename class to better reflect its purpose
class WeatherDataService {
  static final _logger = Logger('WeatherDataService');
  static final DatabaseReference _database = FirebaseDatabase.instance.ref();

  static Stream<List<WeatherDataPoint>> getRealtimeWeatherData() {
    return _database
        .child('hourly_records')
        .onValue
        .map((event) {
      if (event.snapshot.value == null) {
        throw Exception('No weather data available');
      }

      try {
        final Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;
        List<WeatherDataPoint> points = [];

        data.forEach((hourKey, value) {
          if (value is Map) {
            final hour = int.parse(hourKey.split(':')[0]);
            
            // Convert to integer using round()
            final heatIndex = value['heat_index']?['celsius'] != null 
                ? (value['heat_index']['celsius'] as num).round().toDouble()
                : 0.0;
                
            final temperature = value['temperature']?['celsius'] != null
                ? (value['temperature']['celsius'] as num).round().toDouble()
                : 0.0;
                
            final humidity = value['humidity'] != null
                ? (value['humidity'] as num).round().toDouble()
                : 0.0;
            
            final now = DateTime.now();
            final timestamp = DateTime(now.year, now.month, now.day, hour);
            
            points.add(WeatherDataPoint(
              timestamp: timestamp,
              heatIndex: heatIndex,
              temperature: temperature,
              humidity: humidity,
            ));
            
            _logger.fine('Real-time values for $hourKey: '
                'HI: $heatIndex°C, Temp: $temperature°C, Humidity: $humidity%');
          }
        });

        points.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        return points;
      } catch (e) {
        _logger.warning('Error parsing real-time data: $e');
        rethrow;
      }
    });
  }

  // Update return type to use WeatherDataPoint
  static Future<List<WeatherDataPoint>> get24HourHistory() async {
    try {
      if (FirebaseAuth.instance.currentUser == null) {
        _logger.warning('User not authenticated');
        return [];
      }

      final event = await _database
          .child('hourly_records')
          .get();
      
      if (event.value == null) {
        _logger.warning('No data available from Firebase');
        return [];
      }

      final Map<dynamic, dynamic> data = event.value as Map<dynamic, dynamic>;
      List<WeatherDataPoint> points = [];

      data.forEach((key, value) {
        try {
          if (value is Map) {
            final hour = int.parse(key.split(':')[0]);
            
            final heatIndex = value['heat_index']?['celsius'] != null 
                ? double.parse(value['heat_index']['celsius'].toString())
                : 0.0;
                
            final temperature = value['temperature']?['celsius'] != null
                ? double.parse(value['temperature']['celsius'].toString())
                : 0.0;
                
            final humidity = value['heat_index']?['humidity'] != null
                ? double.parse(value['heat_index']['humidity'].toString())
                : 0.0;
            
            final now = DateTime.now();
            final timestamp = DateTime(now.year, now.month, now.day, hour);
            
            points.add(WeatherDataPoint(
              timestamp: timestamp,
              heatIndex: heatIndex,
              temperature: temperature,
              humidity: humidity,
            ));
          }
        } catch (e) {
          _logger.warning('Error processing data for hour $key: $e');
        }
      });

      points.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return points;
    } catch (e) {
      _logger.severe('Error fetching weather data: $e');
      return [];
    }
  }

  // Get hourly average heat index data
  static Stream<Map<int, double>> getHourlyAverages() {
    return _database
        .child('hourly_records')
        .onValue
        .map((event) {
          final Map<int, double> hourlyData = {};

          if (event.snapshot.value == null) {
            return hourlyData;
          }

          final Map<dynamic, dynamic> data = 
              event.snapshot.value as Map<dynamic, dynamic>;

          data.forEach((key, value) {
            if (value is Map && value.containsKey('heat_index')) {
              final hour = DateTime.fromMillisecondsSinceEpoch(int.parse(key)).hour;
              final heatIndex = double.parse(value['heat_index'].toString());
              hourlyData[hour] = heatIndex;
            }
          });

          return hourlyData;
        });
  }

  // Convert HeatIndexDataPoint list to FlSpot list for FL Chart
  static List<FlSpot> convertToFlSpots(
    List<WeatherDataPoint> points, 
    String dataType // 'temperature', 'heatIndex', or 'humidity'
  ) {
    _logger.info('Converting ${points.length} points to spots for $dataType');
    
    final spots = points.map((point) {
      final hour = point.timestamp.hour.toDouble();
      final value = switch(dataType) {
        'temperature' => point.temperature,
        'humidity' => point.humidity,
        _ => point.heatIndex,
      };
      return FlSpot(hour, value);
    }).toList();

    spots.sort((a, b) => a.x.compareTo(b.x));
    return spots;
  }
}