import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'package:choy_ritur_golpo/app/utils/device_info.dart';

class FirestoreSync {
  FirestoreSync._internal();

  static final FirestoreSync _singleton = FirestoreSync._internal();

  factory FirestoreSync() => _singleton;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Returns a stable document id per device/platform.
  /// For now use FCM token as the doc id because it is what you will target.
  /// If token changes, we migrate by writing to the new doc id.
  Future<String?> _getFcmToken() async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to get FCM token: $e');
      }
      return null;
    }
  }

  /// Save or update the user's location with latest FCM token.
  Future<void> saveLocation({
    required double latitude,
    required double longitude,
    String? district,
    String? city,
  }) async {
    try {
      final token = await _getFcmToken();
      if (token == null) return;

      final data = <String, dynamic>{
        'fcm': token,
        'lat': latitude,
        'lon': longitude,
        if (district != null) 'district': district,
        if (city != null) 'city': city,
        'platform': Platform.isAndroid ? 'android' : Platform.isIOS ? 'ios' : 'other',
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _db.collection('users').doc(token).set(data, SetOptions(merge: true));

      if (kDebugMode) {
        print('✅ Firestore location synced');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to sync location to Firestore: $e');
      }
    }
  }

  /// Save or update the user's FCM token. Optionally pass last known lat/lon.
  Future<void> saveFcmToken({
    required String token,
    double? latitude,
    double? longitude,
    String? district,
    String? city,
  }) async {
    try {
      final data = <String, dynamic>{
        'fcm': token,
        if (latitude != null) 'lat': latitude,
        if (longitude != null) 'lon': longitude,
        if (district != null) 'district': district,
        if (city != null) 'city': city,
        'platform': Platform.isAndroid ? 'android' : Platform.isIOS ? 'ios' : 'other',
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _db.collection('users').doc(token).set(data, SetOptions(merge: true));

      if (kDebugMode) {
        print('✅ Firestore token synced');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to sync FCM token to Firestore: $e');
      }
    }
  }
}


