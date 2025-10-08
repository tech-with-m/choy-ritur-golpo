import 'package:hive/hive.dart';
import 'hive_db.dart';
import 'hive_globals.dart';

class HiveMigrationHelper {
  // Weather Cards operations
  static List<WeatherCard> getAllWeatherCards() {
    return weatherCardBox.values.toList()
      ..sort((a, b) => (a.index ?? 0).compareTo(b.index ?? 0));
  }
  
  static void saveWeatherCard(WeatherCard card) {
    // Generate a unique key based on location and city
    final key = _generateWeatherCardKey(card);
    weatherCardBox.put(key, card);
  }
  
  static void deleteWeatherCard(WeatherCard card) {
    final key = _generateWeatherCardKey(card);
    weatherCardBox.delete(key);
  }
  
  static String _generateWeatherCardKey(WeatherCard card) {
    // Use city and district as primary key, fallback to coordinates
    if (card.city != null && card.district != null) {
      return '${card.city}_${card.district}';
    } else if (card.lat != null && card.lon != null) {
      // Round coordinates to avoid precision issues
      final lat = (card.lat! * 1000).round() / 1000;
      final lon = (card.lon! * 1000).round() / 1000;
      return '${lat}_${lon}';
    } else {
      // Fallback to timestamp-based key
      return 'card_${DateTime.now().millisecondsSinceEpoch}';
    }
  }
  
  static List<WeatherCard> getWeatherCardsOlderThan(DateTime expiry) {
    return weatherCardBox.values
        .where((card) => card.timestamp != null && card.timestamp!.isBefore(expiry))
        .toList();
  }
  
  // Main Weather Cache operations
  static MainWeatherCache? getMainWeatherCache() {
    try {
      print('🔄 HiveMigrationHelper: Getting main weather cache');
      final cache = mainWeatherCacheBox.get('main');
      if (cache != null) {
        print('✅ Main weather cache retrieved successfully');
        print('📊 Retrieved time entries: ${cache.time?.length}');
        print('📊 Retrieved timezone: ${cache.timezone}');
        print('📊 Retrieved timestamp: ${cache.timestamp}');
      } else {
        print('⚠️ Main weather cache is null - no cached data found');
      }
      return cache;
    } catch (e) {
      print('❌ Error getting main weather cache: $e');
      return null;
    }
  }
  
  static void saveMainWeatherCache(MainWeatherCache cache) {
    try {
      print('🔄 HiveMigrationHelper: About to save weather cache');
      print('📊 Cache time entries: ${cache.time?.length}');
      print('📊 Cache timezone: ${cache.timezone}');
      print('📊 Cache timestamp: ${cache.timestamp}');
      
      mainWeatherCacheBox.put('main', cache);
      print('✅ Main weather cache saved successfully to Hive');
      
      // Immediate verification
      final verification = mainWeatherCacheBox.get('main');
      if (verification != null) {
        print('✅ Immediate verification successful - cache exists in Hive');
        print('📊 Verified time entries: ${verification.time?.length}');
      } else {
        print('❌ Immediate verification failed - cache not found in Hive');
      }
    } catch (e) {
      print('❌ Error saving main weather cache: $e');
      rethrow;
    }
  }
  
  static void deleteMainWeatherCache() {
    try {
      mainWeatherCacheBox.delete('main');
    } catch (e) {
      print('❌ Error deleting main weather cache: $e');
    }
  }
  
  static bool hasMainWeatherCache() {
    try {
      return mainWeatherCacheBox.get('main') != null;
    } catch (e) {
      print('❌ Error checking main weather cache: $e');
      return false;
    }
  }
  
  static void deleteExpiredMainWeatherCache(DateTime expiry) {
    try {
      final cache = mainWeatherCacheBox.get('main');
      if (cache?.timestamp != null && cache!.timestamp!.isBefore(expiry)) {
        mainWeatherCacheBox.delete('main');
      }
    } catch (e) {
      print('❌ Error deleting expired main weather cache: $e');
    }
  }
  
  // Location Cache operations
  static LocationCache? getLocationCache() {
    try {
      print('🔄 HiveMigrationHelper: Getting location cache');
      final cache = locationCacheBox.get('main');
      if (cache != null) {
        print('✅ Location cache retrieved successfully');
        print('📊 Retrieved location: ${cache.city}, ${cache.district}');
        print('📊 Retrieved coordinates: ${cache.lat}, ${cache.lon}');
      } else {
        print('⚠️ Location cache is null - no cached data found');
      }
      return cache;
    } catch (e) {
      print('❌ Error getting location cache: $e');
      return null;
    }
  }
  
  static void saveLocationCache(LocationCache cache) {
    try {
      print('🔄 HiveMigrationHelper: About to save location cache');
      print('📊 Location: ${cache.city}, ${cache.district}');
      print('📊 Coordinates: ${cache.lat}, ${cache.lon}');
      
      locationCacheBox.put('main', cache);
      print('✅ Location cache saved successfully to Hive');
      
      // Immediate verification
      final verification = locationCacheBox.get('main');
      if (verification != null) {
        print('✅ Immediate verification successful - location cache exists in Hive');
        print('📊 Verified location: ${verification.city}, ${verification.district}');
      } else {
        print('❌ Immediate verification failed - location cache not found in Hive');
      }
    } catch (e) {
      print('❌ Error saving location cache: $e');
      rethrow;
    }
  }
  
  static void deleteLocationCache() {
    try {
      locationCacheBox.delete('main');
    } catch (e) {
      print('❌ Error deleting location cache: $e');
    }
  }
  
  static bool hasLocationCache() {
    try {
      return locationCacheBox.get('main') != null;
    } catch (e) {
      print('❌ Error checking location cache: $e');
      return false;
    }
  }
  
  // Settings operations
  static void saveSettings(Settings settings) {
    settingsBox.put('main', settings);
  }
  
  // Batch operations
  static void deleteAllWeatherData() {
    mainWeatherCacheBox.clear();
    weatherCardBox.clear();
  }
  
  static void deleteAllLocationData() {
    locationCacheBox.clear();
  }
  
  static void deleteAllData() {
    mainWeatherCacheBox.clear();
    weatherCardBox.clear();
    locationCacheBox.clear();
  }
}