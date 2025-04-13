import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:logging/logging.dart';
import '../services/heat_index_data_service.dart';
import '../models/weather_data_point.dart';  // Updated import
import 'dart:async';

class HeatIndexChart extends StatefulWidget {
  const HeatIndexChart({super.key});

  @override
  State<HeatIndexChart> createState() => _HeatIndexChartState();
}

class _HeatIndexChartState extends State<HeatIndexChart> {
  static final _logger = Logger('HeatIndexChart');
  late TransformationController _transformationController;
  List<FlSpot> _heatIndexSpots = [];
  List<FlSpot> _temperatureSpots = [];
  StreamSubscription<List<WeatherDataPoint>>? _realtimeSubscription;

  double _minX = 0;
  double _maxX = 23; // Changed from 24 to 23
  double _minY = 20; // Changed from 25 to 20
  double _maxY = 50;
  double _zoomLevel = 1.0;
  double _initialZoomLevel = 1.0;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _loadHeatIndexData();
    _subscribeToRealtimeUpdates();
  }

  Future<void> _loadHeatIndexData() async {
    try {
      setState(() {});

      final points = await WeatherDataService.get24HourHistory();
      _logger.info('Loaded ${points.length} data points');

      if (points.isEmpty) {
        throw Exception('No data available');
      }

      setState(() {
        _heatIndexSpots = points.map((point) {
          final value = point.heatIndex;
          return FlSpot(point.timestamp.hour.toDouble(), value);
        }).toList();

        _temperatureSpots = points.map((point) {
          final value = point.temperature;
          return FlSpot(point.timestamp.hour.toDouble(), value);
        }).toList();

        _heatIndexSpots.sort((a, b) => a.x.compareTo(b.x));
        _temperatureSpots.sort((a, b) => a.x.compareTo(b.x));
      });
      
      _logger.info('Spots created: Heat Index: ${_heatIndexSpots.length}, Temperature: ${_temperatureSpots.length}');
    } catch (e) {
      _logger.severe('Error loading weather data: $e');
      setState(() {});
    }
  }

  void _subscribeToRealtimeUpdates() {
    _realtimeSubscription?.cancel();
    
    _realtimeSubscription = WeatherDataService.getRealtimeWeatherData().listen(
      (dataPoints) {
        if (!mounted) return;
        
        setState(() {
          _heatIndexSpots.clear();
          _temperatureSpots.clear();
          
          for (var point in dataPoints) {
            // Round values to integers
            final heatIndexValue = point.heatIndex.round().toDouble();
            final temperatureValue = point.temperature.round().toDouble();
                
            _heatIndexSpots.add(FlSpot(
              point.timestamp.hour.toDouble(),
              heatIndexValue
            ));
            
            _temperatureSpots.add(FlSpot(
              point.timestamp.hour.toDouble(),
              temperatureValue
            ));
          }
          
          _heatIndexSpots.sort((a, b) => a.x.compareTo(b.x));
          _temperatureSpots.sort((a, b) => a.x.compareTo(b.x));
          
          _logger.info('Updated chart with ${_heatIndexSpots.length} data points');
        });
      },
      onError: (error) {
        _logger.severe('Error in real-time updates: $error');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating chart: $error')),
          );
        }
      },
      cancelOnError: false,
    );
  }

  String _formatHourLabel(int hour) {
    if (hour == 0) return '12 AM';
    if (hour == 12) return '12 PM';
    return hour > 12 
        ? '${(hour - 12)} PM'
        : '$hour AM';
  }


  String _formatTemperature(int value) {
    return '$value°C';
  }

  void _handleZoom(double scale) {
    setState(() {
      _zoomLevel = scale.clamp(1.0, 3.0);
      
      final centerX = (_minX + _maxX) / 2;
      final centerY = (_minY + _maxY) / 2;
      
      final xRange = 23 / _zoomLevel;
      final yRange = 30 / _zoomLevel; // Changed from 25 to 30 to match new range
      
      _minX = centerX - (xRange / 2);
      _maxX = centerX + (xRange / 2);
      _minY = centerY - (yRange / 2);
      _maxY = centerY + (yRange / 2);
      
      _minX = _minX.clamp(0.0, 22.0);
      _maxX = _maxX.clamp(1.0, 23.0);
      _minY = _minY.clamp(20.0, 45.0); // Changed from 25.0 to 20.0
      _maxY = _maxY.clamp(25.0, 50.0); // Changed from 30.0 to 25.0
    });
  }

  void _handlePanStart(FlPanStartEvent event) {
    _initialZoomLevel = _zoomLevel;
  }

  void _handlePanEnd(FlPanEndEvent event) {
    // Reset or update zoom state if needed
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildChartControls(),
        _buildChart(),
      ],
    );
  }

  Widget _buildChartControls() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 12.0,
        right: 12.0,
        top: 8.0,
        bottom: 24.0  // Increased from 8.0 to 24.0
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start, // Changed from spaceBetween to start
        children: [
          Row(
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE60049),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text('RealFeel',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0BB4FF),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text('Temperature',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    if (_heatIndexSpots.isEmpty || _temperatureSpots.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return GestureDetector(
      onScaleStart: (_) {
        _initialZoomLevel = _zoomLevel;
      },
      onScaleUpdate: (details) {
        setState(() {
          _handleZoom(_initialZoomLevel * details.scale);
        });
      },
      child: AspectRatio(
        aspectRatio: 1.3, // Changed from 1.7 to make chart taller
        child: Padding(
          padding: const EdgeInsets.only(right: 18, left: 12),
          child: LineChart(
            LineChartData(
              minX: _minX,
              maxX: _maxX,
              minY: _minY, // Changed to match new minimum
              maxY: _maxY,
              clipData: FlClipData.all(),
              gridData: FlGridData(show: true),
              rangeAnnotations: RangeAnnotations(),
              lineTouchData: LineTouchData(
                enabled: true,
                touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
                  if (event is FlPanStartEvent) {
                    _handlePanStart(event);
                  } else if (event is FlPanEndEvent) {
                    _handlePanEnd(event);
                  }
                },
                handleBuiltInTouches: true,
                touchSpotThreshold: 20,
                touchTooltipData: LineTouchTooltipData(
                  tooltipRoundedRadius: 4,  // Reduced from 8
                  tooltipPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),  // Reduced padding
                  tooltipMargin: 8,  // Reduced from 16
                  getTooltipItems: (List<LineBarSpot> spots) {
                    return spots.map((spot) {
                      final hour = spot.x.toInt();
                      final value = '${spot.y.round()}°C'; // Changed from toStringAsFixed(1)
                      return LineTooltipItem(
                        '${_formatHourLabel(hour)}\n$value',
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList();
                  },
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                ),
              ),
              lineBarsData: [
                // Heat Index Line
                LineChartBarData(
                  spots: _heatIndexSpots.where((spot) => spot.y > 0).toList(),
                  isCurved: false,  // Changed to false
                  color: const Color(0xFFE60049),  // Changed from Colors.orange
                  barWidth: 2,
                  // Removed curveSmoothness
                  // Removed preventCurveOverShooting
                  // Removed preventCurveOvershootingThreshold
                  dotData: FlDotData(
                    show: true,
                    checkToShowDot: (spot, barData) {
                      final hour = spot.x.toInt();
                      return hour % 4 == 0 || hour == 23;
                    },
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 2.0,  // Reduced from 2.5
                        color: const Color(0xFFE60049),  // Changed from Colors.orange
                        strokeWidth: 1.0,  // Reduced from 1.5
                        strokeColor: const Color(0xFFE60049),  // Changed from Colors.orange
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: false, // Changed from true to false to remove shadow
                  ),
                  isStrokeCapRound: true,
                  isStrokeJoinRound: true,
                ),
                // Temperature Line
                LineChartBarData(
                  spots: _temperatureSpots.where((spot) => spot.y > 0).toList(),
                  isCurved: false,  // Changed to false
                  color: const Color(0xFF0BB4FF),  // Changed from Colors.blue
                  barWidth: 2,
                  // Removed curveSmoothness
                  // Removed preventCurveOverShooting
                  // Removed preventCurveOvershootingThreshold
                  dotData: FlDotData(
                    show: true,
                    checkToShowDot: (spot, barData) {
                      final hour = spot.x.toInt();
                      return hour % 4 == 0 || hour == 23;
                    },
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 2.0,  // Reduced from 2.5
                        color: const Color(0xFF0BB4FF),  // Changed from Colors.blue
                        strokeWidth: 1.0,  // Reduced from 1.5
                        strokeColor: const Color(0xFF0BB4FF),  // Changed from Colors.blue
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: false, // Changed from true to false to remove shadow
                  ),
                  isStrokeCapRound: true,
                  isStrokeJoinRound: true,
                ),
              ],
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 4,
                    reservedSize: 22,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      int hour = value.toInt();
                      // Change the condition to include 23
                      if (hour % 4 != 0 && hour != 23) return const Text('');
                      return Text(
                        _formatHourLabel(hour),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.normal,
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 52,
                    interval: 5,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      final List<int> showValues = [20, 25, 30, 35, 40, 45, 50];  // Added 20 to Y-axis values
                      if (!showValues.contains(value.toInt())) return const Text('');
                      
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          _formatTemperature(value.toInt()),  // This formats the number and adds °C
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
            ),
            duration: const Duration(milliseconds: 500),  // Increased animation duration
            curve: Curves.easeInOutCubic,  // Changed to more smooth curve
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    _transformationController.dispose();
    super.dispose();
  }
}