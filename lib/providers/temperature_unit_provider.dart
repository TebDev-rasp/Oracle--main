import 'package:flutter/foundation.dart';

class TemperatureUnitProvider with ChangeNotifier {
  bool _isFahrenheit = false;

  bool get isFahrenheit => _isFahrenheit;

  void setFahrenheit(bool value) {
    _isFahrenheit = value;
    notifyListeners();
  }
}