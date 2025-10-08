import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:get/get.dart';

class WeatherAlertScreen extends StatelessWidget {
  final String title;
  final String message;
  final String? imageUrl;
  final String? alertType;
  final DateTime? timestamp;
  final Map<String, dynamic>? additionalData;

  const WeatherAlertScreen({
    super.key,
    required this.title,
    required this.message,
    this.imageUrl,
    this.alertType,
    this.timestamp,
    this.additionalData,
  });

  Color _getAlertColor() {
    switch (alertType?.toLowerCase()) {
      case 'severe':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      case 'alert':
        return Colors.amber;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('আবহাওয়া সতর্কতা'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Alert Header
            Container(
              color: _getAlertColor().withOpacity(0.1),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        IconsaxPlusBold.notification_bing,
                        color: _getAlertColor(),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _getAlertColor(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (timestamp != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      // Format timestamp in Bangla
                      timestamp!.toString(),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Alert Image
            if (imageUrl != null)
              Image.network(
                imageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),

            // Alert Message
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  if (additionalData != null) ...[
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 20),
                    // Add additional weather data here
                    _buildAdditionalData(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: _getAlertColor(),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('ফিরে যাই', style: TextStyle(fontSize: 16)),
          ),
        ),
      ),
    );
  }

  Widget _buildAdditionalData() {
    if (additionalData == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'অতিরিক্ত তথ্য',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        // Add your additional weather data widgets here
        // Example:
        // - Wind speed
        // - Temperature
        // - Humidity
        // - Rainfall prediction
        // etc.
      ],
    );
  }
}