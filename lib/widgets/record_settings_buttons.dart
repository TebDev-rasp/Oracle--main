import 'package:flutter/material.dart';
import '../models/hourly_record.dart';
import 'download_dialog.dart';

class RecordSettingsButtons extends StatelessWidget {
  final bool isCelsius;
  final VoidCallback onTemperatureUnitChanged;
  final List<HourlyRecord> records;
  final String currentTimeFilter;
  final Function(String) onTimeFilterChanged;
  final double buttonSize;
  final double buttonPadding;
  final double buttonSpacing;

  const RecordSettingsButtons({
    super.key,
    required this.isCelsius,
    required this.onTemperatureUnitChanged,
    required this.records,
    required this.currentTimeFilter,
    required this.onTimeFilterChanged,
    required this.buttonSize,
    required this.buttonPadding,
    required this.buttonSpacing,
  });

  void _showTimeFilterMenu(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final menuItemFontSize = screenWidth * 0.035;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(100, 100, 0, 0),
      items: [
        PopupMenuItem(
          value: 'All',
          child: Text('All Times', style: TextStyle(fontSize: menuItemFontSize)),
        ),
        PopupMenuItem(
          value: 'Morning',
          child: Text('Morning (6AM-12PM)', style: TextStyle(fontSize: menuItemFontSize)),
        ),
        PopupMenuItem(
          value: 'Afternoon',
          child: Text('Afternoon (12PM-5PM)', style: TextStyle(fontSize: menuItemFontSize)),
        ),
        PopupMenuItem(
          value: 'Evening',
          child: Text('Evening (5PM-8PM)', style: TextStyle(fontSize: menuItemFontSize)),
        ),
        PopupMenuItem(
          value: 'Night',
          child: Text('Night (8PM-6AM)', style: TextStyle(fontSize: menuItemFontSize)),
        ),
      ],
    ).then((value) {
      if (value != null) {
        onTimeFilterChanged(value);
      }
    });
  }

  void _showDownloadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => DownloadDialog(
        records: records,
        isCelsius: isCelsius,  // Add this parameter
      ),
    );
  }

  IconData _getTimeFilterIcon(String filter) {
    switch (filter) {
      case 'Morning':
        return Icons.wb_sunny_rounded;
      case 'Afternoon':
        return Icons.wb_twilight_rounded;
      case 'Evening':
        return Icons.nights_stay_outlined;
      case 'Night':
        return Icons.bedtime_rounded;
      default:
        return Icons.access_time_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark 
        ? Colors.white.withAlpha(51)  // White with 20% opacity for dark mode
        : theme.colorScheme.onSurface.withAlpha(51);

    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.download),
          style: IconButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: borderColor,
                width: 1,
              ),
            ),
          ),
          onPressed: () => _showDownloadDialog(context),
        ),
        SizedBox(width: buttonSpacing),
        IconButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return RotationTransition(
                turns: animation,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: Icon(
              _getTimeFilterIcon(currentTimeFilter),
              key: ValueKey<String>(currentTimeFilter),
            ),
          ),
          style: IconButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: borderColor,
                width: 1,
              ),
            ),
          ),
          onPressed: () => _showTimeFilterMenu(context),
        ),
        SizedBox(width: buttonSpacing),
        IconButton(
          icon: Text(
            isCelsius ? '°C' : '°F',
            style: TextStyle(
              fontSize: buttonSize * 1,
              fontWeight: FontWeight.bold,
              color: theme.iconTheme.color,
            ),
          ),
          style: IconButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: borderColor,
                width: 1,
              ),
            ),
          ),
          onPressed: onTemperatureUnitChanged,
        ),
      ],
    );
  }
}