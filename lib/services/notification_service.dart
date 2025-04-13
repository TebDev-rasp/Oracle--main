import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:oracle/services/device_tracking_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  static final _logger = Logger('NotificationService');
  static bool _isInitialized = false;

  // Single flag to track if notification was shown this session

  // Add these new fields at the top of the class
  static const Duration _notificationCooldown = Duration(minutes: 30);
  static const double _minimumChangeThreshold = 2.0;

  DateTime? _lastNotificationTime;
  double? _lastNotifiedHeatIndex;
  String? _lastNotificationLevel;

  // Singleton factory constructor
  factory NotificationService() {
    return _instance;
  }

  // Private constructor
  NotificationService._internal();

  Future<void> initialize() async {
    if (_isInitialized) {
      _logger.info('Notification service already initialized');
      return;
    }

    // Reset notification state on initialization

    _logger.info('Initializing notification service');

    try {
      await AwesomeNotifications().initialize(
        'resource://drawable/ic_notification',
        [
          NotificationChannel(
            channelKey: 'heat_index_channel',
            channelName: 'Heat Index Alerts',
            channelDescription: 'Notifications for dangerous heat index levels',
            defaultColor: Colors.transparent,
            ledColor: Colors.transparent,
            importance: NotificationImportance.High,
            enableVibration: true,
            criticalAlerts: true,
            playSound: false, // Disable sound
            enableLights: true,
            groupKey: 'heat_index_alerts',
            groupSort: GroupSort.Desc,
            groupAlertBehavior: GroupAlertBehavior.Children,
          ),
          // Add new channel for login notifications
          NotificationChannel(
            channelKey: 'login_alerts_channel',
            channelName: 'Login Security Alerts',
            channelDescription: 'Notifications for account login activities',
            defaultColor: Colors.blue,
            ledColor: Colors.blue,
            importance: NotificationImportance.High,
            enableVibration: true,
            playSound: true,
            groupKey: 'login_alerts',
          ),
        ],
        debug: true,
      );

      await requestPermissions();

      AwesomeNotifications().setListeners(
        onActionReceivedMethod: _onActionReceivedMethod,
        onNotificationCreatedMethod: _onNotificationCreatedMethod,
        onNotificationDisplayedMethod: _onNotificationDisplayedMethod,
      );

      _isInitialized = true;
      _logger.info('Notification service initialized successfully');
    } catch (e) {
      _logger.severe('Failed to initialize notification service: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    _logger
        .info('Notification action received: ${receivedAction.buttonKeyInput}');
  }

  @pragma('vm:entry-point')
  static Future<void> _onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    _logger.info('Notification created: ${receivedNotification.title}');
  }

  @pragma('vm:entry-point')
  static Future<void> _onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    _logger.info('Notification displayed: ${receivedNotification.title}');
  }

  Future<void> requestPermissions() async {
    _logger.info('Requesting notification permissions');

    // Check if permissions are already granted
    final bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      // Show dialog to request permissions
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }

    // Double check if permissions were granted
    final afterRequest = await AwesomeNotifications().isNotificationAllowed();
    _logger.info('Notification permissions granted: $afterRequest');
  }

  Future<void> showHeatIndexNotification(double heatIndex) async {
    _logger.info('Evaluating heat index notification for: $heatIndex');

    // Check cooldown period
    if (_lastNotificationTime != null) {
      final timeSinceLastNotification =
          DateTime.now().difference(_lastNotificationTime!);
      if (timeSinceLastNotification < _notificationCooldown) {
        // Check if change is significant enough
        if (_lastNotifiedHeatIndex != null) {
          final change = (heatIndex - _lastNotifiedHeatIndex!).abs();
          if (change < _minimumChangeThreshold) {
            _logger.info(
                'Change in heat index ($change°C) below threshold, skipping notification');
            return;
          }
        }
      }
    }

    // Determine notification level
    String currentLevel;
    if (heatIndex >= 54) {
      currentLevel = 'EXTREME_DANGER';
    } else if (heatIndex >= 41) {
      currentLevel = 'DANGER';
    } else if (heatIndex >= 32) {
      currentLevel = 'EXTREME_CAUTION';
    } else if (heatIndex >= 27) {
      currentLevel = 'CAUTION';
    } else {
      currentLevel = 'NORMAL';
    }

    // Check if notification level has changed
    if (_lastNotificationLevel == currentLevel &&
        _lastNotifiedHeatIndex != null &&
        (heatIndex - _lastNotifiedHeatIndex!).abs() < _minimumChangeThreshold) {
      _logger.info(
          'Same notification level and change below threshold, skipping notification');
      return;
    }

    // Original notification logic
    String title;
    String body;
    Color? backgroundColor;
    List<NotificationActionButton> actionButtons = [];

    if (heatIndex >= 54) {
      title = '🟣 Extreme Danger';
      body = 'Heat index: ${heatIndex.round()}°C\n'
          '• Heat stroke imminent\n'
          '• Avoid outdoor activities\n'
          '• Seek immediate shelter';
      backgroundColor = Colors.purple[900];
      actionButtons = [
        NotificationActionButton(
          key: 'EMERGENCY',
          label: 'Emergency Numbers',
        ),
      ];
    } else if (heatIndex >= 41) {
      title = '🔴 Danger';
      body = 'Heat index: ${heatIndex.round()}°C\n'
          '• Heat cramps/exhaustion likely\n'
          '• Limit outdoor exposure\n'
          '• Stay hydrated';
      backgroundColor = Colors.red[700];
    } else if (heatIndex >= 32) {
      title = '🟠 Extreme Caution';
      body = 'Heat index: ${heatIndex.round()}°C\n'
          '• Heat exhaustion possible\n'
          '• Take frequent breaks\n'
          '• Drink plenty of water';
      backgroundColor = Colors.orange[700];
    } else if (heatIndex >= 27) {
      title = '🟡 Caution';
      body = 'Heat index: ${heatIndex.round()}°C\n'
          '• Fatigue possible\n'
          '• Use caution with outdoor activities';
      backgroundColor = Colors.yellow[700];
    } else {
      _logger.info('Normal heat index: $heatIndex, no notification needed');
      return;
    }

    try {
      // Create a unique notification ID based on date and heat index
      final int notificationId =
          DateTime.now().day * 1000000 + (heatIndex * 100).round();

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: notificationId,
          channelKey: 'heat_index_channel',
          title: title,
          body: body,
          icon: 'resource://drawable/ic_notification',
          notificationLayout: NotificationLayout.BigText,
          criticalAlert: heatIndex >= 41,
          wakeUpScreen: heatIndex >= 41,
          backgroundColor: backgroundColor,
          category: NotificationCategory.Alarm,
          groupKey: 'heat_index_alerts',
          showWhen: true,
          displayOnForeground: true,
          displayOnBackground: true,
        ),
        actionButtons: actionButtons,
      );

      // Update tracking variables
      _lastNotificationTime = DateTime.now();
      _lastNotifiedHeatIndex = heatIndex;
      _lastNotificationLevel = currentLevel;
      _logger.info(
          'Heat index notification shown successfully. Level: $currentLevel');
    } catch (e) {
      _logger.severe('Failed to show notification: $e');
    }
  }

  // Add this method to reset the cooldown if needed
  void resetNotificationCooldown() {
    _lastNotificationTime = null;
    _lastNotifiedHeatIndex = null;
    _lastNotificationLevel = null;
  }

  // Add method to show login notification
  Future<void> showLoginNotification({
    required String deviceInfo,
    String? location,
    required DateTime loginTime,
  }) async {
    if (!_isInitialized) {
      _logger.warning('Notification service not initialized');
      return;
    }

    try {
      final bool isAllowed =
          await AwesomeNotifications().isNotificationAllowed();
      if (!isAllowed) {
        _logger.warning('Notifications not allowed');
        return;
      }

      final notificationId =
          DateTime.now().millisecondsSinceEpoch.remainder(100000);

      final locationText = location != null ? ' from $location' : '';
      final timeString =
          '${loginTime.hour}:${loginTime.minute.toString().padLeft(2, '0')}';

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: notificationId,
          channelKey: 'login_alerts_channel',
          title: 'New Login Detected',
          body:
              'Your account was accessed$locationText on $deviceInfo at $timeString',
          notificationLayout: NotificationLayout.Default,
          category: NotificationCategory.Alarm,
          wakeUpScreen: true,
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'REVIEW',
            label: 'Review Activity',
          ),
          NotificationActionButton(
            key: 'TRUST',
            label: 'Trust Device',
          ),
        ],
      );

      _logger.info('Login notification shown successfully');
    } catch (e) {
      _logger.severe('Failed to show login notification: $e');
    }
  }

  // Add handler for the "Trust Device" action
  Future<void> handleTrustDeviceAction(ReceivedAction action) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Mark this device as trusted
        final deviceTrackingService = DeviceTrackingService();
        await deviceTrackingService.markAsPrimaryDevice(currentUser.uid);

        // Show confirmation
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
            channelKey: 'login_alerts_channel',
            title: 'Device Trusted',
            body:
                'This device has been marked as trusted and won\'t trigger login alerts',
            notificationLayout: NotificationLayout.Default,
          ),
        );
      }
    } catch (e) {
      _logger.severe('Error handling trust device action: $e');
    }
  }
}
