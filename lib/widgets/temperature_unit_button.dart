import 'package:flutter/material.dart';

enum TemperatureUnit { celsius, fahrenheit }

class TemperatureUnitButton extends StatelessWidget {
  final TemperatureUnit currentUnit;
  final Function(TemperatureUnit) onUnitChanged;

  const TemperatureUnitButton({
    super.key,
    required this.currentUnit,
    required this.onUnitChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final buttonStyle = TextButton.styleFrom(
      foregroundColor: isDark ? Colors.white70 : Colors.black87,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
    );

    return TextButton.icon(
      style: buttonStyle,
      onPressed: () {
        onUnitChanged(
          currentUnit == TemperatureUnit.celsius
              ? TemperatureUnit.fahrenheit
              : TemperatureUnit.celsius,
        );
      },
      icon: Icon(
        currentUnit == TemperatureUnit.celsius
            ? Icons.thermostat
            : Icons.thermostat_outlined,
        size: 20,
        color: isDark ? Colors.white : Colors.black87,
      ),
      label: Text(
        currentUnit == TemperatureUnit.celsius ? '°C' : '°F',
        style: TextStyle(
          fontSize: 14,
          color: isDark ? Colors.white70 : Colors.black87,
        ),
      ),
    );
  }
}