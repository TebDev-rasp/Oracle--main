import 'package:flutter/material.dart';
import 'map_widget.dart';

class MapPlaceholder extends StatelessWidget {
  const MapPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 0),
          child: Text(
            'Location',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white : const Color(0xFF111217),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          height: 600,
          margin: const EdgeInsets.only(top: 8, bottom: 24),
          child: const MapWidget(),
        ),
      ],
    );
  }
}