import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';

class Temperature extends ChangeNotifier {
  double value;    
  double celsius;
  final DatabaseReference _dbRef;

  Temperature({
    this.value = 00.0,     
    this.celsius = 00.0,   
  }) : _dbRef = FirebaseDatabase.instance.ref().child('sensor_data/raw/temperature') {
    _startListening();
  }

  void _startListening() {
    _dbRef.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        value = (data['fahrenheit'] as num).toDouble();    
        celsius = (data['celsius'] as num).toDouble();     
        notifyListeners();  // This will trigger UI updates automatically
      }
    });
  }
}