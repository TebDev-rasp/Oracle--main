import 'package:flutter/material.dart';

class HeatIndexMarker {
  final double latitude;
  final double longitude;
  final double heatIndex;
  final DateTime timestamp;

  HeatIndexMarker({
    required this.latitude,
    required this.longitude,
    required this.heatIndex,
    required this.timestamp,
  });

  Color get markerColor {
    if (heatIndex >= 39.4) return Colors.red;
    if (heatIndex >= 32.2) return Colors.orange;
    if (heatIndex >= 26.7) return Colors.yellow;
    return Colors.green;
  }

  String get heatIndexLevel {
    if (heatIndex >= 39.4) return 'Danger';
    if (heatIndex >= 32.2) return 'Extreme Caution';
    if (heatIndex >= 26.7) return 'Caution';
    return 'Safe';
  }
}