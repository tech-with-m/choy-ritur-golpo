import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:choy_ritur_golpo/app/controller/controller.dart';
import 'package:choy_ritur_golpo/app/data/hive_db.dart';
import 'package:choy_ritur_golpo/app/ui/widgets/weather/daily/daily_card_list.dart';
import 'package:choy_ritur_golpo/app/ui/widgets/weather/daily/daily_container.dart';
import 'package:choy_ritur_golpo/app/ui/widgets/weather/desc/desc_container.dart';
import 'package:choy_ritur_golpo/app/ui/widgets/weather/hourly.dart';
import 'package:choy_ritur_golpo/app/ui/widgets/weather/now.dart';
import 'package:choy_ritur_golpo/app/ui/widgets/shimmer.dart';
import 'package:choy_ritur_golpo/app/ui/widgets/weather/sunset_sunrise.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:choy_ritur_golpo/app/ui/widgets/weather/daily/main_daily_card_list.dart';
import 'package:choy_ritur_golpo/main.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final weatherController = Get.put(WeatherController());

  String _formatCacheAge(DateTime? timestamp) {
    if (timestamp == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'just_now'.tr;
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${'minutes_ago'.tr}';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${'hours_ago'.tr}';
    } else {
      return '${difference.inDays} ${'days_ago'.tr}';
    }
  }

  Widget _buildOfflineIndicator(DateTime? cacheTimestamp) {
    return FutureBuilder<bool>(
      future: isOnline.value,
      builder: (context, snapshot) {
        final online = snapshot.data ?? true;
        
        // Only show indicator if offline and we have cached data
        if (online || cacheTimestamp == null) {
          return const SizedBox.shrink();
        }
        
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.shade200, width: 1.5),
          ),
          child: Row(
            children: [
              Icon(
                Icons.cloud_off,
                color: Colors.orange.shade700,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'offline_mode'.tr,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade900,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${'cached_data'.tr} • ${'last_updated'.tr}: ${_formatCacheAge(cacheTimestamp)}',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await weatherController.deleteAll(false);
        await weatherController.setLocation(forceRefresh: true);
        setState(() {});
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Obx(() {
          // Force check if we have data even if loading is true (safety net)
          final hasData = weatherController.mainWeather.time != null && 
                         weatherController.mainWeather.time!.isNotEmpty;
          
          if (weatherController.isLoading.isTrue && !hasData) {
            return ListView(
              children: const [
                MyShimmer(hight: 200),
                MyShimmer(
                  hight: 130,
                  edgeInsetsMargin: EdgeInsets.symmetric(vertical: 15),
                ),
                MyShimmer(
                  hight: 90,
                  edgeInsetsMargin: EdgeInsets.only(bottom: 15),
                ),
                MyShimmer(
                  hight: 400,
                  edgeInsetsMargin: EdgeInsets.only(bottom: 15),
                ),
                MyShimmer(
                  hight: 450,
                  edgeInsetsMargin: EdgeInsets.only(bottom: 15),
                ),
              ],
            );
          }

          final mainWeather = weatherController.mainWeather;
          
          // Simple check: if we have time data, we have complete weather data
          if (mainWeather.time == null || mainWeather.time!.isEmpty) {
            // No weather data - show error message
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.wifi_off,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'no_weather_data'.tr,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'check_internet'.tr,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          final weatherCard = WeatherCard.fromJson(mainWeather.toJson());
          final hourOfDay = weatherController.hourOfDay.value;
          final dayOfNow = weatherController.dayOfNow.value;
          
          // Safe array access with bounds checking
          final safeHourIndex = hourOfDay < mainWeather.time!.length ? hourOfDay : 0;
          final safeDayIndex = dayOfNow < (mainWeather.sunrise?.length ?? 0) ? dayOfNow : 0;
          
          final sunrise = mainWeather.sunrise![safeDayIndex];
          final sunset = mainWeather.sunset![safeDayIndex];
          final tempMax = mainWeather.temperature2MMax![safeDayIndex];
          final tempMin = mainWeather.temperature2MMin![safeDayIndex];

          return ListView(
            children: [
              // Offline indicator (only shows when offline with cached data)
              _buildOfflineIndicator(mainWeather.timestamp),
              Now(
                time: mainWeather.time![safeHourIndex],
                weather: mainWeather.weathercode![safeHourIndex],
                degree: mainWeather.temperature2M![safeHourIndex],
                feels: mainWeather.apparentTemperature![safeHourIndex]!,
                timeDay: sunrise,
                timeNight: sunset,
                tempMax: tempMax!,
                tempMin: tempMin!,
              ),
              Card(
                margin: const EdgeInsets.only(bottom: 15),
                color: Colors.green.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.green.shade200, width: 2),
                ),
                elevation: 2,
                shadowColor: Colors.grey.shade200,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: SizedBox(
                    height: 135,
                    child: ScrollablePositionedList.separated(
                      key: const PageStorageKey(0),
                      separatorBuilder: (BuildContext context, int index) {
                        return const VerticalDivider(
                          width: 10,
                          indent: 40,
                          endIndent: 40,
                        );
                      },
                      scrollDirection: Axis.horizontal,
                      itemScrollController:
                          weatherController.itemScrollController,
                      itemCount: mainWeather.time!.length,
                      itemBuilder: (ctx, i) {
                        final i24 = (i / 24).floor();

                        return GestureDetector(
                          onTap: () {
                            weatherController.hourOfDay.value = i;
                            weatherController.dayOfNow.value = i24;
                            setState(() {});
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  i == hourOfDay
                                      ? Colors.green.shade100
                                      : Colors.transparent,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                            child: Hourly(
                              time: mainWeather.time![i],
                              weather: mainWeather.weathercode![i],
                              degree: mainWeather.temperature2M![i],
                              timeDay: mainWeather.sunrise![i24 < mainWeather.sunrise!.length ? i24 : 0],
                              timeNight: mainWeather.sunset![i24 < mainWeather.sunset!.length ? i24 : 0],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              SunsetSunrise(timeSunrise: sunrise, timeSunset: sunset),
              MainDailyCardList(
                weatherData: weatherCard,
              ),
            ],
          );
        }),
      ),
    );
  }
}
