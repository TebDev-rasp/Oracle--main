import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
class Humidity extends ChangeNotifier {
  double value;
  final DatabaseReference _dbRef;

  Humidity({
    this.value = 00.0,
  }) : _dbRef = FirebaseDatabase.instance.ref().child('sensor_data/raw/humidity') {
    _startListening();
  }

  void _startListening() {
    _dbRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        debugPrint('Humidity data received: $data');
        // Direct number conversion since data is not nested
        value = (data as num).toDouble();
        notifyListeners();
      }
    }, onError: (error) {
      debugPrint('Error receiving humidity data: $error');
    });
  }

  String get formattedValue => '${value.toStringAsFixed(1)}%';
}
