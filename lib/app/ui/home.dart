import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:choy_ritur_golpo/app/controller/controller.dart';
import 'package:choy_ritur_golpo/app/data/hive_db.dart';
import 'package:choy_ritur_golpo/app/data/hive_globals.dart';
import 'package:choy_ritur_golpo/app/data/hive_migration_helper.dart';
import 'package:choy_ritur_golpo/app/ui/places/view/season_page.dart';
import 'package:choy_ritur_golpo/app/ui/geolocation.dart';
import 'package:choy_ritur_golpo/app/ui/main/view/main.dart';
import 'package:choy_ritur_golpo/app/utils/show_snack_bar.dart';
// import 'package:choy_ritur_golpo/app/utils/ad_helper.dart'; // DISABLED FOR OFFLINE TESTING
import 'package:choy_ritur_golpo/main.dart';
import 'package:choy_ritur_golpo/app/utils/notification_permission_manager.dart';
import 'package:choy_ritur_golpo/app/ui/widgets/notification_prompt_dialog.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart'; // DISABLED FOR OFFLINE TESTING

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int tabIndex = 0;
  bool visible = false;
  final _focusNode = FocusNode();
  late TabController tabController;
  final weatherController = Get.put(WeatherController());
  final _controller = TextEditingController();
  // BannerAd? _bannerAd; // DISABLED
  // bool _isBannerAdLoaded = false; // DISABLED

  final List<Widget> pages = [
    const MainPage(),
    const SeasonPage()
    //if (!settings.hideMap) const MapPage(),
    //const SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    // CRITICAL: Ensure loading is false on init to prevent blank page
    // This handles the case where UI renders before onInit completes
    if (weatherController.mainWeather.time != null && 
        weatherController.mainWeather.time!.isNotEmpty) {
      weatherController.isLoading.value = false;
    }
    getData();
    setupTabController();
    // ADS DISABLED FOR OFFLINE FUNCTIONALITY
    // AdHelper.loadInterstitialAd();
    // _loadBannerAd();
    
    // Schedule notification permission request
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        _maybeRequestNotificationPermission();
      }
    });
  }

  Future<void> _maybeRequestNotificationPermission() async {
    final shouldAsk = await NotificationPermissionManager.shouldAskForPermission();
    if (shouldAsk && mounted) {
      // Show custom prompt dialog first
      final shouldProceed = await showDialog<bool>(
        context: context,
        builder: (context) => const NotificationPromptDialog(),
      );

      // Only proceed with system permission dialog if user agreed
      if (shouldProceed == true && mounted) {
        final status = await NotificationPermissionManager.requestPermission();
        if (status == AuthorizationStatus.authorized) {
          // Re-subscribe to topics if permission is granted
          await firebaseMessaging?.subscribeToTopic('general');
          await firebaseMessaging?.subscribeToTopic('alert');
          await firebaseMessaging?.subscribeToTopic('news');
        }
      }
    }
  }

  @override
  void dispose() {
    tabController.dispose();
    // _bannerAd?.dispose(); // DISABLED
    // AdHelper.dispose(); // DISABLED
    super.dispose();
  }

  void setupTabController() {
    tabController = TabController(
      initialIndex: tabIndex,
      length: pages.length,
      vsync: this,
    );

    tabController.animation?.addListener(() {
      int value = (tabController.animation!.value).round();
      if (value != tabIndex) {
        // Call handleTabChange for both UI update and ad display
        handleTabChange(value);
      }
    });

    tabController.addListener(() {
      handleTabChange(tabController.index);
    });
  }

  // Handle tab changes (ads disabled)
  void handleTabChange(int newIndex) async {
    // Only process if the tab actually changed
    if (tabIndex == newIndex) return;
    
    // ADS DISABLED - just change tab
    setState(() {
      tabIndex = newIndex;
    });
  }

  void getData() async {
    try {
      print('🏠 Home getData() started');
      
      // If cached data is already loaded, don't do anything
      if (weatherController.mainWeather.time != null && 
          weatherController.mainWeather.time!.isNotEmpty) {
        print('✅ Cached data already available, skipping getData()');
        weatherController.isLoading.value = false;
        return;
      }
      
      // CACHE-FIRST STRATEGY: Always use setLocation which loads cache first
      print('📦 Using cache-first strategy via setLocation()');
      await weatherController.setLocation();
      
      print('✅ Home getData() completed');
    } catch (e) {
      print('❌ Error in getData(): $e');
      // Ensure loading state is set to false even if there's an error
      weatherController.isLoading.value = false;
    }
  }

  void changeTabIndex(int index) {
    handleTabChange(index);
    tabController.animateTo(index);
  }

  // ADS DISABLED
  // void _loadBannerAd() { ... }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final labelLarge = textTheme.labelLarge;

    final textStyle = textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
      fontSize: 18,
    );

    return DefaultTabController(
      length: pages.length,
      child: ScaffoldMessenger(
        key: globalKey,
        child: Scaffold(
          body: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (tabIndex == 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Obx(() {
                            final location = weatherController.location;
                            final city = location.city;
                            final district = location.district;
                            final text = weatherController.isLoading.isFalse
                                ? district!.isEmpty
                                    ? '$city'
                                    : city!.isEmpty
                                    ? district
                                    : city == district
                                    ? city
                                    : '$city, $district'
                                : settings.location
                                ? 'search'.tr
                                : HiveMigrationHelper.hasLocationCache()
                                ? 'loading'.tr
                                : 'searchCity'.tr;
                            return Text(
                              text,
                              style: textStyle?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              ),
                              textAlign: TextAlign.center,
                              softWrap: true,
                            );
                          }),
                        ),
                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [


                              IconButton(
                                icon: const Icon(Icons.edit_location_alt, color: Colors.green),
                                tooltip: 'Change location',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  Get.to(
                                    () => const SelectGeolocation(isStart: false),
                                    transition: Transition.downToUp,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: TabBarView(controller: tabController, children: pages),
                ),
              ],
            ),
          ),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // BANNER ADS DISABLED
              NavigationBar(
            onDestinationSelected: (int index) => changeTabIndex(index),
            selectedIndex: tabIndex,
            destinations: [
              NavigationDestination(
                icon: const Icon(IconsaxPlusLinear.cloud_sunny),
                selectedIcon: const Icon(IconsaxPlusBold.cloud_sunny),
                label: 'abohawa'.tr,
              ),
              NavigationDestination(
                icon: Image.asset(
                  'assets/icons/tab2.png',
                  width: 26,
                  height: 26,
                ),
                selectedIcon: Image.asset(
                  'assets/icons/tab2.png',
                  width: 26,
                  height: 26,
                ),
                label: 'season_tab'.tr,
              ),
            ],
          ),
            ],
          ),
        ),
      ),
    );
  }
}
