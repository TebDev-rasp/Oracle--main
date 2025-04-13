import 'package:flutter/material.dart';
import '../../models/hourly_record.dart';

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
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Temperature (°C)', '${record.temperatureCelsius.toStringAsFixed(1)}°C'),
          _buildDetailRow('Temperature (°F)', '${record.temperatureFahrenheit.toStringAsFixed(1)}°F'),
          _buildDetailRow('Heat Index (°C)', '${record.heatIndexCelsius.toStringAsFixed(1)}°C'),
          _buildDetailRow('Heat Index (°F)', '${record.heatIndexFahrenheit.toStringAsFixed(1)}°F'),
          _buildDetailRow('Humidity', '${record.humidity.toStringAsFixed(1)}%'),
          _buildDetailRow('Timestamp', DateTime.fromMillisecondsSinceEpoch(record.timestamp).toString()),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }
}