import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import '../models/hourly_record.dart';

class PngGenerator {
  static Widget generateTable(List<HourlyRecord> records, bool isCelsius) {
    return Material(
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            Table(
              border: TableBorder.all(
                color: Colors.grey[400]!,
                width: 1,
              ),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: const {
                0: FlexColumnWidth(0.8),  // Time
                1: FlexColumnWidth(1.2),  // Temperature
                2: FlexColumnWidth(1.2),  // Heat Index
                3: FlexColumnWidth(0.8),  // Humidity
                4: FlexColumnWidth(1.0),  // Status
              },
              children: [
                _buildHeaderRow(),
                ...records.map((record) => _buildDataRow(record, isCelsius)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8.0),
      color: Colors.blue[100],
      child: const Text(
        'Hourly Weather Records',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  static TableRow _buildHeaderRow() {
    return TableRow(
      decoration: BoxDecoration(color: Colors.grey[200]),
      children: [
        _buildHeaderCell('Time'),
        _buildHeaderCell('Temperature\n(°C/°F)'),
        _buildHeaderCell('Heat Index\n(°C/°F)'),
        _buildHeaderCell('Humidity\n(%)'),
        _buildHeaderCell('Status'),
      ],
    );
  }

  static TableRow _buildDataRow(HourlyRecord record, bool isCelsius) {
    return TableRow(
      children: [
        _buildCell(_formatTime(record.time)),
        _buildCell(isCelsius 
            ? '${record.temperatureCelsius.round()}°C'
            : '${(record.temperatureFahrenheit).round()}°F'),
        _buildCell(isCelsius
            ? '${record.heatIndexCelsius.round()}°C'
            : '${(record.heatIndexFahrenheit).round()}°F'),
        _buildCell('${record.humidity.round()}%'),
        _buildCell(_getHeatIndexStatus(record.heatIndexCelsius),
            color: _getStatusColor(record.heatIndexCelsius)),
      ],
    );
  }

  static Widget _buildHeaderCell(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.black, width: 2),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  static Widget _buildCell(String text, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4), // Reduced padding
      color: color,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11, // Smaller font size
          color: color != null ? Colors.white : Colors.black87,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  static Color _getStatusColor(double heatIndex) {
    if (heatIndex < 27) return Colors.green;
    if (heatIndex < 32) return Colors.yellow[700]!;
    if (heatIndex < 41) return Colors.orange;
    if (heatIndex < 54) return Colors.red;
    return Colors.purple;
  }

  static String _formatTime(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '${hour12.toString().padLeft(2, '0')}:$minute $period';
  }

  static String _getHeatIndexStatus(double heatIndex) {
    if (heatIndex < 27) return 'Normal';
    if (heatIndex < 32) return 'Caution';
    if (heatIndex < 41) return 'Extreme Caution';
    if (heatIndex < 54) return 'Danger';
    return 'Extreme Danger';
  }

  static Future<Uint8List> generateImage(List<HourlyRecord> records) async {
    final screenshotController = ScreenshotController();
    
    // Fixed dimensions for all dataset sizes
    final baseWidth = 1200.0;  // Increased width to ensure table fits
    final rowHeight = 50.0;
    final headerHeight = 120.0;
    
    // Calculate height based on content
    final contentHeight = (records.length * rowHeight) + headerHeight;
    final minHeight = 400.0;
    final actualHeight = contentHeight < minHeight ? minHeight : contentHeight;
    
    return await screenshotController.captureFromWidget(
      Container(
        width: baseWidth,
        height: actualHeight,
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: FittedBox(  // Added FittedBox to ensure table fits
          fit: BoxFit.contain,
          child: SizedBox(
            width: baseWidth,
            child: generateTable(records, true),
          ),
        ),
      ),
      delay: const Duration(milliseconds: 300),
      targetSize: Size(baseWidth, actualHeight),  // Use full width for all cases
      pixelRatio: 3.0,
    );
  }
}