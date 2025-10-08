import 'dart:io';

import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:bangla_utilities/bangla_utilities.dart';
import 'package:get/get.dart';
import 'package:workmanager/workmanager.dart';
import '../controller/controller.dart';
import '../ui/widgets/weather/status/status_data.dart';
import '../../main.dart';

class WidgetManager {
  static const String _appGroupId = 'es.antonborri.home_widget';
  // Use simple class names - HomeWidget plugin adds package name automatically
  static const String _androidWidgetName4x2 = 'OreoWidget4x2';
  static const String _androidWidgetName4x1 = 'OreoWidget4x1';

  // Keys for widget data
  static const String _keyBanglaDate = 'bangla_date';
  static const String _keyEnglishDate = 'english_date';
  static const String _keyWeatherIcon = 'weather_icon';
  static const String _keyWeatherDesc = 'weather_desc';
  static const String _keyTemperature = 'temperature';
  static const String _keyLastUpdate = 'last_update';
  static const String _keyUpdateStatus = 'update_status';

  // Fallback values
  static const String _fallbackWeatherDesc = 'আবহাওয়ার তথ্য লোড হচ্ছে...';
  static const String _fallbackTemp = '--°';
  static const String _errorWeatherDesc = 'আবহাওয়ার তথ্য পাওয়া যায়নি';
  static const String _defaultIconPath = 'assets/images/sun.png';

  static Future<void> initialize() async {
    print('🔧 Initializing WidgetManager...');
    try {
      // Set up the app group ID
      if (Platform.isIOS) {
        await HomeWidget.setAppGroupId('es.antonborri.home_widget');
      }
      print('✅ WidgetManager initialized with app group: $_appGroupId');
      
      // Save initialization status
      await _saveAndVerify(_keyUpdateStatus, 'initializing');
      
      // Register background callback
/*      await HomeWidget.registerInteractivityCallback((uri) async {
        print('🔄 Background callback triggered');
        await _loadInitialData();
      });
      print('✅ Background callback registered');
      */
      // Load initial data immediately
      await _loadInitialData();
      
      // Start periodic updates
      await _setupPeriodicUpdates();
      
      print('✅ WidgetManager initialization complete');
    } catch (e) {
      print('❌ Failed to initialize WidgetManager: $e');
      // Save error status
      await _saveAndVerify(_keyUpdateStatus, 'error');
      // Save fallback data
      await _saveFallbackData(isError: true);
    }
  }

  static Future<void> _setupPeriodicUpdates() async {
    try {
      // Don't register periodic task here since it's already done in main.dart
      // This avoids duplicate registrations and conflicts
      print('✅ Using main.dart periodic task registration');
    } catch (e) {
      print('❌ Failed to setup periodic updates: $e');
    }
  }

  static Future<void> _loadInitialData() async {
    try {
      print('🔄 Starting initial data load for widget');
      
      // Save loading status
      await _saveAndVerify(_keyUpdateStatus, 'loading');
      await _saveFallbackData(isLoading: true);
      
      // Get current weather data
      final weatherController = Get.find<WeatherController>();
      
      // Check if we have any cached weather data
      final hasWeatherData = weatherController.mainWeather.time != null;
      print('📊 Has cached weather data: $hasWeatherData');
      
      if (!hasWeatherData) {
        print('⚠️ No cached weather data, loading fresh data first');
        // Try to get fresh data using cached location
        final locationCache = weatherController.location;
        if (locationCache.lat != null && locationCache.lon != null) {
          print('📍 Using cached location data');
          await weatherController.getLocation(
            locationCache.lat!,
            locationCache.lon!,
            locationCache.district ?? '',
            locationCache.city ?? '',
          );
        } else {
          print('📍 No cached location, trying to get current location');
          await weatherController.getCurrentLocation();
        }
      }
      
      // Now try to update widget
      print('🔄 Attempting widget update');
      final success = await weatherController.updateWidget();
      
      if (!success) {
        print('⚠️ Widget update failed, trying one more time with fresh data');
        // One more try with fresh data
        await weatherController.getCurrentLocation();
        
        // Final attempt to update widget
        final retrySuccess = await weatherController.updateWidget();
        if (retrySuccess) {
          print('✅ Widget updated successfully after retry');
          await _saveAndVerify(_keyUpdateStatus, 'success');
        } else {
          print('❌ Widget update failed even after retry');
          await _saveFallbackData(isError: true);
        }
      } else {
        print('✅ Widget update successful on first try');
        await _saveAndVerify(_keyUpdateStatus, 'success');
      }
    } catch (e) {
      print('❌ Failed to load initial widget data: $e');
      await _saveFallbackData(isError: true);
    }
  }

  static Future<void> _saveFallbackData({
    bool isLoading = false,
    bool isError = false,
  }) async {
    final now = DateTime.now();
    String formattedBanglaDate;
    
    try {
      //code brough from now widget
      String dateString = DateFormat.MMMMEEEEd(
        locale.languageCode,
      ).format(DateTime.parse(now.toIso8601String()));

      // Calculate Bangla date components
      final dateTime = DateTime.parse(now.toIso8601String());
      final banglaDate = BanglaUtility.getBanglaDay(day: dateTime.day, month: dateTime.month, year: dateTime.year);
      final banglaMonth = BanglaUtility.getBanglaMonthName(day: dateTime.day, month: dateTime.month, year: dateTime.year);

      // now wd end

      formattedBanglaDate = '$dateString, $banglaDate $banglaMonth';
    } catch (e) {
      formattedBanglaDate = '-- ---, ----';
    }

    final formattedEnglishDate = DateFormat('EEEE, d MMMM').format(now);

    await Future.wait([
      _saveAndVerify(_keyBanglaDate, formattedBanglaDate),
      _saveAndVerify(_keyEnglishDate, formattedEnglishDate),
      _saveAndVerify(_keyWeatherIcon, _defaultIconPath),
      _saveAndVerify(_keyWeatherDesc, isLoading ? _fallbackWeatherDesc : _errorWeatherDesc),
      _saveAndVerify(_keyTemperature, _fallbackTemp),
      _saveAndVerify(_keyLastUpdate, now.millisecondsSinceEpoch.toString()),
      _saveAndVerify(_keyUpdateStatus, isLoading ? 'loading' : 'error'),
    ]);

    // Update widgets to show loading/error state individually
    try {
      await HomeWidget.updateWidget(androidName: _androidWidgetName4x2);
      print('✅ 4x2 widget fallback update completed');
    } catch (e) {
      print('⚠️ 4x2 widget fallback update failed: $e');
    }
    
    try {
      await HomeWidget.updateWidget(androidName: _androidWidgetName4x1);
      print('✅ 4x1 widget fallback update completed');
    } catch (e) {
      print('⚠️ 4x1 widget fallback update failed: $e');
    }
  }

  static Future<void> updateWidget({
    required String weatherIcon,
    required String weatherDescription,
    required String temperature,
  }) async {
    try {
      final now = DateTime.now();
      
      // Save updating status
      await _saveAndVerify(_keyUpdateStatus, 'updating');
      
      // Get Bangla date components
      String formattedBanglaDate;
      try {
        String dateString = DateFormat.MMMMEEEEd(
          locale.languageCode,
        ).format(DateTime.parse(now.toIso8601String()));

        // Calculate Bangla date components
        final dateTime = DateTime.parse(now.toIso8601String());
        final banglaDate = BanglaUtility.getBanglaDay(day: dateTime.day, month: dateTime.month, year: dateTime.year);
        final banglaMonth = BanglaUtility.getBanglaMonthName(day: dateTime.day, month: dateTime.month, year: dateTime.year);

        formattedBanglaDate = formattedBanglaDate = '$dateString, $banglaDate $banglaMonth';
        print('✅ Generated Bangla date: $formattedBanglaDate');
      } catch (e) {
        print('❌ BanglaUtility failed: $e');
        formattedBanglaDate = '-- ---, ----';
      }

      final formattedEnglishDate = DateFormat('EEEE, d MMMM').format(now);
      final statusData = StatusData();
      final banTemp = statusData.getDegree(temperature);
      // Save data with retries
      final maxRetries = 3;
      for (var i = 0; i < maxRetries; i++) {
        try {
          final results = await Future.wait([
            _saveAndVerify(_keyBanglaDate, formattedBanglaDate),
            _saveAndVerify(_keyEnglishDate, formattedEnglishDate),
            _saveAndVerify(_keyWeatherIcon, weatherIcon),
            _saveAndVerify(_keyWeatherDesc, weatherDescription),
            _saveAndVerify(_keyTemperature, banTemp),
            _saveAndVerify(_keyLastUpdate, now.millisecondsSinceEpoch.toString()),
            _saveAndVerify(_keyUpdateStatus, 'success'),
          ]);

          if (results.every((r) => r)) {
            print('✅ All data saved and verified on attempt ${i + 1}');
            
            // Add a small delay before updating widgets
            await Future.delayed(const Duration(milliseconds: 100));
            
            // Update both widgets individually to isolate errors
            bool success4x2 = false;
            bool success4x1 = false;
            
            try {
              final result4x2 = await HomeWidget.updateWidget(androidName: _androidWidgetName4x2);
              success4x2 = result4x2 == true;
              print('🔄 Widget 4x2 update result: $result4x2');
            } catch (e) {
              print('⚠️ Widget 4x2 update failed: $e');
            }
            
            try {
              final result4x1 = await HomeWidget.updateWidget(androidName: _androidWidgetName4x1);
              success4x1 = result4x1 == true;
              print('🔄 Widget 4x1 update result: $result4x1');
            } catch (e) {
              print('⚠️ Widget 4x1 update failed: $e');
            }
            
            print('🔄 Widget update results: 4x2=$success4x2, 4x1=$success4x1');
            
            // Consider it successful if at least one widget updated
            if (success4x2 || success4x1) {
              return; // Success, exit the retry loop
            }
          }
        } catch (e) {
          print('❌ Attempt ${i + 1} failed: $e');
          if (i == maxRetries - 1) {
            // All retries failed
            await _saveFallbackData(isError: true);
            rethrow;
          }
          await Future.delayed(Duration(milliseconds: 200 * (i + 1))); // Exponential backoff
        }
      }
    } catch (e, stackTrace) {
      print('❌ Error updating widget: $e');
      print('Stack trace: $stackTrace');
      await _saveFallbackData(isError: true);
    }
  }

  static Future<bool> _saveAndVerify(String key, String value) async {
    try {
      // Ensure value is not null and is a valid string
      if (value.isEmpty) {
        print('⚠️ Warning: Empty value for key $key, using fallback');
        value = 'N/A';
      }
      
      // Save the value
      final saved = await HomeWidget.saveWidgetData(key, value.toString());
      if (saved == null) {
        print('❌ Failed to save $key');
        return false;
      }

      // Verify the save by reading back
      final readValue = await HomeWidget.getWidgetData<String>(key);
      final success = readValue == value;
      print('${success ? '✅' : '❌'} $key: saved=$saved, verified=${readValue == value}');
      if (!success) {
        print('  Expected: $value');
        print('  Got: $readValue');
      }
      return success;
    } catch (e) {
      print('❌ Error saving/verifying $key: $e');
      // The error might be the kotlin.Number casting issue
      if (e.toString().contains('kotlin.Number')) {
        print('🔍 Detected kotlin.Number casting error - this is likely a HomeWidget plugin issue');
        print('🔍 Key: $key, Value: $value, Value type: ${value.runtimeType}');
      }
      return false;
    }
  }

  /// Background-safe widget update that doesn't require database access
  static Future<bool> updateWidgetFromBackground() async {
    try {
      print('🔄 Attempting background widget update...');
      
      // Try to read existing widget data
      final existingTemp = await HomeWidget.getWidgetData<String>(_keyTemperature);
      final existingDesc = await HomeWidget.getWidgetData<String>(_keyWeatherDesc);
      final existingIcon = await HomeWidget.getWidgetData<String>(_keyWeatherIcon);
      
      if (existingTemp != null && existingDesc != null && existingIcon != null) {
        print('✅ Found existing widget data - refreshing...');
        
        // Update timestamp to show widget is still active
        await HomeWidget.saveWidgetData(_keyLastUpdate, DateTime.now().millisecondsSinceEpoch.toString());
        await HomeWidget.saveWidgetData(_keyUpdateStatus, 'background_refresh');
        
        // Try to trigger widget refresh with error handling
        try {
          // Update widgets one by one to isolate any issues
          bool success4x2 = false;
          bool success4x1 = false;
          
          try {
            final result4x2 = await HomeWidget.updateWidget(androidName: _androidWidgetName4x2);
            success4x2 = result4x2 == true;
            print('🔄 Widget 4x2 update result: $result4x2');
          } catch (e) {
            print('⚠️ Widget 4x2 update failed: $e');
          }
          
          try {
            final result4x1 = await HomeWidget.updateWidget(androidName: _androidWidgetName4x1);
            success4x1 = result4x1 == true;
            print('🔄 Widget 4x1 update result: $result4x1');
          } catch (e) {
            print('⚠️ Widget 4x1 update failed: $e');
          }
          
          return success4x2 || success4x1;
        } catch (updateError) {
          print('⚠️ Widget update call failed, trying alternative approach: $updateError');
          // Try updating without specifying androidName (fallback)
          try {
            await HomeWidget.updateWidget();
            return true;
          } catch (fallbackError) {
            print('❌ Fallback widget update also failed: $fallbackError');
            return false;
          }
        }
      } else {
        print('⚠️ No existing widget data found, showing fallback state...');
        // Show fallback data instead of trying to access WeatherController in background
        await _saveFallbackData(isLoading: true);
        return true;
      }
    } catch (e) {
      print('❌ Background widget update failed: $e');
      // Try a basic widget refresh as last resort
      try {
        await HomeWidget.updateWidget();
        print('✅ Fallback widget refresh completed');
        return true;
      } catch (fallbackError) {
        print('❌ Even fallback widget refresh failed: $fallbackError');
        return false;
      }
    }
  }
}