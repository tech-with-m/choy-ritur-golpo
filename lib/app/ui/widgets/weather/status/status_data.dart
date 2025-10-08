import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:choy_ritur_golpo/app/data/hive_globals.dart';
import 'package:choy_ritur_golpo/main.dart';
import 'package:timezone/timezone.dart';

String convertToBanglaDigits(String input) {
  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const bangla  = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
  for (int i = 0; i < english.length; i++) {
    input = input.replaceAll(english[i], bangla[i]);
  }
  return input;
}

class StatusData {
  String getDegree(dynamic degree) {
    String degreeString = degree.toString().trim();

    // Check if the string contains known units
    bool hasCelsius = degreeString.contains('°C');
    bool hasFahrenheit = degreeString.contains('°F');
    bool hasOnlyDegreeSymbol = degreeString.contains('°') && !hasCelsius && !hasFahrenheit;

    // Add unit if needed
    if (!hasCelsius && !hasFahrenheit) {
      // Remove any standalone ° symbol (e.g., "25°" or just "°")
      degreeString = degreeString.replaceAll('°', '');

      switch (settings.degrees) {
        case 'fahrenheit':
          degreeString += '°F';
          break;
        case 'celsius':
        default:
          degreeString += '°C';
          break;
      }
    }

    // Convert to Bangla if needed
    if (locale.languageCode == 'bn') {
      degreeString = convertToBanglaDigits(degreeString);
    }

    return degreeString;
  }



  String getSpeed(int? speed) {
    if (speed == null) return '';
    String value;
    String unit;
    if (settings.measurements == 'metric') {
      unit = 'kph'.tr;
      value = speed.toString();
      if (settings.wind == 'm/s') {
        unit = 'm/s'.tr;
        value = (speed * (5 / 18)).toStringAsFixed(1);
      }
    } else {
      unit = 'mph'.tr;
      value = speed.toString();
    }
    String result = '$value $unit';
    if (locale.languageCode == 'bn') {
      result = convertToBanglaDigits(result);
    }
    return result;
  }

  String getPressure(int? pressure) {
    if (pressure == null) return '';
    String value;
    String unit;
    if (settings.pressure == 'mmHg') {
      unit = 'mmHg'.tr;
      value = (pressure * (3 / 4)).toStringAsFixed(1);
    } else {
      unit = 'hPa'.tr;
      value = pressure.toString();
    }
    String result = '$value $unit';
    if (locale.languageCode == 'bn') {
      result = convertToBanglaDigits(result);
    }
    return result;
  }

  String getVisibility(double? length) {
    if (length == null) return '';
    String value;
    String unit;
    if (settings.measurements == 'metric') {
      unit = 'km'.tr;
      value = (length / 1000).toStringAsFixed(length > 1000 ? 0 : 2);
    } else {
      unit = 'mi'.tr;
      value = (length / 5280).toStringAsFixed(length > 5280 ? 0 : 2);
    }
    String result = '$value $unit';
    if (locale.languageCode == 'bn') {
      result = convertToBanglaDigits(result);
    }
    return result;
  }

  String getPrecipitation(double? precipitation) {
    if (precipitation == null) return '';
    String value = precipitation.toString();
    String unit;
    switch (settings.measurements) {
      case 'metric':
        unit = 'mm'.tr;
        break;
      case 'imperial':
        unit = 'inch'.tr;
        break;
      default:
        unit = 'mm'.tr;
        break;
    }
    String result = '$value $unit';
    if (locale.languageCode == 'bn') {
      result = convertToBanglaDigits(result);
    }
    return result;
  }

  String getTimeFormat(String time) {
    final dateTime = DateTime.tryParse(time);
    if (dateTime == null) return '';
    String formatPattern;
    switch (settings.timeformat) {
      case '12':
        formatPattern = 'h:mm a';
        break;
      case '24':
        formatPattern = 'HH:mm';
        break;
      default:
        formatPattern = 'HH:mm';
        break;
    }
    final formattedTime = DateFormat(formatPattern, 'en_US').format(dateTime);
    if (locale.languageCode == 'bn') {
      return convertToBanglaDigits(formattedTime);
    }
    return formattedTime;
  }

  String getTimeFormatTz(TZDateTime time) {
    String formatPattern;
    switch (settings.timeformat) {
      case '12':
        formatPattern = 'h:mm a';
        break;
      case '24':
        formatPattern = 'HH:mm';
        break;
      default:
        formatPattern = 'HH:mm';
        break;
    }
    final formattedTime = DateFormat(formatPattern, 'en_US').format(time);
    if (locale.languageCode == 'bn') {
      return convertToBanglaDigits(formattedTime);
    }
    return formattedTime;
  }

  String getSunriseSunsetTimeFormat(String time) {
    final dateTime = DateTime.tryParse(time);
    if (dateTime == null) return '';
    String formatPattern;
    String timePrefix = '';
    
    switch (settings.timeformat) {
      case '12':
        formatPattern = 'h:mm';
        if (locale.languageCode == 'bn') {
          timePrefix = dateTime.hour < 12 ? 'সকাল ' : 'সন্ধ্যা ';
        }
        break;
      case '24':
        formatPattern = 'HH:mm';
        break;
      default:
        formatPattern = 'HH:mm';
        break;
    }
    final formattedTime = DateFormat(formatPattern, 'en_US').format(dateTime);
    final result = timePrefix + formattedTime;
    if (locale.languageCode == 'bn') {
      return convertToBanglaDigits(result);
    }
    return result;
  }
}
