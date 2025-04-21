import 'package:firebase_database/firebase_database.dart';
import 'package:oracle/models/heat_index_marker.dart';

class HeatIndexLeafletService {
  final DatabaseReference _heatIndexDatabase = FirebaseDatabase.instance
      .ref()
      .child('sensor_data')
      .child('smooth')
      .child('heat_index');

  final DatabaseReference _locationDatabase =
      FirebaseDatabase.instance.ref().child('gps_data');

  // This stream will update whenever location changes
  Stream<HeatIndexMarker> getHeatIndexStream() {
    return _locationDatabase.onValue.asyncMap((locationEvent) async {
      // Get location data
      final locationData =
          locationEvent.snapshot.value as Map<dynamic, dynamic>? ?? {};
      final latitude =
          (locationData['latitude'] as num?)?.toDouble() ?? 14.9320671;
      final longitude =
          (locationData['longitude'] as num?)?.toDouble() ?? 120.244495;

      // Get the latest heat index data
      final heatSnapshot = await _heatIndexDatabase.get();
      final heatData = heatSnapshot.value as Map<dynamic, dynamic>? ?? {};
      final celsius = (heatData['celsius'] as num?)?.toDouble() ?? 0.0;

      return HeatIndexMarker(
        latitude: latitude,
        longitude: longitude,
        heatIndex: celsius,
        timestamp: DateTime.now(),
      );
    });
  }

  Future<double> getCurrentHeatIndex() async {
    final snapshot = await _heatIndexDatabase.get();
    final data = snapshot.value as Map<dynamic, dynamic>? ?? {};
    return (data['celsius'] as num?)?.toDouble() ?? 0.0;
  }
}
