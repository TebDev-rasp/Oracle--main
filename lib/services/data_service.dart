import '../services/heat_index_monitor.dart';

class DataService {
  // ...existing code...

  Future<void> processNewData(Map<String, dynamic> data) async {
    // ...existing data processing...

    // Check heat index and send notification if needed
    if (data.containsKey('heat_index')) {
      final heatIndex = double.tryParse(data['heat_index'].toString());
      if (heatIndex != null) {
        await HeatIndexMonitor.checkHeatIndex(heatIndex);
      }
    }

    // ...rest of existing code...
  }
}
