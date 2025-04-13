import 'package:flutter/material.dart';

class TemperatureUtils {
  static Color getTemperatureColor(double temperature) {
    if (temperature <= 60) {
      return Colors.blue;
    } else if (temperature <= 90) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  static String getHeatIndexWarning(double temperature) {
    if (temperature >= 103) {
      return 'Danger';
    } else if (temperature >= 91) {
      return 'Caution';
    }
    return 'Normal';
  }
}
