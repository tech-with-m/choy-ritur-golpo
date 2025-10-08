import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:get/get.dart';

class WeatherAlertDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? imageUrl;
  final String? alertType;

  const WeatherAlertDialog({
    super.key,
    required this.title,
    required this.message,
    this.imageUrl,
    this.alertType,
  });

  IconData _getAlertIcon() {
    // You can expand this based on your alert types
    switch (alertType?.toLowerCase()) {
      case 'rain':
      case 'heavy_rain':
        return IconsaxPlusBold.cloud;
      case 'storm':
        return IconsaxPlusBold.cloud_lightning;
      case 'cyclone':
        return IconsaxPlusBold.wind;
      case 'flood':
        return IconsaxPlusBold.cloud_drizzle;
      default:
        return IconsaxPlusBold.notification_bing;
    }
  }

  Color _getAlertColor() {
    // You can expand this based on your alert types
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Alert Header with Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getAlertColor().withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(_getAlertIcon(), 
                  color: _getAlertColor(),
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _getAlertColor(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Alert Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl!,
                      height: 150,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),

          // Action Button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: _getAlertColor(),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('বুঝেছি', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}