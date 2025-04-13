import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/heat_index_data.dart';
import '../models/comfort_level.dart';
import '../models/risk_level.dart';
import '../utils/heat_index_colors.dart';
import '../providers/temperature_unit_provider.dart';

class HeatIndexContainer extends StatefulWidget {
  static const double _valueFontSize = 64.0;

  final HeatIndex heatIndex;
  final ComfortLevel comfortLevel;
  final VoidCallback onSwap;

  const HeatIndexContainer({
    super.key,
    required this.heatIndex,
    this.comfortLevel = const ComfortLevel(),
    required this.onSwap,
  });

  @override
  State<HeatIndexContainer> createState() => _HeatIndexContainerState();
}

class _HeatIndexContainerState extends State<HeatIndexContainer> {
  String _getComfortStatus() {
    return ComfortLevel.getStatus(widget.heatIndex.value);
  }

  String _getRiskLevel() {
    return RiskLevel.getStatus(widget.heatIndex.value);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final gradientColors = HeatIndexColors.getGradientColors(widget.heatIndex.value);

    return Consumer<TemperatureUnitProvider>(
      builder: (context, provider, child) {
        final displayValue = provider.isFahrenheit 
            ? widget.heatIndex.value
            : (widget.heatIndex.value - 32) * 5 / 9;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 15, bottom: 10),
              child: Text(
                'Heat Index',
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
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: gradientColors,
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
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _getComfortStatus(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: HeatIndexColors.getTextColor(widget.heatIndex.value),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${displayValue.round()}°', // Changed from toStringAsFixed(1)
                          style: TextStyle(
                            fontSize: HeatIndexContainer._valueFontSize,
                            fontWeight: FontWeight.bold,
                            color: HeatIndexColors.getTextColor(widget.heatIndex.value),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            provider.isFahrenheit ? 'F' : 'C',
                            style: TextStyle(
                              fontSize: HeatIndexContainer._valueFontSize * 0.6,
                              fontWeight: FontWeight.bold,
                              color: HeatIndexColors.getTextColor(widget.heatIndex.value),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                content: Text(
                                  _getRiskLevel(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            },
                          );
                        },
                        child: Text(
                          _getRiskLevel(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: HeatIndexColors.getTextColor(widget.heatIndex.value),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}