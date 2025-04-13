import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/humidity_data.dart';

class HumidityContainer extends StatelessWidget {
  static const double valueFontSize = 64.0;

  const HumidityContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 10.0),
          child: Row(  // Added Row to match Temperature container
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Humidity',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white : const Color(0xFF111217),
                ),
              ),
              // Space reserved for potential controls
              const SizedBox(width: 48),  // Match temperature swap button width
            ],
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
                Color(0xFFFFC067),  // Base orange from heat index
                Color(0xFFFFDEAF),  // Lighter orange from heat index
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
          child: Consumer<Humidity>(
            builder: (context, humidity, _) => Center(
              child: humidity.value == 0.0
                ? const CircularProgressIndicator()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        humidity.value.round().toString(), // Changed from toStringAsFixed(1)
                        style: const TextStyle(
                          fontSize: valueFontSize,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111217),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '%',
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
        ),
      ],
    );
  }
}