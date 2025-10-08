import 'dart:async';
import 'dart:convert';
import 'dart:io';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:choy_ritur_golpo/app/controller/controller.dart';
import 'package:choy_ritur_golpo/app/data/hive_db.dart';
import 'package:choy_ritur_golpo/app/data/hive_globals.dart';
import 'package:choy_ritur_golpo/app/ui/geolocation.dart';
import 'package:choy_ritur_golpo/app/ui/home.dart';
import 'package:choy_ritur_golpo/app/ui/onboarding.dart';
import 'package:choy_ritur_golpo/app/ui/screens/notification_screen.dart';
import 'package:choy_ritur_golpo/app/utils/ad_helper.dart';
import 'package:choy_ritur_golpo/app/utils/device_info.dart';
import 'package:choy_ritur_golpo/app/utils/widget_manager.dart';
import 'package:choy_ritur_golpo/theme/theme.dart';
import 'package:choy_ritur_golpo/theme/theme_controller.dart';
import 'package:choy_ritur_golpo/translation/translation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:choy_ritur_golpo/app/utils/firestore_sync.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:home_widget/home_widget.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart';

// REMOVE shared_preferences and dart:async imports from here, they're not needed globally
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:async';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Helper function to check internet connectivity with timeout
Future<bool> _checkConnectivityWithTimeout() async {
  try {
    return await InternetConnection().hasInternetAccess.timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        print('⚠️ Internet connectivity check timed out');
        return false;
      },
    );
  } catch (e) {
    print('❌ Error checking internet connectivity: $e');
    return false;
  }
}

// Global instances moved to hive_globals.dart
final ValueNotifier<Future<bool>> isOnline = ValueNotifier(
  _checkConnectivityWithTimeout(),
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

bool amoledTheme = false;
bool materialColor = false;
bool roundDegree = false; // This was not deleted, I re-added
bool largeElement = false;
Locale locale = const Locale('bn', 'IN');
int timeRange = 1;
String timeStart = '09:00';
String timeEnd = '21:00';
String widgetBackgroundColor = '';
String widgetTextColor = '';

const String appGroupId = 'আবহাওয়া';
const String androidWidgetName = 'OreoWidget';

const List<Map<String, dynamic>> appLanguages = [
  {'name': 'English', 'locale': Locale('en', 'US')},
  {'name': 'বাংলা', 'locale': Locale('bn', 'IN')},
];

FirebaseMessaging? firebaseMessaging;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // You can handle background messages here if needed
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      print('🔄 Background task: $task');

      // Handle different background tasks
      switch (task) {
        case 'widgetUpdate':
        case 'widgetBackgroundUpdate':
        case 'weatherWidgetUpdate':
        case 'updateWeatherWidget':
          print('🔄 Background widget update requested');
          return await WidgetManager.updateWidgetFromBackground();
        default:
          print('⚠️ Unknown background task: $task');
          return false;
      }
    } catch (e) {
      print('❌ Background task failed: $e');
      return false;
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeApp();
  
  // Ensure settings.language is set (should be done in _initializeHive)
  if (kDebugMode) {
    print('settings.language: ${settings.language}');
  }
  settings.language = 'bn_IN';
  
  // Safely save settings only if Hive is available
  try {
    settingsBox.put('main', settings);
  } catch (e) {
    print('⚠️ Could not save settings to Hive: $e');
  }

  // Now set the locale variable
  locale = Locale(
    settings.language!.split('_')[0],
    settings.language!.split('_')[1],
  );

  runApp(const MyApp());
}

Future<void> _initializeApp() async {
  print('🚀 App initialization started');
  
  // CRITICAL: Initialize Hive FIRST - this is the ONLY blocking operation we need
  try {
    print('📦 Initializing Hive...');
    await _initializeHive();
    print('✅ Hive initialized successfully');
  } catch (e) {
    print('❌ Hive initialization failed: $e');
    settings = Settings();
    settings.language = 'bn_IN';
    locationCache = LocationCache();
  }

  // CRITICAL: Initialize timezone immediately (required for time calculations)
  try {
    print('⏰ Initializing timezone...');
    await _initializeTimeZone();
    print('✅ Timezone initialized');
  } catch (e) {
    print('❌ Timezone init failed: $e');
  }

  // CRITICAL: Initialize Firebase with timeout (required for FCM)
  try {
    print('🔥 Initializing Firebase with 3s timeout...');
    await Firebase.initializeApp().timeout(
      const Duration(seconds: 3),
      onTimeout: () {
        print('⚠️ Firebase init timed out after 3s (offline?)');
        throw TimeoutException('Firebase init timeout');
      },
    );
    print('✅ Firebase initialized');
  } catch (e) {
    print('❌ Firebase init failed (app will work without push notifications): $e');
  }

  // Everything else runs in background - doesn't block app startup
  _initializeServicesInBackground();

  print('✅ App initialization completed - launching UI (ADS DISABLED)');
}

// All non-critical services run in background
void _initializeServicesInBackground() {
  Future.microtask(() async {
    try {
      print('🔄 Background services initialization started');
      
      // Firebase Messaging (Firebase already initialized above)
      try {
        firebaseMessaging = FirebaseMessaging.instance;
        FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
        await firebaseMessaging!.subscribeToTopic('alert').timeout(const Duration(seconds: 5));
        print('✅ FCM topics subscribed');
      } catch (e) {
        print('⚠️ FCM setup failed (offline?): $e');
      }

      // FCM Token Sync
      try {
        await _syncFcmTokenOnce().timeout(const Duration(seconds: 5));
        FirebaseMessaging.instance.onTokenRefresh.listen((t) async {
          try {
            await FirestoreSync().saveFcmToken(
              token: t,
              latitude: locationCache.lat,
              longitude: locationCache.lon,
              district: locationCache.district,
              city: locationCache.city,
            );
          } catch (e) {
            debugPrint('FCM token refresh failed: $e');
          }
        });
        print('✅ FCM token synced');
      } catch (e) {
        print('⚠️ FCM token sync failed (offline?): $e');
      }

      // Notifications
      try {
        await _initializeNotifications();
        print('✅ Notifications initialized');
      } catch (e) {
        print('⚠️ Notifications init failed: $e');
      }

      // ADS REMOVED - focusing on offline functionality
      print('⚠️ Ads disabled for offline functionality testing');

      // Connectivity
      _setupConnectivityListener();

      // Android-specific
      if (Platform.isAndroid) {
        try {
          await _setOptimalDisplayMode();
          await Workmanager().initialize(callbackDispatcher, isInDebugMode: kDebugMode);
          await Workmanager().registerPeriodicTask(
            'widgetUpdate',
            'widgetBackgroundUpdate',
            frequency: const Duration(minutes: 15),
            existingWorkPolicy: ExistingWorkPolicy.replace,
            constraints: Constraints(
              networkType: NetworkType.not_required,
              requiresBatteryNotLow: false,
              requiresCharging: false,
              requiresDeviceIdle: false,
            ),
            backoffPolicy: BackoffPolicy.linear,
            backoffPolicyDelay: const Duration(minutes: 5),
          );
          print('✅ Android services initialized');
        } catch (e) {
          print('⚠️ Android services init failed: $e');
        }
      }

      DeviceFeature().init();
      
      print('✅ Background services initialization completed');
    } catch (e) {
      print('❌ Background services error: $e');
    }
  });
}
DateTime? _lastConnectivityRefresh;
/*
Future<void> _initializeFirebaseAuth() async {
  try {
    // Check current auth state first
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      print('🔐 No authenticated user found, signing in anonymously...');

      // Add retry logic for anonymous sign-in
      int retryCount = 0;
      const maxRetries = 3;

      while (retryCount < maxRetries) {
        try {
          final userCredential = await FirebaseAuth.instance.signInAnonymously();
          print('✅ Anonymous sign-in successful: ${userCredential.user?.uid}');
          break;
        } catch (e) {
          retryCount++;
          print('❌ Anonymous sign-in attempt $retryCount failed: $e');

          if (retryCount >= maxRetries) {
            print('❌ Max retry attempts reached for anonymous sign-in');
            // Don't throw here - app can continue without auth
            break;
          }

          // Wait before retry with exponential backoff
          await Future.delayed(Duration(seconds: retryCount * 2));
        }
      }
    } else {
      print('✅ User already authenticated: ${currentUser.uid}');
    }
  } catch (e) {
    print('❌ Firebase Auth initialization failed: $e');
    // Don't throw - app should continue to work
  }
}
*/
void _setupConnectivityListener() {
  Connectivity().onConnectivityChanged.listen((result) {
    // Debounce rapid connectivity changes
    final now = DateTime.now();
    if (_lastConnectivityRefresh != null && 
        now.difference(_lastConnectivityRefresh!).inSeconds < 2) {
      print('⚠️ Skipping rapid connectivity change');
      return;
    }
    _lastConnectivityRefresh = now;
    
    isOnline.value =
        result.contains(ConnectivityResult.none)
            ? Future.value(false)
            : _checkConnectivityWithTimeout();
  });
}

Future<void> _initializeTimeZone() async {
  final timeZoneName = await FlutterTimezone.getLocalTimezone();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation(timeZoneName));
}

Future<void> _initializeHive() async {
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(SettingsAdapter());
  Hive.registerAdapter(MainWeatherCacheAdapter());
  Hive.registerAdapter(LocationCacheAdapter());
  Hive.registerAdapter(WeatherCardAdapter());

  // Open boxes
  settingsBox = await Hive.openBox<Settings>('settings');
  mainWeatherCacheBox = await Hive.openBox<MainWeatherCache>(
    'mainWeatherCache',
  );
  locationCacheBox = await Hive.openBox<LocationCache>('locationCache');
  weatherCardBox = await Hive.openBox<WeatherCard>('weatherCard');

  // Load settings synchronously as they're needed immediately
  settings = settingsBox.get('main') ?? Settings();
  settings.language = 'bn_IN';

  if (settings.theme == null) {
    settings.theme = 'system';
  }

  // Save settings in background
  Future.microtask(() {
    settingsBox.put('main', settings);
  });

  // Load location cache synchronously to avoid race conditions
  locationCache = locationCacheBox.get('main') ?? LocationCache();
}

Future<void> _initializeNotifications() async {
  // Create notification channels for each topic (Android only)
  if (Platform.isAndroid) {
    final androidPlugin =
        flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    // Create alert channel
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        'weather_alerts',
        'Weather Alerts',
        description: 'Important weather alerts and warnings',
        importance: Importance.max,
        enableLights: true,
        ledColor: Color(0xFFFF0000),
      ),
    );
  }

  const initializationSettings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(
      // Request permissions on iOS
      requestAlertPermission: false, // We'll handle this separately
      requestBadgePermission: false,
      requestSoundPermission: false,
    ),
    linux: LinuxInitializationSettings(defaultActionName: 'ChoyRiturGolpo'),
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    // Handle notification taps
    onDidReceiveNotificationResponse: (NotificationResponse details) {
      // Get the payload (if any) and handle notification tap
      final payload = details.payload;
      if (payload != null) {
        try {
          final data = Map<String, dynamic>.from(
            jsonDecode(payload) as Map<String, dynamic>,
          );
          _handleNotificationTap(data);
        } catch (e) {
          debugPrint('Error parsing notification payload: $e');
        }
      }
    },
  );
}

// Save/refresh token to Firestore once on app start
Future<void> _syncFcmTokenOnce() async {
  try {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      final loc = locationCache;
      await FirestoreSync().saveFcmToken(
        token: token,
        latitude: loc.lat,
        longitude: loc.lon,
        district: loc.district,
        city: loc.city,
      );
    }
  } catch (e) {
    debugPrint('Failed to sync FCM token: $e');
  }
}

void _handleNotificationTap(Map<String, dynamic> data) {
  final title = data['title'] as String? ?? '';
  final message = data['body'] as String? ?? '';

  // Show full screen notification content
  Get.to(() => NotificationScreen(title: title, message: message));
}

Future<void> _setOptimalDisplayMode() async {
  final supported = await FlutterDisplayMode.supported;
  final active = await FlutterDisplayMode.active;
  final sameResolution =
      supported
          .where((m) => m.width == active.width && m.height == active.height)
          .toList()
        ..sort((a, b) => b.refreshRate.compareTo(a.refreshRate));
  final mostOptimalMode =
      sameResolution.isNotEmpty ? sameResolution.first : active;
  await FlutterDisplayMode.setPreferredMode(mostOptimalMode);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static Future<void> updateAppState(
    BuildContext context, {
    bool? newAmoledTheme,
    bool? newMaterialColor,
    bool? newRoundDegree,
    bool? newLargeElement,
    Locale? newLocale,
    int? newTimeRange,
    String? newTimeStart,
    String? newTimeEnd,
    String? newWidgetBackgroundColor,
    String? newWidgetTextColor,
  }) async {
    final state = context.findAncestorStateOfType<_MyAppState>()!;

    if (newAmoledTheme != null) state.changeAmoledTheme(newAmoledTheme);
    if (newMaterialColor != null) state.changeMarerialTheme(newMaterialColor);
    if (newRoundDegree != null) state.changeRoundDegree(newRoundDegree);
    if (newLargeElement != null) state.changeLargeElement(newLargeElement);
    if (newLocale != null) state.changeLocale(newLocale);
    if (newTimeRange != null) state.changeTimeRange(newTimeRange);
    if (newTimeStart != null) state.changeTimeStart(newTimeStart);
    if (newTimeEnd != null) state.changeTimeEnd(newTimeEnd);
    if (newWidgetBackgroundColor != null) {
      state.changeWidgetBackgroundColor(newWidgetBackgroundColor);
    }
    if (newWidgetTextColor != null) {
      state.changeWidgetTextColor(newWidgetTextColor);
    }
    // Widget theme is now fixed (glass theme with light text)
    // No settings needed for widgets
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late final ThemeController themeController;
  bool _widgetUpdatePending = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _widgetUpdatePending) {
      _widgetUpdatePending = false;
      // Update widget when app is fully resumed
      Future.delayed(const Duration(seconds: 1), () async {
        try {
          final weatherController = Get.find<WeatherController>();
          print('🔄 Processing pending widget update...');
          final success = await weatherController.updateWidget();
          print(
            success ? '✅ Widget update successful' : '❌ Widget update failed',
          );
        } catch (e) {
          print('❌ Error updating widget: $e');
        }
      });
    }
  }

  void changeAmoledTheme(bool newAmoledTheme) =>
      setState(() => amoledTheme = newAmoledTheme);

  void changeMarerialTheme(bool newMaterialColor) =>
      setState(() => materialColor = newMaterialColor);

  void changeRoundDegree(bool newRoundDegree) => // Re-adding this line
      setState(() => roundDegree = newRoundDegree); // Re-adding this line

  void changeLargeElement(bool newLargeElement) =>
      setState(() => largeElement = newLargeElement);

  void changeTimeRange(int newTimeRange) =>
      setState(() => timeRange = newTimeRange);

  void changeTimeStart(String newTimeStart) =>
      setState(() => timeStart = newTimeStart);

  void changeTimeEnd(String newTimeEnd) => setState(() => timeEnd = newTimeEnd);

  void changeLocale(Locale newLocale) => setState(() => locale = newLocale);

  void changeWidgetBackgroundColor(String newWidgetBackgroundColor) =>
      setState(() => widgetBackgroundColor = newWidgetBackgroundColor);

  void changeWidgetTextColor(String newWidgetTextColor) =>
      setState(() => widgetTextColor = newWidgetTextColor);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    themeController = Get.put(ThemeController());
    amoledTheme = settings.amoledTheme;
    materialColor = settings.materialColor;
    roundDegree = settings.roundDegree; // Re-adding this line
    largeElement = settings.largeElement;
    locale = Locale(
      settings.language!.split('_')[0],
      settings.language!.split('_')[1],
    );
    timeRange = settings.timeRange ?? 1;
    timeStart = settings.timeStart ?? '09:00';
    timeEnd = settings.timeEnd ?? '21:00';
    widgetBackgroundColor = settings.widgetBackgroundColor ?? '';
    widgetTextColor = settings.widgetTextColor ?? '';
    _setupFcmForegroundHandler();
    _setupFcmOpenedAppHandler();
    _setupFcmInitialMessageHandler();

    // Initialize widget support after app is ready
    if (Platform.isAndroid) {
      Future.microtask(() async {
        try {
          // Check if widget update was requested
          try {
            final widgetUpdateRequested = await _checkWidgetUpdateRequested();
            if (widgetUpdateRequested) {
              _widgetUpdatePending = true;
              print('⚡ Widget update requested on app start');
            }
          } catch (e) {
            print('⚠️ Error checking widget update request: $e');
          }

          // Initialize HomeWidget with error isolation
          try {
            print('🔧 Setting HomeWidget app group ID...');
            if (Platform.isIOS) {
              await HomeWidget.setAppGroupId('es.antonborri.home_widget');
            }
            print('✅ HomeWidget app group ID set');
          } catch (e) {
            print('❌ Error setting HomeWidget app group ID: $e');
            if (e.toString().contains('kotlin.Number')) {
              print('🔍 kotlin.Number error detected in setAppGroupId call');
              print('🔧 Attempting alternative widget initialization...');

              // Try without setting app group ID - some versions of the plugin have issues with this
              try {
                print(
                  '🔧 Skipping setAppGroupId and proceeding with widget setup...',
                );
                // Continue without setting app group ID
              } catch (altError) {
                print('❌ Alternative approach also failed: $altError');
                throw e; // Re-throw original error
              }
            } else {
              throw e; // Re-throw to prevent further initialization
            }
          }

          // Register background callback with error isolation
          try {
            print('🔧 Registering HomeWidget background callback...');
            await HomeWidget.registerBackgroundCallback((uri) async {
              print('🔄 HomeWidget background callback triggered');
              try {
                final weatherController = Get.find<WeatherController>();
                await weatherController.updateWidget();
                print('✅ Widget update from background completed');
              } catch (callbackError) {
                print('❌ Error in background callback: $callbackError');
              }
            });
            print('✅ Background callback registered');
          } catch (e) {
            print('❌ Error registering background callback: $e');
            if (e.toString().contains('kotlin.Number')) {
              print(
                '🔍 kotlin.Number error detected in registerBackgroundCallback call',
              );
            }
            // Don't throw here - app can continue without background callback
          }

          // Initialize widget manager with error isolation
          try {
            print('🔧 Initializing widget manager...');
            await WidgetManager.initialize();
            print('✅ Widget manager initialized');
          } catch (e) {
            print('❌ Error initializing widget manager: $e');
            if (e.toString().contains('kotlin.Number')) {
              print(
                '🔍 kotlin.Number error detected in WidgetManager.initialize call',
              );
            }
            // Don't throw here - app can continue without widget manager
          }

          // If widget update was requested, trigger it now
          if (_widgetUpdatePending) {
            try {
              final weatherController = Get.find<WeatherController>();
              print('🔄 Processing widget update request...');
              final success = await weatherController.updateWidget();
              print(
                success
                    ? '✅ Widget update successful'
                    : '❌ Widget update failed',
              );
              _widgetUpdatePending = false;
            } catch (e) {
              print('❌ Error processing widget update: $e');
              _widgetUpdatePending = false;
            }
          }
        } catch (e) {
          print('❌ Error initializing widget support: $e');
          if (e.toString().contains('kotlin.Number')) {
            print(
              '🔍 This appears to be a HomeWidget plugin issue with kotlin.Number casting',
            );
            print(
              '🔍 The app will continue to work, but widgets may not function properly',
            );
          }
        }
      });
    }
  }

  Future<bool> _checkWidgetUpdateRequested() async {
    try {
      // Check if widget update was requested via intent extras
      // This is a safer approach than using method channels
      return false; // For now, disable this check to avoid method channel errors
    } catch (e) {
      print('❌ Error checking widget update request: $e');
      return false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _showNotificationContent(RemoteMessage message) {
    final notification = message.notification;
    // Support both notification payload and data-only payload
    final title = notification?.title ?? (message.data['title'] as String? ?? '');
    final body = notification?.body ?? (message.data['body'] as String? ?? '');
    if (title.isEmpty && body.isEmpty) return;

    if (kDebugMode) {
      print('Showing notification:');
      print('Title: $title');
      print('Body: $body');
      print('Showing notification screen');
    }

    // Check if we're already showing a notification to prevent multiple screens
    if (Get.currentRoute.contains('NotificationScreen')) {
      print('⚠️ Notification screen already active, ignoring duplicate');
      return;
    }

    // Always show the improved notification screen for consistency
    // Use Get.to to properly add to navigation stack so back button works
    Get.to(() => NotificationScreen(title: title, message: body))
        ?.whenComplete(() async {
      // Show interstitial ad when notification screen is closed
      if (kDebugMode) {
        print('📱 Notification screen closed, showing interstitial ad');
      }
      await AdHelper.showInterstitialAd();
    });
  }

  void _setupFcmForegroundHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      // Debug logging
      if (kDebugMode) {
        print('FCM Message received in foreground:');
        print('From: ${message.from}');
        print('Data: ${message.data}');
        print('Title: ${message.notification?.title}');
        print('Body: ${message.notification?.body}');
      }
      // When app is in foreground, show notification screen
      _showNotificationContent(message);
    });
  }

  void _setupFcmOpenedAppHandler() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Debug logging
      if (kDebugMode) {
        print('FCM Message opened from background:');
        print('From: ${message.from}');
        print('Data: ${message.data}');
        print('Title: ${message.notification?.title}');
        print('Body: ${message.notification?.body}');
      }
      // When app is in background and notification is tapped, show notification screen
      _showNotificationContent(message);
    });
  }

  // removed inner _syncFcmToken def; using top-level _syncFcmTokenOnce()

  void _setupFcmInitialMessageHandler() {
    FirebaseMessaging.instance.getInitialMessage().then((
      RemoteMessage? message,
    ) {
      if (message != null) {
        // Debug logging
        if (kDebugMode) {
          print('FCM Initial Message:');
          print('From: ${message.from}');
          print('Data: ${message.data}');
          print('Title: ${message.notification?.title}');
          print('Body: ${message.notification?.body}');
        }
        // When app is terminated and opened from notification, show notification screen
        _showNotificationContent(message);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final edgeToEdgeAvailable = DeviceFeature().isEdgeToEdgeAvailable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: DynamicColorBuilder(
        builder: (lightColorScheme, darkColorScheme) {
          final lightMaterialTheme = lightTheme(
            lightColorScheme?.surface,
            lightColorScheme,
            edgeToEdgeAvailable,
          );
          final darkMaterialTheme = darkTheme(
            darkColorScheme?.surface,
            darkColorScheme,
            edgeToEdgeAvailable,
          );
          final darkMaterialThemeOled = darkTheme(
            oledColor,
            darkColorScheme,
            edgeToEdgeAvailable,
          );

          return GetMaterialApp(
            navigatorKey: navigatorKey,
            themeMode: themeController.theme,
            theme:
                materialColor
                    ? lightColorScheme != null
                        ? lightMaterialTheme
                        : lightTheme(
                          lightColor,
                          colorSchemeLight,
                          edgeToEdgeAvailable,
                        )
                    : lightTheme(
                      lightColor,
                      colorSchemeLight,
                      edgeToEdgeAvailable,
                    ),
            darkTheme:
                amoledTheme
                    ? materialColor
                        ? darkColorScheme != null
                            ? darkMaterialThemeOled
                            : darkTheme(
                              oledColor,
                              colorSchemeDark,
                              edgeToEdgeAvailable,
                            )
                        : darkTheme(
                          oledColor,
                          colorSchemeDark,
                          edgeToEdgeAvailable,
                        )
                    : materialColor
                    ? darkColorScheme != null
                        ? darkMaterialTheme
                        : darkTheme(
                          darkColor,
                          colorSchemeDark,
                          edgeToEdgeAvailable,
                        )
                    : darkTheme(
                      darkColor,
                      colorSchemeDark,
                      edgeToEdgeAvailable,
                    ),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            translations: Translation(),
            locale: locale,
            fallbackLocale: const Locale('bn', 'IN'),
            supportedLocales:
                appLanguages.map((e) => e['locale'] as Locale).toList(),
            debugShowCheckedModeBanner: false,
            home:
                settings.onboard
                    ? (locationCache.city == null ||
                            locationCache.district == null ||
                            locationCache.lat == null ||
                            locationCache.lon == null)
                        ? const SelectGeolocation(isStart: true)
                        : const HomePage()
                    : const OnBording(),
            title: 'Weather',
          );
        },
      ),
    );
  }
}
