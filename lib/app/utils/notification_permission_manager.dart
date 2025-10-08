import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationPermissionManager {
  static const String _lastAskTimeKey = 'notification_last_ask_time';
  static const String _askCountKey = 'notification_ask_count';
  static const Duration _waitAfterDenial = Duration(days: 3); // Wait 3 days before asking again after denial
  
  static Future<bool> shouldAskForPermission() async {
    final prefs = await SharedPreferences.getInstance();
    final lastAskTime = DateTime.fromMillisecondsSinceEpoch(
      prefs.getInt(_lastAskTimeKey) ?? 0
    );
    
    // Check current permission status
    final status = await FirebaseMessaging.instance.getNotificationSettings();
    
    // Never ask again if permission is granted
    if (status.authorizationStatus == AuthorizationStatus.authorized ||
        status.authorizationStatus == AuthorizationStatus.provisional) {
      return false;
    }
    
    // If permission was denied (not permanently), check if enough time has passed
    if (status.authorizationStatus == AuthorizationStatus.denied) {
      final timeSinceLastAsk = DateTime.now().difference(lastAskTime);
      return timeSinceLastAsk >= _waitAfterDenial;
    }
    
    // For not determined status, we can ask
    return status.authorizationStatus == AuthorizationStatus.notDetermined;
  }
  
  static Future<void> recordAskAttempt() async {
    final prefs = await SharedPreferences.getInstance();
    final currentCount = prefs.getInt(_askCountKey) ?? 0;
    await prefs.setInt(_askCountKey, currentCount + 1);
    await prefs.setInt(_lastAskTimeKey, DateTime.now().millisecondsSinceEpoch);
  }
  
  static Future<AuthorizationStatus> requestPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    await recordAskAttempt();
    return settings.authorizationStatus;
  }
  
  static Future<void> resetPermissionState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastAskTimeKey);
    await prefs.remove(_askCountKey);
  }
}