import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationBuilder {
  static const _channelId = 'weather_alerts';
  static const _channelName = 'Weather Alerts';
  static const _channelDescription = 'Important weather alerts and updates';

  static AndroidNotificationDetails _getAndroidDetails(RemoteMessage message) {
    // Get alert type from data payload
    final alertType = message.data['alert_type'] ?? 'default';
    
    // Configure importance and priority based on alert type
    var importance = Importance.high;
    var priority = Priority.high;
    
    if (alertType == 'severe') {
      importance = Importance.max;
      priority = Priority.max;
    }

    return AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: importance,
      priority: priority,
      enableLights: true,
      ledColor: _getAlertColor(alertType),
      ledOnMs: 1000,
      ledOffMs: 500,
      icon: '@mipmap/ic_launcher',
      // Use different icons based on alert type
      styleInformation: message.notification?.android?.imageUrl != null
          ? BigPictureStyleInformation(
              FilePathAndroidBitmap(message.notification!.android!.imageUrl!),
              hideExpandedLargeIcon: true,
            )
          : const BigTextStyleInformation(''),
      // Custom sound based on alert type
      sound: RawResourceAndroidNotificationSound(_getAlertSound(alertType)),
    );
  }

  static DarwinNotificationDetails _getIOSDetails(RemoteMessage message) {
    final alertType = message.data['alert_type'] ?? 'default';
    
    return DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: _getAlertSound(alertType),
      // Customize based on alert type
      interruptionLevel: _getInterruptionLevel(alertType),
    );
  }

  static NotificationDetails buildNotificationDetails(RemoteMessage message) {
    return NotificationDetails(
      android: _getAndroidDetails(message),
      iOS: _getIOSDetails(message),
    );
  }

  // Helper methods for customization
  static Color _getAlertColor(String alertType) {
    switch (alertType.toLowerCase()) {
      case 'severe':
        return const Color(0xFFFF0000); // Red
      case 'warning':
        return const Color(0xFFFFA500); // Orange
      case 'alert':
        return const Color(0xFFFFD700); // Amber
      default:
        return const Color(0xFF2196F3); // Blue
    }
  }

  static String _getAlertSound(String alertType) {
    switch (alertType.toLowerCase()) {
      case 'severe':
        return 'severe_alert';
      case 'warning':
        return 'warning_alert';
      default:
        return 'notification_sound';
    }
  }

  static InterruptionLevel _getInterruptionLevel(String alertType) {
    switch (alertType.toLowerCase()) {
      case 'severe':
        return InterruptionLevel.timeSensitive;
      case 'warning':
        return InterruptionLevel.active;
      default:
        return InterruptionLevel.passive;
    }
  }
}