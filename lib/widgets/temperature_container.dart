import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/temperature_data.dart';
import '../providers/temperature_unit_provider.dart';

class TemperatureContainer extends StatefulWidget {
  const TemperatureContainer({
    super.key,
    required this.temperature,
    required this.onSwap,
  });

  final Temperature temperature;
  final VoidCallback onSwap;

  @override
  State<TemperatureContainer> createState() => _TemperatureContainerState();
}

class _TemperatureContainerState extends State<TemperatureContainer> {
  static const double valueFontSize = 64.0;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Consumer<TemperatureUnitProvider>(
      builder: (context, provider, child) {
        final displayValue = provider.isFahrenheit 
            ? widget.temperature.value
            : (widget.temperature.value - 32) * 5 / 9;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 15, bottom: 10),
              child: Text(
                'Temperature',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white : const Color(0xFF111217),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              height: 150,
              margin: const EdgeInsets.only(top: 2, bottom: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFF0BB4FF),    // Base blue color
                    Color(0xFFCCEFFF),    // Lighter shade of blue (more similar to HeatIndex style)
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    offset: const Offset(0, 1),
                    blurRadius: 2,
                    spreadRadius: 0.5,
                  ),
                ],
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${displayValue.round()}°', // Changed from toStringAsFixed(1)
                      style: const TextStyle(
                        fontSize: valueFontSize,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111217),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        provider.isFahrenheit ? 'F' : 'C',
                        style: const TextStyle(
                          fontSize: valueFontSize * 0.6,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111217),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}