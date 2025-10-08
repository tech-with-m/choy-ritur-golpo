import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gap/gap.dart';
import 'package:choy_ritur_golpo/app/ui/widgets/weather/status/status_data.dart';

class SunsetSunrise extends StatefulWidget {
  const SunsetSunrise({
    super.key,
    required this.timeSunrise,
    required this.timeSunset,
  });

  final String timeSunrise;
  final String timeSunset;

  @override
  State<SunsetSunrise> createState() => _SunsetSunriseState();
}

class _SunsetSunriseState extends State<SunsetSunrise> {
  final statusData = StatusData();

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final titleSmall = textTheme.titleSmall;
    final titleLarge = textTheme.titleLarge;

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      color: Colors.green.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.green.shade200),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'sunrise'.tr,
                          style: titleSmall?.copyWith(
                            color: Colors.green.shade600,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Gap(2),
                        Text(
                          statusData.getSunriseSunsetTimeFormat(widget.timeSunrise),
                          style: titleLarge?.copyWith(
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(5),
                  Flexible(
                    child: Image.asset('assets/images/sunrise.png', scale: 10),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'sunset'.tr,
                          style: titleSmall?.copyWith(
                            color: Colors.green.shade600,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Gap(2),
                        Text(
                          statusData.getSunriseSunsetTimeFormat(widget.timeSunset),
                          style: titleLarge?.copyWith(
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(5),
                  Flexible(
                    child: Image.asset('assets/images/sunset.png', scale: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
