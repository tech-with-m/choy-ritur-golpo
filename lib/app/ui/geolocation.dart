import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:latlong2/latlong.dart';
import 'package:choy_ritur_golpo/app/api/api.dart';
import 'package:choy_ritur_golpo/app/api/city_api.dart';
import 'package:choy_ritur_golpo/app/controller/controller.dart';
import 'package:choy_ritur_golpo/app/ui/home.dart';
import 'package:choy_ritur_golpo/app/ui/widgets/button.dart';
import 'package:choy_ritur_golpo/app/ui/widgets/text_form.dart';
import 'package:choy_ritur_golpo/main.dart';
import 'manual_location.dart';

import '../utils/show_snack_bar.dart';

class SelectGeolocation extends StatefulWidget {
  const SelectGeolocation({super.key, required this.isStart});
  final bool isStart;

  @override
  State<SelectGeolocation> createState() => _SelectGeolocationState();
}

class _SelectGeolocationState extends State<SelectGeolocation> {
  bool isLoading = false;
  final formKeySearch = GlobalKey<FormState>();
  final _focusNode = FocusNode();
  final weatherController = Get.put(WeatherController());
  final _controller = TextEditingController();
  final _controllerLat = TextEditingController();
  final _controllerLon = TextEditingController();
  final _controllerCity = TextEditingController();
  final _controllerDistrict = TextEditingController();

  static const colorFilter = ColorFilter.matrix(<double>[
    -0.2, -0.7, -0.08, 0, 255, // Red channel
    -0.2, -0.7, -0.08, 0, 255, // Green channel
    -0.2, -0.7, -0.08, 0, 255, // Blue channel
    0, 0, 0, 1, 0, // Alpha channel
  ]);

  final bool _isDarkMode = Get.theme.brightness == Brightness.dark;

  final mapController = MapController();

  textTrim(value) {
    value.text = value.text.trim();
    while (value.text.contains('  ')) {
      value.text = value.text.replaceAll('  ', ' ');
    }
  }

  void fillController(selection) {
    _controllerLat.text = '${selection.latitude}';
    _controllerLon.text = '${selection.longitude}';
    _controllerCity.text = selection.name;
    _controllerDistrict.text = selection.admin1;
    _controller.clear();
    _focusNode.unfocus();
    setState(() {});
  }

  void fillControllerGeo(location) {
    _controllerLat.text = '${location['lat']}';
    _controllerLon.text = '${location['lon']}';
    _controllerCity.text = location['district'];
    _controllerDistrict.text = location['city'];
    setState(() {});
  }

  void fillMap(double latitude, double longitude) {
    _controllerLat.text = '$latitude';
    _controllerLon.text = '$longitude';
    setState(() {});
  }

  Widget _buildMapTileLayer() {
    return TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.tech_with_m.choy_ritur_golpo',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: widget.isStart
            ? null
            : IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: const Icon(Icons.arrow_back, size: 24),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
        automaticallyImplyLeading: false,
        title: Text(
          'অবস্থান নির্বাচন',
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'সঠিক আবহাওয়া তথ্য দিতে আপনার এলাকাটির অবস্থান দরকার',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                    const SizedBox(height: 40),
                    MyTextButton(
                      buttonName: 'অবস্থান জানতে অনুমতি দিই',
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                      icon: const Icon(Icons.location_on, color: Colors.white),
                      onPressed: () async {
                        setState(() => isLoading = true);
                        try {
                          final location = await weatherController.getCurrentLocationSearch();
                          await weatherController.deleteAll(true);
                          await weatherController.getLocation(
                            location['lat'],
                            location['lon'],
                            location['district'],
                            location['city'],
                          );
                          if (widget.isStart) {
                            Get.off(() => const HomePage(), transition: Transition.downToUp);
                          } else {
                            Get.back();
                          }
                        } catch (e) {
                          showSnackBar(content: 'অবস্থান অনুমতি পাওয়া যায়নি');
                        }
                        setState(() => isLoading = false);
                      },
                    ),
                    const SizedBox(height: 16),
                    MyTextButton(
                      buttonName: 'নিজে অবস্থান নির্বাচন করি',
                      borderColor: Colors.green,
                      textColor: Colors.green,
                      icon: const Icon(IconsaxPlusLinear.map, color: Colors.green),
                      onPressed: () {
                        // Navigate to the manual selection page
                        Get.to(() => const ManualLocationPage(), transition: Transition.downToUp);
                      },
                    ),
                  ],
                ),
              ),
            ),
            if (isLoading)
              BackdropFilter(
                filter: ImageFilter.blur(sigmaY: 3, sigmaX: 3),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
