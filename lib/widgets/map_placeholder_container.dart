import 'package:flutter/material.dart';

class MapPlaceholderContainer extends StatelessWidget {
  const MapPlaceholderContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(top: .0),
      padding: const EdgeInsets.all(.0),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(2.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 10,
            // offset: const Offset(0, 4),
          ),
        ],
      ),
      height: 600,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map,
              size: 48,
              color: isDarkMode ? Colors.white54 : Colors.black38,
            ),
            const SizedBox(height: 16),
            Text(
              'Map View Coming Soon',
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.white54 : Colors.black38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
