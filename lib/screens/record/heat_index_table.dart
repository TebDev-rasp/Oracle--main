import 'package:flutter/material.dart';
import 'package:oracle/screens/record/temperature_humidity_table.dart';
import 'package:oracle/widgets/page_indicator_overlay.dart';
import '../../models/hourly_record.dart';

class HeatIndexTable extends StatefulWidget {
  final bool isCelsius;
  final List<HourlyRecord> records;

  const HeatIndexTable({
    super.key,
    required this.isCelsius,
    required this.records,
  });

  @override
  State<HeatIndexTable> createState() => _HeatIndexTableState();
}

class _HeatIndexTableState extends State<HeatIndexTable> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  int _currentIndex = 0;
  bool _isUserSwiping = false;
  double _dragStartPosition = 0;
  double _dragDistance = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onHorizontalDragStart: (details) {
            setState(() {
              _isUserSwiping = true;
              _dragStartPosition = details.localPosition.dx;
            });
          },
          onHorizontalDragUpdate: (details) {
            if (_isUserSwiping) {
              final newDragDistance = details.localPosition.dx - _dragStartPosition;
              
              // Only allow drag in valid directions
              if ((_currentIndex == 0 && newDragDistance < 0) ||  // First page, can only swipe left
                  (_currentIndex == 1 && newDragDistance > 0) ||  // Second page, can only swipe right
                  (_currentIndex < 0 || _currentIndex > 1)) {     // Invalid states
                setState(() {
                  _dragDistance = newDragDistance;
                });
              }
            }
          },
          onHorizontalDragEnd: (details) {
            if (_isUserSwiping) {
              final velocity = details.primaryVelocity ?? 0;
              final distance = _dragDistance.abs();
              final threshold = MediaQuery.of(context).size.width * 0.2;

              if (distance > threshold || velocity.abs() > 300) {
                if (_dragDistance > 0 && _currentIndex == 1) {
                  // Swipe right on second page
                  _animateToPage(0);
                } else if (_dragDistance < 0 && _currentIndex == 0) {
                  // Swipe left on first page
                  _animateToPage(1);
                } else {
                  // Spring back animation if invalid swipe
                  _animationController
                    ..duration = const Duration(milliseconds: 150)
                    ..forward().then((_) => _animationController.reverse());
                }
              } else {
                // Spring back if threshold not met
                _animationController
                  ..duration = const Duration(milliseconds: 150)
                  ..forward().then((_) => _animationController.reverse());
              }
            }

            setState(() {
              _isUserSwiping = false;
              _dragDistance = 0;
            });
          },
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) => setState(() => _currentIndex = index),
            children: [
              _buildHeatIndexView(
                MediaQuery.of(context).size.width,
                MediaQuery.of(context).size.height,
              ),
              TemperatureHumidityTable(
                isCelsius: widget.isCelsius,
                records: widget.records,
              ),
            ],
          ),
        ),
        if (_isUserSwiping)
          PageIndicatorOverlay(
            currentIndex: _currentIndex,
            pageCount: 2,
          ),
      ],
    );
  }

  void _animateToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildHeatIndexView(double screenWidth, double screenHeight) {
    final tableWidth = screenWidth * 0.95;  // 95% of screen width
    final timeWidth = tableWidth * 0.28;    // 28% of table width
    final heatWidth = tableWidth * 0.32;    // 32% of table width
    final statusWidth = tableWidth * 0.40;  // 40% of table width
    
    final verticalPadding = screenHeight * 0.015;  // 1.5% of screen height
    final fontSize = screenWidth * 0.035;          // 3.5% of screen width
// 10% larger than content
// 0.2% of screen width
    
    return SizedBox(
      height: screenHeight * 0.72,
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
                    1: FixedColumnWidth(heatWidth),
                    2: FixedColumnWidth(statusWidth),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Theme.of(context).dividerColor,
                            width: screenWidth * 0.005, // 0.5% of screen width
                          ),
                        ),
                      ),
                      children: [
                        _buildHeaderCell('Time', fontSize, verticalPadding),
                        _buildHeaderCell('Heat Index', fontSize, verticalPadding),
                        _buildHeaderCell('Status', fontSize, verticalPadding),
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
                        1: FixedColumnWidth(heatWidth),
                        2: FixedColumnWidth(statusWidth),
                      },
                      children: widget.records.map((record) {
                        return _buildDataRow(
                          context, 
                          record, 
                          fontSize, 
                          verticalPadding,
                          timeWidth,
                          heatWidth,
                          statusWidth,
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


  // Helper method to build header cells
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

  // Helper method to build data rows
  TableRow _buildDataRow(
    BuildContext context,
    HourlyRecord record,
    double fontSize,
    double padding,
    double timeWidth,
    double heatWidth,
    double statusWidth,
  ) {
    final heatIndex = widget.isCelsius
        ? '${record.heatIndexCelsius.round()}°C'
        : '${record.heatIndexFahrenheit.round()}°F';

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
        Container(
          width: timeWidth,
          padding: EdgeInsets.symmetric(vertical: padding),
          decoration: _isCurrentTime(record.time)
              ? BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withAlpha(51),
                  borderRadius: BorderRadius.circular(4),
                )
              : null,
          child: Text(
            _formatTime(record.time),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: fontSize,
              color: _isCurrentTime(record.time)
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
              fontWeight: _isCurrentTime(record.time)
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ),
        Container(
          width: heatWidth,
          padding: EdgeInsets.symmetric(vertical: padding),
          child: Text(
            heatIndex,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: fontSize),
          ),
        ),
        Container(
          width: statusWidth,
          padding: EdgeInsets.symmetric(vertical: padding),
          child: Text(
            _getStatusFromHeatIndex(record.heatIndexCelsius),
            style: TextStyle(
              color: _getStatusColor(record.heatIndexCelsius),
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatTime(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '${hour12.toString().padLeft(2, '0')}:$minute $period';
  }

  bool _isCurrentTime(String recordTime) {
    final now = DateTime.now();
    final currentHour = now.hour;
    
    final parts = recordTime.split(':');
    final recordHour = int.parse(parts[0]);
    final recordMinute = int.parse(parts[1]);

    // Highlight the row if it matches the current hour and is at :00
    return recordHour == currentHour && recordMinute == 0;
  }

  Color _getStatusColor(double heatIndex) {
    if (heatIndex < 27) return Colors.green;
    if (heatIndex < 32) return Colors.orange;
    if (heatIndex < 41) return Colors.deepOrange;
    if (heatIndex < 54) return Colors.red;
    return Colors.purple;
  }

  String _getStatusFromHeatIndex(double heatIndex) {
    if (heatIndex < 27) return 'Normal';
    if (heatIndex < 32) return 'Caution';
    if (heatIndex < 41) return 'Extreme Caution';
    if (heatIndex < 54) return 'Danger';
    return 'Extreme Danger';
  }


}