import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:choy_ritur_golpo/app/ui/widgets/weather/status/status_weather.dart';
import 'package:choy_ritur_golpo/app/ui/widgets/weather/status/status_data.dart';
import 'package:choy_ritur_golpo/main.dart';

class DailyCard extends StatefulWidget {
  const DailyCard({
    super.key,
    required this.timeDaily,
    required this.weathercodeDaily,
    required this.temperature2MMax,
    required this.temperature2MMin,
    required this.isFirstCard,
  });
  final DateTime timeDaily;
  final int? weathercodeDaily;
  final double? temperature2MMax;
  final double? temperature2MMin;
  final bool isFirstCard;

  @override
  State<DailyCard> createState() => _DailyCardState();
}

class _DailyCardState extends State<DailyCard> {
  final statusWeather = StatusWeather();
  final statusData = StatusData();

  @override
  Widget build(BuildContext context) {
    return widget.weathercodeDaily == null
        ? Container()
        : Container(
            margin: const EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isFirstCard 
                              ? 'আগামীকাল, ${DateFormat(
                                  'EEEE, d MMMM',
                                  locale.languageCode,
                                ).format(DateTime.tryParse(widget.timeDaily.toString())!)}'
                              : DateFormat(
                                  'EEEE, d MMMM',
                                  locale.languageCode,
                                ).format(DateTime.tryParse(widget.timeDaily.toString())!),
                          style: context.textTheme.titleLarge?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          statusWeather.getText(widget.weathercodeDaily!),
                          style: context.textTheme.titleMedium?.copyWith(
                            fontSize: 16,
                            color: Colors.green.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${statusData.getDegree(widget.temperature2MMin?.round())} / ${statusData.getDegree(widget.temperature2MMax?.round())}',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: Colors.green.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Image.asset(
                    statusWeather.getImageNowDaily(widget.weathercodeDaily),
                    width: 50,
                    height: 50,
                  ),
                ],
              ),
            ),
          );
  }
}
