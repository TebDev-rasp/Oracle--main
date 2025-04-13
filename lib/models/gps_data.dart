class GpsData {
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  GpsData({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  factory GpsData.fromString(String data) {
    final coordinates = data.split(',');
    if (coordinates.length != 2) {
      throw FormatException('Invalid GPS data format');
    }

    return GpsData(
      latitude: double.parse(coordinates[0]),
      longitude: double.parse(coordinates[1]),
      timestamp: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory GpsData.fromJson(Map<String, dynamic> json) {
    return GpsData(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  String toString() {
    return 'GPS Location: ($latitude, $longitude) at ${timestamp.toLocal()}';
  }
}