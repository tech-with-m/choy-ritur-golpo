import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:choy_ritur_golpo/app/controller/controller.dart';
import 'home.dart';

class ManualLocationPage extends StatefulWidget {
  const ManualLocationPage({super.key});

  @override
  State<ManualLocationPage> createState() => _ManualLocationPageState();
}

class _ManualLocationPageState extends State<ManualLocationPage> {
  List divisions = [];
  List districts = [];
  List upazilas = [];

  Map? selectedDivision;
  Map? selectedDistrict;
  Map? selectedUpazila;

  bool isLoading = true;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    loadGeoData();
  }

  Future<void> loadGeoData() async {
    final String response = await rootBundle.loadString('assets/geo/geo_with_lat_lon.json');
    final data = json.decode(response);
    setState(() {
      divisions = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final weatherController = Get.put(WeatherController());
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'অবস্থান নির্বাচন',
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(Icons.arrow_back, size: 24),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
      ),
      body: isLoading || isProcessing
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownButtonFormField<Map>(
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'বিভাগ',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedDivision,
                    items: divisions
                        .map<DropdownMenuItem<Map>>((div) => DropdownMenuItem(
                              value: div,
                              child: Text(div['name']),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDivision = value;
                        selectedDistrict = null;
                        selectedUpazila = null;
                        districts = value?['districts'] ?? [];
                        upazilas = [];
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<Map>(
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'জেলা',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedDistrict,
                    items: districts
                        .map<DropdownMenuItem<Map>>((dist) => DropdownMenuItem(
                              value: dist,
                              child: Text(dist['name']),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDistrict = value;
                        selectedUpazila = null;
                        upazilas = value?['upazilas'] ?? [];
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<Map>(
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'উপজেলা',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedUpazila,
                    items: upazilas
                        .map<DropdownMenuItem<Map>>((upa) => DropdownMenuItem(
                              value: upa,
                              child: Text(upa['name']),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedUpazila = value;
                      });
                    },
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: selectedUpazila == null || selectedDistrict == null
                          ? null
                          : () async {
                              setState(() => isProcessing = true);
                              try {
                                await weatherController.deleteAll(true);
                                await weatherController.getLocation(
                                  selectedUpazila!['lat'],
                                  selectedUpazila!['lon'],
                                  selectedDistrict!['name'],
                                  selectedUpazila!['name'],
                                );
                                Get.off(() => const HomePage(), transition: Transition.downToUp);
                              } catch (e) {
                                Get.snackbar('ত্রুটি', 'আবহাওয়া তথ্য আনতে সমস্যা হয়েছে');
                              }
                              setState(() => isProcessing = false);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      child: const Text('আবহাওয়া দেখি'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
} 