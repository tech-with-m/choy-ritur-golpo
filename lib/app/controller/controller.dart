import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:home_widget/home_widget.dart';

import 'package:lat_lng_to_timezone/lat_lng_to_timezone.dart' as tzmap;
import 'package:path_provider/path_provider.dart';
import 'package:choy_ritur_golpo/app/api/api.dart';
import 'package:choy_ritur_golpo/app/data/hive_db.dart';
import 'package:choy_ritur_golpo/app/data/hive_globals.dart';
import 'package:choy_ritur_golpo/app/data/hive_migration_helper.dart';
import 'package:choy_ritur_golpo/app/utils/notification.dart';
import 'package:choy_ritur_golpo/app/utils/show_snack_bar.dart';
import 'package:choy_ritur_golpo/app/ui/widgets/weather/status/status_data.dart';
import 'package:choy_ritur_golpo/app/ui/widgets/weather/status/status_weather.dart';
import 'package:choy_ritur_golpo/main.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/standalone.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:url_launcher/url_launcher.dart';
import 'package:workmanager/workmanager.dart';
import 'package:dio/dio.dart';

import '../utils/widget_manager.dart';
import 'package:choy_ritur_golpo/app/utils/firestore_sync.dart';

class WeatherController extends GetxController {
  // CRITICAL FIX: Initialize isLoading based on cache existence
  // This prevents blank page by checking cache BEFORE first render
  late final isLoading = _shouldShowLoading().obs;
  
  final _district = ''.obs;
  final _city = ''.obs;
  final _latitude = 0.0.obs;
  final _longitude = 0.0.obs;

  String get district => _district.value;
  String get city => _city.value;
  double get latitude => _latitude.value;
  double get longitude => _longitude.value;

  final _mainWeather = MainWeatherCache().obs;
  final _location = LocationCache().obs;
  final _weatherCard = WeatherCard().obs;

  final weatherCards = <WeatherCard>[].obs;

  MainWeatherCache get mainWeather => _mainWeather.value;
  LocationCache get location => _location.value;
  WeatherCard get weatherCard => _weatherCard.value;

  final hourOfDay = 0.obs;
  final dayOfNow = 0.obs;
  final itemScrollController = ItemScrollController();
  final cacheExpiry = DateTime.now().subtract(const Duration(hours: 12));

  // Check if we should show loading state based on cache
  bool _shouldShowLoading() {
    try {
      final hasCache = HiveMigrationHelper.hasMainWeatherCache();
      print('🎯 _shouldShowLoading() - Cache exists: $hasCache');
      // If cache exists, don't show loading - show data immediately
      return !hasCache;
    } catch (e) {
      print('❌ Error checking cache in _shouldShowLoading(): $e');
      return true; // Safe default
    }
  }

  @override
  void onInit() {
    super.onInit();
    
    weatherCards.assignAll(HiveMigrationHelper.getAllWeatherCards());
    
    // Load cached data immediately on controller initialization
    // This MUST run synchronously before any UI renders
    _loadInitialCachedData();
    
    // Start periodic refresh timer (optional - only if user wants frequent updates)
    _startPeriodicRefresh();
  }

  Timer? _refreshTimer;
  DateTime? _lastRefreshTime;
  
  void _startPeriodicRefresh() {
    // Cancel any existing timer first
    _refreshTimer?.cancel();
    
    // Only refresh every 30 minutes while app is active to avoid battery drain
    // Users can still manually refresh with pull-to-refresh
    _refreshTimer = Timer.periodic(const Duration(minutes: 30), (timer) async {
      try {
        // Only refresh if app is online and has been used
        if (await isOnline.value && 
            _mainWeather.value.time != null && 
            _mainWeather.value.time!.isNotEmpty) {
          
          // Prevent rapid successive refreshes
          final now = DateTime.now();
          if (_lastRefreshTime != null && 
              now.difference(_lastRefreshTime!).inMinutes < 25) {
            print('⚠️ Skipping periodic refresh - too recent');
            return;
          }
          
          print('🔄 Periodic refresh triggered (30 minutes)');
          _lastRefreshTime = now;
          await setLocation();
        }
      } catch (e) {
        print('❌ Error in periodic refresh: $e');
      }
    });
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    super.onClose();
  }


  // Load cached data immediately without waiting for online check
  void _loadInitialCachedData() {
    print('🚀 _loadInitialCachedData() STARTED');
    print('📊 Initial isLoading value: ${isLoading.value}');
    
    try {
      final mainWeatherCache = HiveMigrationHelper.getMainWeatherCache();
      final locationCache = HiveMigrationHelper.getLocationCache();
      
      print('📦 Cache retrieval complete - Weather: ${mainWeatherCache != null}, Location: ${locationCache != null}');
      
      if (mainWeatherCache != null && locationCache != null) {
        // Check if weather data is complete
        if (mainWeatherCache.time != null && mainWeatherCache.time!.isNotEmpty) {
          print('✅ Cache has valid data - ${mainWeatherCache.time!.length} time entries');
          print('📅 Cache timestamp: ${mainWeatherCache.timestamp}');
          
          _mainWeather.value = mainWeatherCache;
          _location.value = locationCache;
          
          // Set location coordinates from cache
          if (locationCache.lat != null && locationCache.lon != null) {
            _latitude.value = locationCache.lat!;
            _longitude.value = locationCache.lon!;
            _city.value = locationCache.city ?? '';
            _district.value = locationCache.district ?? '';
            print('📍 Location set: ${_city.value}, ${_district.value}');
          }
          
          // Calculate time indices safely
          try {
            hourOfDay.value = getTime(
              _mainWeather.value.time!,
              _mainWeather.value.timezone!,
            );
            dayOfNow.value = getDay(
              _mainWeather.value.timeDaily!,
              _mainWeather.value.timezone!,
            );
            print('⏰ Time indices calculated - Hour: ${hourOfDay.value}, Day: ${dayOfNow.value}');
          } catch (timeError) {
            print('⚠️ Error calculating time indices: $timeError');
            hourOfDay.value = 0;
            dayOfNow.value = 0;
          }
          
          print('✅ Cache data loaded successfully into controller');
          print('✅ UI should show cached weather data immediately');
        } else {
          print('⚠️ Cached weather data is incomplete - time is ${mainWeatherCache.time == null ? "null" : "empty"}');
          print('⚠️ Will show no internet error');
        }
      } else {
        print('⚠️ No cached data available on init - First time app launch');
        print('⚠️ isLoading should be true, will attempt to fetch data');
      }
    } catch (e) {
      print('❌ Error loading initial cached data: $e');
      print('❌ Stack trace: ${StackTrace.current}');
    } finally {
      // Ensure isLoading is false if we have data
      final hasData = _mainWeather.value.time != null && _mainWeather.value.time!.isNotEmpty;
      if (hasData && isLoading.value) {
        print('🔄 Setting isLoading to false (we have cached data)');
        isLoading.value = false;
      } else if (!hasData && !isLoading.value) {
        print('🔄 Setting isLoading to true (no cached data available)');
        isLoading.value = true;
      }
      print('✅ Final isLoading state: ${isLoading.value}');
      print('✅ Has data: $hasData');
      print('✅ _loadInitialCachedData() COMPLETED');
    }
  }

  Future<Position> _determinePosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }
    
    try {
      // Add timeout to prevent hanging when offline
      return await Geolocator.getCurrentPosition(
        timeLimit: const Duration(seconds: 10),
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          distanceFilter: 100,
        ),
      );
    } catch (e) {
      print('⚠️ Geolocator timeout or error: $e');
      // Try to get last known position as fallback
      try {
        final lastPosition = await Geolocator.getLastKnownPosition();
        if (lastPosition != null) {
          print('📍 Using last known position as fallback');
          return lastPosition;
        }
      } catch (fallbackError) {
        print('⚠️ Last known position also failed: $fallbackError');
      }
      rethrow;
    }
  }

  Future<void> setLocation({bool forceRefresh = false}) async {
    try {
      // If we already have cached data loaded and not forcing refresh, don't reload it
      if (!forceRefresh && _mainWeather.value.time != null && _mainWeather.value.time!.isNotEmpty) {
        print('✅ Cached data already loaded, skipping reload');
        isLoading.value = false;
        
        // Still try background refresh if online
        _tryBackgroundRefresh();
        return;
      }
      
      if (forceRefresh) {
        print('🔄 Force refresh requested - loading fresh data');
      }
      
      // CACHE-FIRST STRATEGY: Always try to load cache first, regardless of internet
      print('📦 Cache-first strategy: Loading cached data first');
      await readCache();
      
      // If cache loaded successfully, we're done for now
      if (_mainWeather.value.time != null && _mainWeather.value.time!.isNotEmpty) {
        print('✅ Cache loaded successfully - data ready');
        isLoading.value = false;
        
        // Try to refresh in background if online (non-blocking)
        _tryBackgroundRefresh();
        return;
      }
      
      // If no cache available, try to get fresh data
      print('📦 No cache available - attempting fresh data');
      
      // For force refresh, try to load data regardless of connectivity check
      // The actual API calls will handle offline scenarios
      if (forceRefresh) {
        print('🔄 Force refresh - attempting to load fresh data');
      } else {
        // Only check online status for normal refresh
        final online = await isOnline.value;
        if (!online) {
          print('📱 Offline and no cache - showing error');
          isLoading.value = false;
          showSnackBar(content: 'no_inter'.tr);
          return;
        }
        print('🌐 Online - loading fresh data');
      }
      if (settings.location) {
        await getCurrentLocation(skipOnlineCheck: forceRefresh);
      } else {
        final locationCity = HiveMigrationHelper.getLocationCache();
        if (locationCity != null) {
          await getLocation(
            locationCity.lat!,
            locationCity.lon!,
            locationCity.district!,
            locationCity.city!,
            skipOnlineCheck: forceRefresh,
          );
        } else {
          print('⚠️ No cached location available');
          isLoading.value = false;
        }
      }
    } catch (e) {
      print('❌ Error in setLocation(): $e');
      isLoading.value = false;
    }
  }

  // Non-blocking background refresh if online
  void _tryBackgroundRefresh({bool forceRefresh = false}) {
    // Run in background without blocking UI
    Future.microtask(() async {
      try {
        final online = await isOnline.value;
        if (online && _mainWeather.value.time != null && _mainWeather.value.time!.isNotEmpty) {
          print('🔄 Background refresh: Updating data silently');
          if (settings.location) {
            await getCurrentLocation();
          } else {
            final locationCity = HiveMigrationHelper.getLocationCache();
            if (locationCity != null) {
              await getLocation(
                locationCity.lat!,
                locationCity.lon!,
                locationCity.district!,
                locationCity.city!,
              );
            }
          }
        }
      } catch (e) {
        print('⚠️ Background refresh failed: $e');
        // Don't show errors for background refresh
      }
    });
  }

  Future<Map<String, String>?> _getBarikoiLocation(double lat, double lon) async {
    try {
      final dio = Dio()
        ..options.connectTimeout = const Duration(seconds: 5)
        ..options.receiveTimeout = const Duration(seconds: 3);
      
      final response = await dio.get(
        'https://maps.barikoi.com/api/geocode/reverse',
        queryParameters: {
          'api_key': 'bkoi_2da17c85565f573e2918f28ce5fbe85904b5334b8df2ac0cb6abadb534acfb38',
          'latitude': lat,
          'longitude': lon,
          'country': true,
          'address': true,
          'bangla': true,
        },
      );

      if (response.statusCode == 200 && 
          response.data['status'] == 200 && 
          response.data['place'] != null) {
        final place = response.data['place'];
        return {
          'address': place['address_bn'] ?? '',
          'district': place['city_bn'] ?? '',
          'city': place['area_bn'] ?? '',
        };
      }
      // trying barikoi free
      // there are some other free good option too https://nominatim.openstreetmap.org/reverse?lat=23.831122&lon=90.424301&format=json
      final responseFree =await dio.get(
        'https://maps.barikoi.com/api/geocode/reverse',
        queryParameters: {
          'latitude': lat,
          'longitude': lon
        },
      );
      if (response.statusCode == 200 &&
          response.data['status'] == 200 &&
          response.data['place'] != null) {
        final place = response.data['place'];
        return {
          'address': place['address'] ?? '',
          'district': place['city'] ?? '',
          'city': place['area'] ?? '',
        };
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> getCurrentLocation({bool skipOnlineCheck = false}) async {
    try {
      if (!skipOnlineCheck && !(await isOnline.value)) {
        print('📱 Offline detected in getCurrentLocation()');
        // Only show error if no cache is available
        if (!HiveMigrationHelper.hasMainWeatherCache()) {
          showSnackBar(content: 'no_inter'.tr);
        } else {
          print('📦 Offline but cache available - loading cached data');
        }
        await readCache();
        return;
      }

      if (!await Geolocator.isLocationServiceEnabled()) {
        showSnackBar(
          content: 'no_location'.tr,
          onPressed: () => Geolocator.openLocationSettings(),
        );
        await readCache();
        return;
      }
      // Check if we have recent cached data (less than 1 hour old)
      if (HiveMigrationHelper.hasMainWeatherCache()) {
        final cachedData = HiveMigrationHelper.getMainWeatherCache();
        if (cachedData?.timestamp != null) {
          final age = DateTime.now().difference(cachedData!.timestamp!);
          if (age.inHours < 1) {
            print('📦 Using recent cached data (${age.inMinutes} minutes old)');
            _mainWeather.value = cachedData;
            await readCache();
            return;
          }
        }
      }
      final position = await _determinePosition();
      _latitude.value = position.latitude;
      _longitude.value = position.longitude;

      // Try Barikoi API first
      final barikoiLocation = await _getBarikoiLocation(_latitude.value, _longitude.value);
      
      if (barikoiLocation != null && 
          (barikoiLocation['address']?.isNotEmpty == true || 
           barikoiLocation['district']?.isNotEmpty == true || 
           barikoiLocation['city']?.isNotEmpty == true)) {
        _district.value = barikoiLocation['district'] ?? '';
        _city.value = barikoiLocation['address'] ?? '';
      } else {
        // Fall back to device geocoding
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        final place = placemarks[0];
        _district.value = place.subAdministrativeArea ?? '';
        _city.value = '${place.locality ?? ''}, ${place.subLocality ?? ''}';
      }

      _mainWeather.value = await WeatherAPI().getWeatherData(
        _latitude.value,
        _longitude.value,
      );

      notificationCheck();
      await writeCache();
      // Sync updated location with Firestore (non-blocking)
      // Do this after cache write to ensure we have district/city filled
      unawaited(FirestoreSync().saveLocation(
        latitude: _latitude.value,
        longitude: _longitude.value,
        district: _district.value,
        city: _city.value,
      ));
      await readCache();
    } catch (e) {
      
      // If we get here, something went wrong - try to load cache as fallback
      await readCache();
    }
  }

  Future<Map> getCurrentLocationSearch() async {
    
    if (!(await isOnline.value)) {
      showSnackBar(content: 'no_inter'.tr);
      return {}; // Return empty map when offline
    }

    if (!await Geolocator.isLocationServiceEnabled()) {
      showSnackBar(
        content: 'no_location'.tr,
        onPressed: () => Geolocator.openLocationSettings(),
      );
    }

    final position = await _determinePosition();

    // Try Barikoi API first
    final barikoiLocation = await _getBarikoiLocation(position.latitude, position.longitude);
    
    
    if (barikoiLocation != null && 
        (barikoiLocation['address']?.isNotEmpty == true || 
         barikoiLocation['district']?.isNotEmpty == true || 
         barikoiLocation['city']?.isNotEmpty == true)) {
      return {
        'lat': position.latitude,
        'lon': position.longitude,
        'district': barikoiLocation['address'],
        'city': '',
      };
    }

    // Fall back to device geocoding
    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    final place = placemarks[0];

    // Format the fallback address in a readable way
    final List<String> addressParts = [];
    if (place.locality?.isNotEmpty == true) addressParts.add(place.locality!);
    if (place.subAdministrativeArea?.isNotEmpty == true) addressParts.add(place.subAdministrativeArea!);
    if (place.administrativeArea?.isNotEmpty == true) addressParts.add(place.administrativeArea!);

    return {
      'lat': position.latitude,
      'lon': position.longitude,
      'district': addressParts.join(', '),
      'city': '',
    };
  }

  Future<void> getLocation(
    double latitude,
    double longitude,
    String district,
    String locality, {
    bool skipOnlineCheck = false,
  }) async {
    try {
      if (!skipOnlineCheck && !(await isOnline.value)) {
        // Only show error if no cache is available
        if (!HiveMigrationHelper.hasMainWeatherCache()) {
          showSnackBar(content: 'no_inter'.tr);
        } else {
          print('📦 Offline but cache available - loading cached data');
        }
        await readCache();
        return;
      }

      // Check if we have recent cached data (less than 1 hour old)
    if (HiveMigrationHelper.hasMainWeatherCache()) {
      final cachedData = HiveMigrationHelper.getMainWeatherCache();
      if (cachedData?.timestamp != null) {
        final age = DateTime.now().difference(cachedData!.timestamp!);
        if (age.inHours < 1) {
          print('📦 Using recent cached data (${age.inMinutes} minutes old)');
          await readCache();
          return;
        }
      }
    }

    _latitude.value = latitude;
    _longitude.value = longitude;
    _district.value = district;
    _city.value = locality;

    _mainWeather.value = await WeatherAPI().getWeatherData(
      _latitude.value,
      _longitude.value,
    );

      notificationCheck();
      await writeCache();
      // Sync manual location selection to Firestore
      unawaited(FirestoreSync().saveLocation(
        latitude: _latitude.value,
        longitude: _longitude.value,
        district: _district.value,
        city: _city.value,
      ));
      await readCache();
    } catch (e) {
      print('❌ Error in getLocation(): $e');

      // Check if it's a network error
      if (e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException') ||
          e.toString().contains('DioException')) {
        print('🌐 Network error detected - showing no internet message');
        showSnackBar(content: 'no_inter'.tr);
      }

      // Try to load cache as fallback
      await readCache();
    }
  }

  Future<void> readCache() async {
    try {
      print('🔄 Starting cache read...');
      
      // Get cached data directly - no retry loops to prevent resource issues
      final mainWeatherCache = HiveMigrationHelper.getMainWeatherCache();
      final locationCache = HiveMigrationHelper.getLocationCache();
      
      print('📊 Cache check - Weather: ${mainWeatherCache != null}, Location: ${locationCache != null}');
      
      // If no cached data available, stop loading but do not show no-internet
      // A missing cache can legitimately happen during a manual refresh
      // (e.g., after deleteAll), and network calls will follow.
      if (mainWeatherCache == null || locationCache == null) {
        print('⚠️ No cached data available');
        print('⚠️ Weather cache: ${mainWeatherCache != null}');
        print('⚠️ Location cache: ${locationCache != null}');
        isLoading.value = false;
        return;
      }
      
      // Log cache details
      print('📊 Weather cache timestamp: ${mainWeatherCache.timestamp}');
      print('📊 Weather cache time entries: ${mainWeatherCache.time?.length}');
      print('📊 Location cache: ${locationCache.city}, ${locationCache.district}');

      _mainWeather.value = mainWeatherCache;
      _location.value = locationCache;

      hourOfDay.value = getTime(
        _mainWeather.value.time!,
        _mainWeather.value.timezone!,
      );
      dayOfNow.value = getDay(
        _mainWeather.value.timeDaily!,
        _mainWeather.value.timezone!,
      );

      if (Platform.isAndroid) {
        // Update widget with new data
        try {
          await updateWidget();
        } catch (e) {
          print('❌ Error updating widget after cache read: $e');
        }
      }

      isLoading.value = false;
      print('✅ Cache read completed successfully');
    } catch (e) {
      print('❌ Error in readCache(): $e');
      isLoading.value = false;
    }

    Future.delayed(const Duration(milliseconds: 30), () {
      itemScrollController.scrollTo(
        index: hourOfDay.value,
        duration: const Duration(seconds: 2),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  Future<void> writeCache() async {
    try {
      print('🔄 Starting cache write...');
      
      final locationCaches = LocationCache(
        lat: _latitude.value,
        lon: _longitude.value,
        city: _city.value,
        district: _district.value,
      );
      
      // Set timestamp on weather cache before saving
      _mainWeather.value.timestamp = DateTime.now();
      
      print('💾 About to save weather cache with ${_mainWeather.value.time?.length} time entries');
      print('💾 Weather timezone: ${_mainWeather.value.timezone}');
      print('💾 Weather timestamp: ${_mainWeather.value.timestamp}');
      print('💾 Location: ${locationCaches.city}, ${locationCaches.district}');
      
      // Always save fresh weather and location data to ensure widgets have latest data
      HiveMigrationHelper.saveMainWeatherCache(_mainWeather.value);
      HiveMigrationHelper.saveLocationCache(locationCaches);
      
      print('✅ Cache save operations completed');
      
      // Verify cache was saved with detailed logging
      final savedWeather = HiveMigrationHelper.getMainWeatherCache();
      final savedLocation = HiveMigrationHelper.getLocationCache();
      
      if (savedWeather != null) {
        print('✅ Weather cache verification successful');
        print('📊 Saved weather time entries: ${savedWeather.time?.length}');
        print('📊 Saved weather timezone: ${savedWeather.timezone}');
        print('📊 Saved weather timestamp: ${savedWeather.timestamp}');
        
        // Additional validation
        if (savedWeather.time == null || savedWeather.time!.isEmpty) {
          print('⚠️ WARNING: Saved weather cache has no time data!');
        }
      } else {
        print('❌ Weather cache verification failed - cache is null');
      }
      
      if (savedLocation != null) {
        print('✅ Location cache verification successful');
        print('📊 Saved location: ${savedLocation.city}, ${savedLocation.district}');
        print('📊 Saved coordinates: ${savedLocation.lat}, ${savedLocation.lon}');
      } else {
        print('❌ Location cache verification failed - cache is null');
      }
      
    } catch (e) {
      print('❌ Error saving cache: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<void> deleteCache() async {
    if (!(await isOnline.value)) {
      return;
    }

    HiveMigrationHelper.deleteExpiredMainWeatherCache(cacheExpiry);
    if (!HiveMigrationHelper.hasMainWeatherCache()) {
      await flutterLocalNotificationsPlugin.cancelAll();
    }
  }


  Future<void> deleteAll(bool changeCity) async {
    if (!(await isOnline.value)) {
      return;
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    await flutterLocalNotificationsPlugin.cancelAll();

    if (!settings.location) {
      HiveMigrationHelper.deleteMainWeatherCache();
    }
    if (settings.location && serviceEnabled || changeCity) {
      HiveMigrationHelper.deleteMainWeatherCache();
      HiveMigrationHelper.deleteLocationCache();
    }
  }

  Future<void> addCardWeather(
    double latitude,
    double longitude,
    String city,
    String district,
  ) async {
    if (!(await isOnline.value)) {
      showSnackBar(content: 'no_inter'.tr);
      return;
    }

    final tz = tzmap.latLngToTimezoneString(latitude, longitude);
    _weatherCard.value = await WeatherAPI().getWeatherCard(
      latitude,
      longitude,
      city,
      district,
      tz,
    );
    weatherCards.add(_weatherCard.value);
    HiveMigrationHelper.saveWeatherCard(_weatherCard.value);
  }

  Future<void> updateCacheCard(bool refresh) async {
    final weatherCard =
        refresh
            ? HiveMigrationHelper.getAllWeatherCards()
            : HiveMigrationHelper.getWeatherCardsOlderThan(cacheExpiry);

    if (!(await isOnline.value) || weatherCard.isEmpty) {
      return;
    }

    for (var oldCard in weatherCard) {
      final updatedCard = await WeatherAPI().getWeatherCard(
        oldCard.lat!,
        oldCard.lon!,
        oldCard.city!,
        oldCard.district!,
        oldCard.timezone!,
      );
      oldCard
        ..time = updatedCard.time
        ..weathercode = updatedCard.weathercode
        ..temperature2M = updatedCard.temperature2M
        ..apparentTemperature = updatedCard.apparentTemperature
        ..relativehumidity2M = updatedCard.relativehumidity2M
        ..precipitation = updatedCard.precipitation
        ..rain = updatedCard.rain
        ..surfacePressure = updatedCard.surfacePressure
        ..visibility = updatedCard.visibility
        ..evapotranspiration = updatedCard.evapotranspiration
        ..windspeed10M = updatedCard.windspeed10M
        ..winddirection10M = updatedCard.winddirection10M
        ..windgusts10M = updatedCard.windgusts10M
        ..cloudcover = updatedCard.cloudcover
        ..uvIndex = updatedCard.uvIndex
        ..dewpoint2M = updatedCard.dewpoint2M
        ..precipitationProbability = updatedCard.precipitationProbability
        ..shortwaveRadiation = updatedCard.shortwaveRadiation
        ..timeDaily = updatedCard.timeDaily
        ..weathercodeDaily = updatedCard.weathercodeDaily
        ..temperature2MMax = updatedCard.temperature2MMax
        ..temperature2MMin = updatedCard.temperature2MMin
        ..apparentTemperatureMax = updatedCard.apparentTemperatureMax
        ..apparentTemperatureMin = updatedCard.apparentTemperatureMin
        ..sunrise = updatedCard.sunrise
        ..sunset = updatedCard.sunset
        ..precipitationSum = updatedCard.precipitationSum
        ..precipitationProbabilityMax =
            updatedCard.precipitationProbabilityMax
        ..windspeed10MMax = updatedCard.windspeed10MMax
        ..windgusts10MMax = updatedCard.windgusts10MMax
        ..uvIndexMax = updatedCard.uvIndexMax
        ..rainSum = updatedCard.rainSum
        ..winddirection10MDominant = updatedCard.winddirection10MDominant
        ..timestamp = DateTime.now();

      HiveMigrationHelper.saveWeatherCard(oldCard);

      final newCard = oldCard;
      final oldIdx = weatherCard.indexOf(oldCard);
      weatherCards[oldIdx] = newCard;
      weatherCards.refresh();
    }
  }

  Future<void> updateCard(WeatherCard weatherCard) async {
    if (!(await isOnline.value)) {
      return;
    }

    final updatedCard = await WeatherAPI().getWeatherCard(
      weatherCard.lat!,
      weatherCard.lon!,
      weatherCard.city!,
      weatherCard.district!,
      weatherCard.timezone!,
    );

    weatherCard
      ..time = updatedCard.time
      ..weathercode = updatedCard.weathercode
      ..temperature2M = updatedCard.temperature2M
      ..apparentTemperature = updatedCard.apparentTemperature
      ..relativehumidity2M = updatedCard.relativehumidity2M
      ..precipitation = updatedCard.precipitation
      ..rain = updatedCard.rain
      ..surfacePressure = updatedCard.surfacePressure
      ..visibility = updatedCard.visibility
      ..evapotranspiration = updatedCard.evapotranspiration
      ..windspeed10M = updatedCard.windspeed10M
      ..winddirection10M = updatedCard.winddirection10M
      ..windgusts10M = updatedCard.windgusts10M
      ..cloudcover = updatedCard.cloudcover
      ..uvIndex = updatedCard.uvIndex
      ..dewpoint2M = updatedCard.dewpoint2M
      ..precipitationProbability = updatedCard.precipitationProbability
      ..shortwaveRadiation = updatedCard.shortwaveRadiation
      ..timeDaily = updatedCard.timeDaily
      ..weathercodeDaily = updatedCard.weathercodeDaily
      ..temperature2MMax = updatedCard.temperature2MMax
      ..temperature2MMin = updatedCard.temperature2MMin
      ..apparentTemperatureMax = updatedCard.apparentTemperatureMax
      ..apparentTemperatureMin = updatedCard.apparentTemperatureMin
      ..sunrise = updatedCard.sunrise
      ..sunset = updatedCard.sunset
      ..precipitationSum = updatedCard.precipitationSum
      ..precipitationProbabilityMax = updatedCard.precipitationProbabilityMax
      ..windspeed10MMax = updatedCard.windspeed10MMax
      ..windgusts10MMax = updatedCard.windgusts10MMax
      ..uvIndexMax = updatedCard.uvIndexMax
      ..rainSum = updatedCard.rainSum
      ..winddirection10MDominant = updatedCard.winddirection10MDominant
      ..timestamp = DateTime.now();

    HiveMigrationHelper.saveWeatherCard(weatherCard);
  }

  Future<void> deleteCardWeather(WeatherCard weatherCard) async {
    weatherCards.remove(weatherCard);
    HiveMigrationHelper.deleteWeatherCard(weatherCard);
  }

  int getTime(List<String> time, String timezone) {
    try {
      final index = time.indexWhere((t) {
        try {
          final dateTime = DateTime.parse(t);
          return tz.TZDateTime.now(tz.getLocation(timezone)).hour ==
                  dateTime.hour &&
              tz.TZDateTime.now(tz.getLocation(timezone)).day == dateTime.day;
        } catch (e) {
          print('⚠️ Error parsing time: $t');
          return false;
        }
      });
      // Return 0 if no match found to prevent -1 index access
      return index >= 0 ? index : 0;
    } catch (e) {
      print('⚠️ Error in getTime: $e');
      return 0;
    }
  }

  int getDay(List<DateTime> time, String timezone) {
    try {
      final index = time.indexWhere(
        (t) => tz.TZDateTime.now(tz.getLocation(timezone)).day == t.day,
      );
      // Return 0 if no match found to prevent -1 index access
      return index >= 0 ? index : 0;
    } catch (e) {
      print('⚠️ Error in getDay: $e');
      return 0;
    }
  }

  TimeOfDay timeConvert(String normTime) {
    final hh = normTime.endsWith('PM') ? 12 : 0;
    final timeParts = normTime.split(' ')[0].split(':');
    return TimeOfDay(
      hour: hh + int.parse(timeParts[0]) % 24,
      minute: int.parse(timeParts[1]) % 60,
    );
  }

  Future<String> getLocalImagePath(String icon) async {
    final directory = await getTemporaryDirectory();
    final imagePath = '${directory.path}/$icon';

    final data = await rootBundle.load('assets/images/$icon');
    final bytes = data.buffer.asUint8List();

    await File(imagePath).writeAsBytes(bytes);

    return imagePath;
  }

  void notification(MainWeatherCache mainWeatherCache) async {
    final now = DateTime.now();
    final startHour = timeConvert(timeStart).hour;
    final endHour = timeConvert(timeEnd).hour;

    for (var i = 0; i < mainWeatherCache.time!.length; i += timeRange) {
      final notificationTime = DateTime.parse(mainWeatherCache.time![i]);

      if (notificationTime.isAfter(now) &&
          notificationTime.hour >= startHour &&
          notificationTime.hour <= endHour) {
        for (var j = 0; j < mainWeatherCache.timeDaily!.length; j++) {
          if (mainWeatherCache.timeDaily![j].day == notificationTime.day) {
            NotificationShow().showNotification(
              UniqueKey().hashCode,
              '$city: ${mainWeatherCache.temperature2M![i]}°',
              '${StatusWeather().getText(mainWeatherCache.weathercode![i])} · ${StatusData().getTimeFormat(mainWeatherCache.time![i])}',
              notificationTime,
              StatusWeather().getImageNotification(
                mainWeatherCache.weathercode![i],
                mainWeatherCache.time![i],
                mainWeatherCache.sunrise![j],
                mainWeatherCache.sunset![j],
              ),
            );
          }
        }
      }
    }
  }

  void notificationCheck() async {
    if (settings.notifications) {
      final pendingNotificationRequests =
          await flutterLocalNotificationsPlugin.pendingNotificationRequests();
      if (pendingNotificationRequests.isEmpty) {
        notification(_mainWeather.value);
      }
    }
  }

  void reorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final element = weatherCards.removeAt(oldIndex);
    weatherCards.insert(newIndex, element);

    for (int i = 0; i < weatherCards.length; i++) {
      final item = weatherCards[i];
      item.index = i;
      HiveMigrationHelper.saveWeatherCard(item);
    }
  }

  Future<bool> updateWidgetBackgroundColor(String color) async {
    settings.widgetBackgroundColor = color;
    HiveMigrationHelper.saveSettings(settings);

    try {
      await HomeWidget.saveWidgetData('background_color', color);
      // Use WidgetManager to handle widget updates properly
      return await WidgetManager.updateWidgetFromBackground();
    } catch (e) {
      print('❌ Error updating widget background color: $e');
      return false;
    }
  }

  Future<bool> updateWidgetTextColor(String color) async {
    settings.widgetTextColor = color;
    HiveMigrationHelper.saveSettings(settings);

    try {
      await HomeWidget.saveWidgetData('text_color', color);
      // Use WidgetManager to handle widget updates properly
      return await WidgetManager.updateWidgetFromBackground();
    } catch (e) {
      print('❌ Error updating widget text color: $e');
      return false;
    }
  }

  Future<bool> updateWidget() async {
    try {
      print('🔄 Starting widget update...');
      
      // Initialize timezone
      //final timeZoneName = await FlutterTimezone.getLocalTimezone();
      //tz.initializeTimeZones();
      //tz.setLocalLocation(tz.getLocation(timeZoneName));
      //print('✅ Timezone initialized');

      // Get weather data
      final mainWeatherCache = HiveMigrationHelper.getMainWeatherCache();
      if (mainWeatherCache == null) {
        print('❌ No weather data found in cache');
        return false;
      }
      print('✅ Found weather data in cache');

      // Calculate time indices
      final hour = getTime(mainWeatherCache.time!, mainWeatherCache.timezone!);
      final day = getDay(mainWeatherCache.timeDaily!, mainWeatherCache.timezone!);
      print('📊 Using hour: $hour, day: $day');

      // Get weather icon
      final weatherIcon = await getLocalImagePath(
        StatusWeather().getImageNotification(
          mainWeatherCache.weathercode![hour],
          mainWeatherCache.time![hour],
          mainWeatherCache.sunrise![day],
          mainWeatherCache.sunset![day],
        ),
      );
      print('🖼️ Weather icon path: $weatherIcon');

      // Get weather description and temperature
      final weatherDesc = StatusWeather().getText(mainWeatherCache.weathercode![hour]);
      final temp = '${mainWeatherCache.temperature2M?[hour].round()}°';
      print('📝 Weather data prepared:');
      print('- Description: $weatherDesc');
      print('- Temperature: $temp');

      // Update widget with retry logic
      var retryCount = 0;
      const maxRetries = 3;
      
      while (retryCount < maxRetries) {
        try {
          await WidgetManager.updateWidget(
            weatherIcon: weatherIcon,
            weatherDescription: weatherDesc,
            temperature: temp,
          );
          print('✅ Widget updated successfully');
          return true;
        } catch (e) {
          retryCount++;
          print('⚠️ Widget update attempt $retryCount failed: $e');
          if (retryCount < maxRetries) {
            await Future.delayed(Duration(seconds: retryCount));
          }
        }
      }

      print('❌ Widget update failed after $maxRetries attempts');
      return false;
    } catch (e, stackTrace) {
      print('❌ Error updating widget: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  void urlLauncher(String uri) async {
    final url = Uri.parse(uri);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
}
