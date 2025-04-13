import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:io';
import '../models/hourly_record.dart';
import 'pdf_generator.dart';
import 'png_generator.dart';

class DownloadDialog extends StatefulWidget {
  final List<HourlyRecord> records;
  final bool isCelsius;

  const DownloadDialog({
    super.key,
    required this.records,
    required this.isCelsius,
  });

  @override
  State<DownloadDialog> createState() => _DownloadDialogState();
}

class _DownloadDialogState extends State<DownloadDialog> {
  String _selectedTimeFilter = 'All';
  final screenshotController = ScreenshotController();

  List<HourlyRecord> get _filteredRecords {
    if (_selectedTimeFilter == 'All') return widget.records;
    
    return widget.records.where((record) {
      final hour = int.parse(record.time.split(':')[0]);
      switch (_selectedTimeFilter) {
        case 'Morning':
          return hour >= 6 && hour < 12;
        case 'Afternoon':
          return hour >= 12 && hour < 17;
        case 'Evening':
          return hour >= 17 && hour < 20;
        case 'Night':
          return hour >= 20 || hour < 6;
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Download Records'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Filter by Time',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            value: _selectedTimeFilter,
            items: const [
              DropdownMenuItem(value: 'All', child: Text('All Times')),
              DropdownMenuItem(value: 'Morning', child: Text('Morning (6AM-12PM)')),
              DropdownMenuItem(value: 'Afternoon', child: Text('Afternoon (12PM-5PM)')),
              DropdownMenuItem(value: 'Evening', child: Text('Evening (5PM-8PM)')),
              DropdownMenuItem(value: 'Night', child: Text('Night (8PM-6AM)')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedTimeFilter = value;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf),
            title: const Text('Download as PDF'),
            onTap: () => _downloadAsPdf(context),
          ),
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text('Download as PNG'),
            onTap: () => _downloadAsImage(context),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Future<void> _downloadAsPdf(BuildContext context) async {
    final isContextMounted = context.mounted;
    
    try {
      // Show loading indicator
      if (isContextMounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Generating PDF...')),
        );
      }

      final pdf = await PdfGenerator.generateDocument(
        _filteredRecords, 
        widget.isCelsius
      );
      final bytes = await pdf.save();
      
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/hourly_records.pdf');
      await file.writeAsBytes(bytes);

      if (isContextMounted) {
        await Share.shareXFiles([XFile(file.path)]);
        if (context.mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (isContextMounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating PDF: $e')),
        );
      }
    }
  }

  Future<void> _downloadAsImage(BuildContext context) async {
    final isContextMounted = context.mounted;
    
    try {
      // Show loading indicator
      if (isContextMounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Generating image...')),
        );
      }

      final rowHeight = 70.0;  // Increased from 50.0 to accommodate two lines
      final headerHeight = 120.0;
      final totalHeight = (_filteredRecords.length * rowHeight) + headerHeight;
      final totalWidth = 800.0;

      final image = await screenshotController.captureFromWidget(
        PngGenerator.generateTable(
          _filteredRecords,
          widget.isCelsius
        ),
        delay: const Duration(milliseconds: 300),
        targetSize: Size(totalWidth, totalHeight),
        pixelRatio: 2,
      );

      final output = await getTemporaryDirectory();
      final file = File('${output.path}/hourly_records.png');
      await file.writeAsBytes(image);

      if (isContextMounted) {
        await Share.shareXFiles([XFile(file.path)]);
        if (context.mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (isContextMounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating image: $e')),
        );
      }
    }
  }
}