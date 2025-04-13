import 'package:firebase_database/firebase_database.dart';
import 'package:oracle/models/heat_index_marker.dart';

class HeatIndexLeafletService {
  final DatabaseReference _database = FirebaseDatabase.instance
      .ref()
      .child('sensor_data')
      .child('smooth')
      .child('heat_index');

  Stream<HeatIndexMarker> getHeatIndexStream() {
    return _database.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      final celsius = (data['celsius'] as num).toDouble();
      
      return HeatIndexMarker(
        latitude: 14.9320671,
        longitude: 120.2005402,
        heatIndex: celsius,
        timestamp: DateTime.now(),
      );
    });
  }

  Future<double> getCurrentHeatIndex() async {
    final snapshot = await _database.get();
    final data = snapshot.value as Map<dynamic, dynamic>;
    return (data['celsius'] as num).toDouble();
  }
}