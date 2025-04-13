import 'package:flutter/material.dart';

class TimeFilterButton extends StatelessWidget {
  final String currentFilter;
  final Function(String) onFilterChanged;

  const TimeFilterButton({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Filter by Time',
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIconForFilter(currentFilter),
            size: 20,
          ),
          const SizedBox(width: 4),
          Text(
            _getShortLabel(currentFilter),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      onSelected: onFilterChanged,
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'All',
          child: Text('All Times'),
        ),
        const PopupMenuItem(
          value: 'Morning',
          child: Text('Morning (6AM-12PM)'),
        ),
        const PopupMenuItem(
          value: 'Afternoon',
          child: Text('Afternoon (12PM-5PM)'),
        ),
        const PopupMenuItem(
          value: 'Evening',
          child: Text('Evening (5PM-8PM)'),
        ),
        const PopupMenuItem(
          value: 'Night',
          child: Text('Night (8PM-6AM)'),
        ),
      ],
    );
  }

  IconData _getIconForFilter(String filter) {
    switch (filter) {
      case 'Morning':
        return Icons.wb_sunny;
      case 'Afternoon':
        return Icons.wb_twighlight;
      case 'Evening':
        return Icons.nights_stay_outlined;
      case 'Night':
        return Icons.nights_stay;
      default:
        return Icons.access_time;
    }
  }

  String _getShortLabel(String filter) {
    return filter == 'All' ? 'All Times' : filter;
  }
}