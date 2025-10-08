import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:bangla_utilities/bangla_utilities.dart';
import 'package:choy_ritur_golpo/app/ui/widgets/weather/status/status_data.dart';
import 'package:choy_ritur_golpo/app/ui/widgets/weather/status/status_weather.dart';
import 'package:choy_ritur_golpo/main.dart';

class Now extends StatefulWidget {
  const Now({
    super.key,
    required this.weather,
    required this.degree,
    required this.time,
    required this.timeDay,
    required this.timeNight,
    required this.tempMax,
    required this.tempMin,
    required this.feels,
  });
  final String time;
  final String timeDay;
  final String timeNight;
  final int weather;
  final double degree;
  final double tempMax;
  final double tempMin;
  final double feels;

  @override
  State<Now> createState() => _NowState();
}

class _NowState extends State<Now> {
  final statusWeather = StatusWeather();
  final statusData = StatusData();

  @override
  Widget build(BuildContext context) {
    String dateString = DateFormat.MMMMEEEEd(
      locale.languageCode,
    ).format(DateTime.parse(widget.time));
    
    // Calculate Bangla date components
    final dateTime = DateTime.parse(widget.time);
    final banglaDate = BanglaUtility.getBanglaDay(day: dateTime.day, month: dateTime.month, year: dateTime.year);
    final banglaMonth = BanglaUtility.getBanglaMonthName(day: dateTime.day, month: dateTime.month, year: dateTime.year);
    
    if (locale.languageCode == 'bn') {
      dateString = 'আজ ' + dateString;
    }
    final double mainFontSize = 32;
    final mainFontWeight = FontWeight.w800;

    return Card(
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
          vertical: 18,
          horizontal: 22,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateString,
                    style: context.textTheme.labelLarge?.copyWith(
                      color: Colors.grey.shade700,
                      fontSize: 16,
                    ),
                  ),
                  if (locale.languageCode == 'bn') ...[
                    const Gap(4),
                    Text(
                      '$banglaDate $banglaMonth',
                      style: context.textTheme.labelLarge?.copyWith(
                        color: Colors.grey.shade700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                  const Gap(10),
                  Text(
                    statusWeather.getText(widget.weather),
                    style: context.textTheme.displayLarge?.copyWith(
                      fontSize: mainFontSize,
                      fontWeight: mainFontWeight,
                      color: Colors.green.shade800,
                    ),
                  ),
                  const Gap(10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'feels'.tr,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade700,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        ' • ',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade700,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        statusData.getDegree(widget.feels.round()),
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const Gap(10),
                  Text(
                    statusData.getDegree(
                      widget.degree.round(),
                    ),
                    style: context.textTheme.displayLarge?.copyWith(
                      fontWeight: mainFontWeight,
                      fontSize: mainFontSize,
                      color: Colors.green.shade800,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(16),
            Image(
              image: AssetImage(
                statusWeather.getImageNow(
                  widget.weather,
                  widget.time,
                  widget.timeDay,
                  widget.timeNight,
                ),
              ),
              fit: BoxFit.contain,
              height: 130,
            ),
          ],
        ),
      ),
    );
  }
}
