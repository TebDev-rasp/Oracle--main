import 'package:flutter/material.dart';
import '../../models/hourly_record.dart';

class TemperatureHumidityTable extends StatelessWidget {
  final bool isCelsius;
  final List<HourlyRecord> records;

  const TemperatureHumidityTable({
    super.key,
    required this.isCelsius,
    required this.records,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    final tableWidth = screenWidth * 0.95;     // 95% of screen width
    final timeWidth = tableWidth * 0.28;       // 28% of table width
    final tempWidth = tableWidth * 0.32;       // 32% of table width
    final humidityWidth = tableWidth * 0.40;   // 40% of table width
    
    final verticalPadding = screenHeight * 0.015;  // 1.5% of screen height
    final fontSize = screenWidth * 0.035;          // 3.5% of screen width
// 10% larger than content
// 0.2% of screen width

    return SizedBox(
      height: screenHeight * 0.72,  // 72% of screen height
      child: Container(
        color: Theme.of(context).brightness == Brightness.dark 
            ? const Color(0xFF1A1A1A) 
            : Colors.white,
        child: Column(
          children: [
            // Fixed Header
            Container(
              width: double.infinity,
              color: Theme.of(context).brightness == Brightness.dark 
                  ? const Color(0xFF1A1A1A) 
                  : Colors.white,
              alignment: Alignment.center,
              child: SizedBox(
                width: tableWidth,
                child: Table(
                  columnWidths: {
                    0: FixedColumnWidth(timeWidth),
                    1: FixedColumnWidth(tempWidth),
                    2: FixedColumnWidth(humidityWidth),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Theme.of(context).dividerColor,
                            width: screenWidth * 0.005,
                          ),
                        ),
                      ),
                      children: [
                        _buildHeaderCell('Time', fontSize, verticalPadding),
                        _buildHeaderCell('Temperature', fontSize, verticalPadding),
                        _buildHeaderCell('Humidity', fontSize, verticalPadding),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: SizedBox(
                    width: tableWidth,
                    child: Table(
                      columnWidths: {
                        0: FixedColumnWidth(timeWidth),
                        1: FixedColumnWidth(tempWidth),
                        2: FixedColumnWidth(humidityWidth),
                      },
                      children: records.map((record) {
                        final temperature = isCelsius
                            ? '${record.temperatureCelsius.round()}°C'
                            : '${record.temperatureFahrenheit.round()}°F';
                        final humidity = '${record.humidity.round()}%';

                        return TableRow(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Theme.of(context).dividerColor.withAlpha(51),
                                width: 1,
                              ),
                            ),
                          ),
                          children: [
                            _buildTimeCell(record.time, fontSize, verticalPadding, context),
                            _buildDataCell(temperature, fontSize, verticalPadding, true), // Added true for temperature
                            _buildDataCell(humidity, fontSize, verticalPadding),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text, double fontSize, double padding) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: padding),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildTimeCell(String time, double fontSize, double padding, BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: padding),
      decoration: _isCurrentTime(time)
          ? BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withAlpha(51),
              borderRadius: BorderRadius.circular(4),
            )
          : null,
      child: Text(
        _formatTime(time),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: fontSize,
          color: _isCurrentTime(time)
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface,
          fontWeight: _isCurrentTime(time)
              ? FontWeight.bold
              : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildDataCell(String text, double fontSize, double padding, [bool isTemperature = false]) {
    if (!isTemperature) {
      return TableCell(
        verticalAlignment: TableCellVerticalAlignment.middle,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: padding),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(fontSize: fontSize),
          ),
        ),
      );
    }

    // Handle temperature cell
    final numValue = double.tryParse(text.replaceAll(RegExp(r'[^0-9.-]'), '')) ?? 0;
    
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: padding),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            color: _getTemperatureColor(numValue, isCelsius),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  bool _isCurrentTime(String recordTime) {
    final now = DateTime.now();
    final currentHour = now.hour;
    
    final parts = recordTime.split(':');
    final recordHour = int.parse(parts[0]);
    final recordMinute = int.parse(parts[1]);

    return recordHour == currentHour && recordMinute == 0;
  }

  String _formatTime(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '${hour12.toString().padLeft(2, '0')}:$minute $period';
  }

  Color _getTemperatureColor(double temperature, bool isCelsius) {
    final tempC = isCelsius ? temperature : (temperature - 32) * 5 / 9;
    
    if (tempC < 27) return Colors.green;            // Normal
    if (tempC < 32) return Colors.orange;           // Caution
    if (tempC < 41) return Colors.deepOrange;       // Extreme Caution
    if (tempC < 54) return Colors.red;              // Danger
    return Colors.purple;                           // Extreme Danger
  }

}