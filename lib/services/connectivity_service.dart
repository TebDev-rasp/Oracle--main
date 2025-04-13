import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

enum ConnectionStatus { online, offline, checking }

class ConnectivityService extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _subscription;
  ConnectionStatus _lastStatus = ConnectionStatus.checking;
  bool _isInitialized = false;

  // New field to track user preference for alerts
  bool _showConnectionAlerts = true;
  static const String _prefsKey = 'show_connection_alerts';
  SharedPreferences? _prefs;

  bool get hasConnection => _lastStatus == ConnectionStatus.online;
  bool get isInitialized => _isInitialized;
  ConnectionStatus get lastStatus => _lastStatus;
  bool get showConnectionAlerts => _showConnectionAlerts;

  ConnectivityService() {
    _loadPreferences();
    _initConnectivity();
  }

  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _showConnectionAlerts = _prefs?.getBool(_prefsKey) ?? true;
    notifyListeners();
  }

  Future<void> _initConnectivity() async {
    try {
      await checkConnection();

      // Listen for connectivity changes
      _subscription = _connectivity.onConnectivityChanged.listen((_) {
        checkConnection();
      });

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _lastStatus = ConnectionStatus.offline;
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> checkConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();

      if (result.isEmpty || result.every((r) => r == ConnectivityResult.none)) {
        _updateStatus(ConnectionStatus.offline);
      } else {
        // Additional validation to handle cases where device is connected
        // to WiFi but has no internet access
        try {
          final response = await Future.delayed(
            const Duration(seconds: 1),
            () => true, // Replace with actual connectivity check if needed
          );
          _updateStatus(
              response ? ConnectionStatus.online : ConnectionStatus.offline);
        } catch (_) {
          _updateStatus(ConnectionStatus.offline);
        }
      }
    } catch (_) {
      _updateStatus(ConnectionStatus.offline);
    }
  }

  void _updateStatus(ConnectionStatus status) {
    if (_lastStatus != status) {
      bool wasOffline = _lastStatus == ConnectionStatus.offline;
      _lastStatus = status;

      // Reset alerts when connection is restored from offline state
      if (wasOffline &&
          status == ConnectionStatus.online &&
          !_showConnectionAlerts) {
        setShowConnectionAlerts(true);
      }

      notifyListeners();
    }
  }

  // Method to set user preference
  Future<void> setShowConnectionAlerts(bool value) async {
    if (_showConnectionAlerts != value) {
      _showConnectionAlerts = value;
      await _prefs?.setBool(_prefsKey, value);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
