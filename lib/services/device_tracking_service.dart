import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class DeviceTrackingService {
  static final _logger = Logger('DeviceTrackingService');
  final _database = FirebaseDatabase.instance.ref();
  final _deviceInfo = DeviceInfoPlugin();

  // Device fingerprint key in shared preferences
  static const String _deviceFingerprintKey = 'device_fingerprint';

  // Get current device information
  Future<Map<String, dynamic>> getCurrentDeviceInfo() async {
    final deviceData = <String, dynamic>{};

    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        deviceData['type'] = 'android';
        deviceData['model'] = androidInfo.model;
        deviceData['manufacturer'] = androidInfo.manufacturer;
        deviceData['id'] = androidInfo.id;
        deviceData['androidVersion'] = androidInfo.version.release;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        deviceData['type'] = 'ios';
        deviceData['model'] = iosInfo.model;
        deviceData['name'] = iosInfo.name;
        deviceData['systemName'] = iosInfo.systemName;
        deviceData['systemVersion'] = iosInfo.systemVersion;
      }

      // Add app version
      final packageInfo = await PackageInfo.fromPlatform();
      deviceData['appVersion'] = packageInfo.version;
      deviceData['appBuild'] = packageInfo.buildNumber;

      return deviceData;
    } catch (e) {
      _logger.warning('Error getting device info: $e');
      return {'type': 'unknown', 'model': 'unknown'};
    }
  }

  // Generate a device fingerprint
  Future<String> getDeviceFingerprint() async {
    final prefs = await SharedPreferences.getInstance();
    String? fingerprint = prefs.getString(_deviceFingerprintKey);

    if (fingerprint != null) {
      return fingerprint;
    }

    // Create a new fingerprint
    final deviceInfo = await getCurrentDeviceInfo();
    final fingerprintData = json.encode(deviceInfo);
    fingerprint = sha256.convert(utf8.encode(fingerprintData)).toString();

    // Save the fingerprint
    await prefs.setString(_deviceFingerprintKey, fingerprint);
    return fingerprint;
  }

  // Check if this is a new device
  Future<bool> isNewDevice(String userId) async {
    try {
      final fingerprint = await getDeviceFingerprint();
      final snapshot = await _database
          .child('users')
          .child(userId)
          .child('knownDevices')
          .child(fingerprint)
          .get();

      return !snapshot.exists;
    } catch (e) {
      _logger.severe('Error checking device status: $e');
      // Default to false to avoid excessive notifications if there's an error
      return false;
    }
  }

  // Save this device as known
  Future<void> saveDeviceAsKnown(String userId) async {
    try {
      final fingerprint = await getDeviceFingerprint();
      final deviceInfo = await getCurrentDeviceInfo();

      await _database
          .child('users')
          .child(userId)
          .child('knownDevices')
          .child(fingerprint)
          .set({
        'deviceInfo': deviceInfo,
        'firstSeen': ServerValue.timestamp,
        'lastSeen': ServerValue.timestamp,
      });

      _logger.info('Device saved as known: $fingerprint');
    } catch (e) {
      _logger.severe('Error saving device: $e');
    }
  }

  // Update last seen timestamp for this device
  Future<void> updateDeviceLastSeen(String userId) async {
    try {
      final fingerprint = await getDeviceFingerprint();

      await _database
          .child('users')
          .child(userId)
          .child('knownDevices')
          .child(fingerprint)
          .update({
        'lastSeen': ServerValue.timestamp,
      });
    } catch (e) {
      _logger.warning('Error updating device last seen: $e');
    }
  }

  // Get approximate location
  Future<String?> getApproximateLocation() async {
    try {
      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      // Request permission
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 5),
      );

      // Reverse geocode
      final placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        if (place.locality != null && place.locality!.isNotEmpty) {
          return place.locality;
        } else if (place.administrativeArea != null) {
          return place.administrativeArea;
        }
      }

      return null;
    } catch (e) {
      _logger.info('Could not determine location: $e');
      return null;
    }
  }

  // Format device info for display
  String formatDeviceInfoForDisplay(Map<String, dynamic> deviceInfo) {
    final type = deviceInfo['type'] ?? 'unknown';
    final model = deviceInfo['model'] ?? 'device';

    if (type == 'android') {
      final manufacturer = deviceInfo['manufacturer'] ?? '';
      return '$manufacturer $model';
    } else if (type == 'ios') {
      return 'iPhone $model';
    }

    return 'Unknown device';
  }

  // Check if this device is considered the user's primary device
  Future<bool> isPrimaryDevice(String userId) async {
    try {
      final fingerprint = await getDeviceFingerprint();
      final snapshot = await _database
          .child('users')
          .child(userId)
          .child('knownDevices')
          .child(fingerprint)
          .child('isPrimary')
          .get();

      return snapshot.exists && snapshot.value == true;
    } catch (e) {
      _logger.severe('Error checking primary device status: $e');
      return false;
    }
  }

  // Mark this device as primary
  Future<void> markAsPrimaryDevice(String userId) async {
    try {
      final fingerprint = await getDeviceFingerprint();

      await _database
          .child('users')
          .child(userId)
          .child('knownDevices')
          .child(fingerprint)
          .update({
        'isPrimary': true,
        'markedPrimaryAt': ServerValue.timestamp,
      });

      _logger.info('Device marked as primary: $fingerprint');
    } catch (e) {
      _logger.severe('Error marking device as primary: $e');
    }
  }

  // Get list of devices for the user
  Future<List<Map<String, dynamic>>> getUserDevices(String userId) async {
    try {
      final snapshot = await _database
          .child('users')
          .child(userId)
          .child('knownDevices')
          .get();

      if (!snapshot.exists || snapshot.value == null) {
        return [];
      }

      final data = snapshot.value as Map<dynamic, dynamic>;
      final devices = <Map<String, dynamic>>[];

      data.forEach((key, value) {
        if (value is Map) {
          final deviceData = Map<String, dynamic>.from(value);
          deviceData['id'] = key;
          devices.add(deviceData);
        }
      });

      return devices;
    } catch (e) {
      _logger.severe('Error getting user devices: $e');
      return [];
    }
  }

  // Add information about the login type
  Future<void> updateDeviceWithLoginInfo(
      String userId, String loginMethod) async {
    try {
      final fingerprint = await getDeviceFingerprint();

      await _database
          .child('users')
          .child(userId)
          .child('knownDevices')
          .child(fingerprint)
          .update({
        'lastLoginMethod': loginMethod,
        'lastLoginTime': ServerValue.timestamp,
      });
    } catch (e) {
      _logger.warning('Error updating device login info: $e');
    }
  }
}
