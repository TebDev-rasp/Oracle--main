import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'heat_index_monitor.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  
  if (message.data.containsKey('heat_index')) {
    final heatIndex = double.tryParse(message.data['heat_index']);
    if (heatIndex != null) {
      await HeatIndexMonitor.checkHeatIndex(heatIndex);
    }
  }
}