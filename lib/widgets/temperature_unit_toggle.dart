import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/temperature_unit_provider.dart';

class TemperatureUnitToggle extends StatelessWidget {
  final bool isDarkMode;

  const TemperatureUnitToggle({
    super.key,
    required this.isDarkMode,
  });

  void _toggleUnit(BuildContext context) {
    final provider = Provider.of<TemperatureUnitProvider>(context, listen: false);
    provider.setFahrenheit(!provider.isFahrenheit);
    Navigator.pop(context);  // Close the sidebar
  }

  void _setUnit(BuildContext context, bool isFahrenheit) {
    final provider = Provider.of<TemperatureUnitProvider>(context, listen: false);
    provider.setFahrenheit(isFahrenheit);
    Navigator.pop(context);  // Close the sidebar
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TemperatureUnitProvider>(
      builder: (context, provider, child) {
        return GestureDetector(
          onTap: () => _toggleUnit(context),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildUnitButton(
                  context: context,
                  text: '°C',
                  isSelected: !provider.isFahrenheit,
                  onTap: () => _setUnit(context, false),
                  isLeft: true,
                ),
                _buildUnitButton(
                  context: context,
                  text: '°F',
                  isSelected: provider.isFahrenheit,
                  onTap: () => _setUnit(context, true),
                  isLeft: false,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUnitButton({
    required BuildContext context,
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isLeft,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDarkMode ? Colors.blue.withAlpha(51) : Colors.purple.withAlpha(26))
              : null,
          borderRadius: BorderRadius.horizontal(
            left: Radius.circular(isLeft ? 3 : 0),
            right: Radius.circular(isLeft ? 0 : 3),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12.0,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}