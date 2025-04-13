import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HistoricalDataProvider with ChangeNotifier {
  static const String _storageKey = 'historical_data';
  static const String _unitKey = 'temperature_unit';
  List<Map<String, dynamic>> _historicalData = [];
  bool _isCelsius = true;
  double? _lastRawHeatIndex;

  List<Map<String, dynamic>> get historicalData => _historicalData;
  bool get isCelsius => _isCelsius;

  HistoricalDataProvider() {
    loadData();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedData = prefs.getString(_storageKey);
    if (storedData != null) {
      _historicalData = List<Map<String, dynamic>>.from(
        json.decode(storedData).map((x) => Map<String, dynamic>.from(x))
      );
    }
    _isCelsius = prefs.getBool(_unitKey) ?? true;
    notifyListeners();
  }

  Future<void> setTemperatureUnit(bool isCelsius) async {
    _isCelsius = isCelsius;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_unitKey, isCelsius);
    notifyListeners();
  }

  Future<void> addReading(Map<String, dynamic> reading) async {
    _historicalData.add(reading);
    await _saveHistoricalData();
    notifyListeners();
  }

  Future<void> clearHistory() async {
    _historicalData.clear();
    await _saveHistoricalData();
    notifyListeners();
  }

  Future<void> _saveHistoricalData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, json.encode(_historicalData));
  }

  bool checkSignificantChange(double currentHeatIndex) {
    if (_lastRawHeatIndex == null) {
      _lastRawHeatIndex = currentHeatIndex;
      return true;
    }
    const threshold = 1.0;
    bool isSignificant = (currentHeatIndex - _lastRawHeatIndex!).abs() > threshold;
    if (isSignificant) {
      _lastRawHeatIndex = currentHeatIndex;
    }
    return isSignificant;
  }
}