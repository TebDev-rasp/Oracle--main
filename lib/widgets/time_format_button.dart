import 'package:flutter/material.dart';

class TimeFormatButton extends StatefulWidget {
  final Function(bool) onFormatChanged;
  final bool is24Hour;

  const TimeFormatButton({
    super.key,
    required this.onFormatChanged,
    required this.is24Hour,
  });

  @override
  State<TimeFormatButton> createState() => _TimeFormatButtonState();
}

class _TimeFormatButtonState extends State<TimeFormatButton> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = Theme.of(context).brightness;
    final buttonStyle = TextButton.styleFrom(
      foregroundColor: theme.colorScheme.onSurface,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
    );

    return TextButton.icon(
      style: buttonStyle,
      onPressed: () {
        widget.onFormatChanged(!widget.is24Hour);
      },
      icon: Icon(
        widget.is24Hour ? Icons.access_time : Icons.access_time_filled,
        size: 20,
        color: brightness == Brightness.light 
            ? Colors.black87 
            : Colors.white70,  // Inverse colors based on theme
      ),
      label: Text(
        widget.is24Hour ? '24h' : '12h',
        style: TextStyle(
          fontSize: 14,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}