class WeatherDataPoint {
  final DateTime timestamp;
  final double heatIndex;
  final double temperature;
  final double humidity;

  WeatherDataPoint({
    required this.timestamp,
    required this.heatIndex,
    required this.temperature,
    required this.humidity,
  });
}