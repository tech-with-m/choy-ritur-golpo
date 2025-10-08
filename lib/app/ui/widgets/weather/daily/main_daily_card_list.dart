import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:choy_ritur_golpo/app/data/hive_db.dart';
import 'package:choy_ritur_golpo/app/ui/widgets/weather/daily/daily_card_info.dart';
import 'package:choy_ritur_golpo/app/ui/widgets/weather/daily/daily_card.dart';

class MainDailyCardList extends StatefulWidget {
  const MainDailyCardList({super.key, required this.weatherData});
  final WeatherCard weatherData;

  @override
  State<MainDailyCardList> createState() => _MainDailyCardListState();
}

class _MainDailyCardListState extends State<MainDailyCardList> {
  @override
  Widget build(BuildContext context) {
    final weatherData = widget.weatherData;
    final timeDaily = weatherData.timeDaily ?? [];

    return Container(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: timeDaily.length - 1,
        itemBuilder: (context, index) {
          final actualIndex = index + 1;
          return DailyCard(
            timeDaily: timeDaily[actualIndex],
            weathercodeDaily: weatherData.weathercodeDaily![actualIndex],
            temperature2MMax: weatherData.temperature2MMax![actualIndex],
            temperature2MMin: weatherData.temperature2MMin![actualIndex],
            isFirstCard: index == 0,
          );
        },
      ),
    );
  }
} 