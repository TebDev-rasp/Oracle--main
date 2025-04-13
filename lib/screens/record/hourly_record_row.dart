import 'package:flutter/material.dart';
import 'package:oracle/models/hourly_record.dart';

class HourlyRecordRow extends DataRow {
  HourlyRecordRow({
    super.key,
    required String time,
    required String heatIndex,
    required String status,
    Color? statusColor,
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    required BuildContext context,
    required HourlyRecord record,
  }) : super(
    cells: [
      DataCell(
        Container(
          width: 80,
          alignment: Alignment.center,
          child: Text(
            _formatTo12Hour(time),
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            softWrap: false,
          ),
        ),
      ),
      DataCell(
        Container(
          width: 100,  // Changed from 90 to 100 to match column header
          alignment: Alignment.center,
          child: Text(
            heatIndex,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            softWrap: false,
          ),
        ),
      ),
      DataCell(
        Container(
          width: 100,
          alignment: Alignment.center,
          child: Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontSize: fontSize,
              fontWeight: fontWeight,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            softWrap: false,
          ),
        ),
      ),
    ],
  );

  static String _formatTo12Hour(String time24) {
    // Extract hour from "HH:00" format
    final hour = int.parse(time24.split(':')[0]);
    
    if (hour == 0) return '12:00 AM';
    if (hour == 12) return '12:00 PM';
    
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour > 12 ? hour - 12 : hour;
    
    return '$hour12:00 $period';
  }
}