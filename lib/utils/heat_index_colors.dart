import 'package:flutter/material.dart';

class HeatIndexColors {
  static List<Color> getGradientColors(double value) {
    if (value <= 79.9) {
      return [
        const Color(0xFF80ef80),
        const Color(0xFFC1F7C1),
      ];
    }
    if (value >= 80.0 && value <= 90.9) {
      return [
        const Color(0xFFFFEE8C),
        const Color(0xFFFFFADB),
      ];
    }
    if (value >= 91.0 && value <= 102.9) {
      return [
        const Color(0xFFFFC067),
        const Color(0xFFFFDEAF),
      ];
    }
    if (value >= 103.0 && value <= 124.9) {
      return [
        const Color(0xFFFF746C),
        const Color(0xFFFFB9B5),
      ];
    }
    if (value >= 125.0) {
      return [
        const Color(0xFFB39EB5),
        const Color(0xFFD1C4D2),
      ];
    }
    return [
        const Color(0xFF2ECC71),
        const Color(0xFF82E0AA),
    ];
  }

  static Color getTextColor(double value) {
    if (value <= 79.9) {
      return const Color(0xFF06402b);
    }
    if (value >= 80.0 && value <= 90.9) {
      return const Color(0xFF453306);
    }
    if (value >= 91.0 && value <= 102.9) {
      return const Color(0xFF522d00);
    }
    if (value >= 103.0 && value <= 124.9) {
      return const Color(0xFFB41F32);
    }
    if (value >= 125.0) {
      return const Color(0xFF341539);
    }
    return Colors.white;
  }
}