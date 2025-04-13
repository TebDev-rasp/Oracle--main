import 'package:flutter/material.dart';
import '../models/hourly_record.dart';

class HourlyRecordDetails extends StatelessWidget {
  final HourlyRecord record;

  const HourlyRecordDetails({
    super.key,
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildDetailRow('Temperature (°C)', record.temperatureCelsius),
          _buildDetailRow('Temperature (°F)', record.temperatureFahrenheit),
          _buildDetailRow('Heat Index (°C)', record.heatIndexCelsius),
          _buildDetailRow('Heat Index (°F)', record.heatIndexFahrenheit),
          _buildDetailRow('Humidity', record.humidity, suffix: '%'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, double value, {String suffix = '°'}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text('${value.toStringAsFixed(1)}$suffix'),
        ],
      ),
    );
  }
}