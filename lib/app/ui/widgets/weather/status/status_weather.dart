import 'package:get/get.dart';

const assetImageRoot = 'assets/images/';

class StatusWeather {
  String getImageNow(
    int weather,
    String time,
    String timeDay,
    String timeNight,
  ) {
    final currentTime = DateTime.parse(time);
    final day = DateTime.parse(timeDay);
    final night = DateTime.parse(timeNight);

    final dayTime = DateTime(
      day.year,
      day.month,
      day.day,
      day.hour,
      day.minute,
    );
    final nightTime = DateTime(
      night.year,
      night.month,
      night.day,
      night.hour,
      night.minute,
    );

    switch (weather) {
      case 0:
        if (currentTime.isAfter(dayTime) && currentTime.isBefore(nightTime)) {
          return '${assetImageRoot}sun.png';
        } else {
          return '${assetImageRoot}full-moon.png';
        }
      case 1:
      case 2:
      case 3:
        if (currentTime.isAfter(dayTime) && currentTime.isBefore(nightTime)) {
          return '${assetImageRoot}cloudy.png';
        } else {
          return '${assetImageRoot}moon.png';
        }
      case 45:
      case 48:
        if (currentTime.isAfter(dayTime) && currentTime.isBefore(nightTime)) {
          return '${assetImageRoot}fog.png';
        } else {
          return '${assetImageRoot}fog_moon.png';
        }
      case 51:
      case 53:
      case 55:
      case 56:
      case 57:
      case 61:
      case 63:
      case 65:
      case 66:
      case 67:
        return '${assetImageRoot}rain.png';
      case 80:
      case 81:
      case 82:
        return '${assetImageRoot}rain-fall.png';
      case 71:
      case 73:
      case 75:
      case 77:
      case 85:
      case 86:
        return '${assetImageRoot}snow.png';
      case 95:
        return '${assetImageRoot}thunder.png';
      case 96:
      case 99:
        return '${assetImageRoot}storm.png';
      default:
        return '';
    }
  }

  String getImageNowDaily(int? weather) {
    switch (weather) {
      case 0:
        return '${assetImageRoot}sun.png';
      case 1:
      case 2:
      case 3:
        return '${assetImageRoot}cloudy.png';
      case 45:
      case 48:
        return '${assetImageRoot}fog.png';
      case 51:
      case 53:
      case 55:
      case 56:
      case 57:
      case 61:
      case 63:
      case 65:
      case 66:
      case 67:
        return '${assetImageRoot}rain.png';
      case 80:
      case 81:
      case 82:
        return '${assetImageRoot}rain-fall.png';
      case 71:
      case 73:
      case 75:
      case 77:
      case 85:
      case 86:
        return '${assetImageRoot}snow.png';
      case 95:
        return '${assetImageRoot}thunder.png';
      case 96:
      case 99:
        return '${assetImageRoot}storm.png';
      default:
        return '';
    }
  }

  String getImageToday(
    int weather,
    String time,
    String timeDay,
    String timeNight,
  ) {
    final currentTime = DateTime.parse(time);
    final day = DateTime.parse(timeDay);
    final night = DateTime.parse(timeNight);

    final dayTime = DateTime(
      day.year,
      day.month,
      day.day,
      day.hour,
      day.minute,
    );
    final nightTime = DateTime(
      night.year,
      night.month,
      night.day,
      night.hour,
      night.minute,
    );

    switch (weather) {
      case 0:
        if (currentTime.isAfter(dayTime) && currentTime.isBefore(nightTime)) {
          return '${assetImageRoot}clear_day.png';
        } else {
          return '${assetImageRoot}clear_night.png';
        }
      case 1:
      case 2:
      case 3:
        if (currentTime.isAfter(dayTime) && currentTime.isBefore(nightTime)) {
          return '${assetImageRoot}cloudy_day.png';
        } else {
          return '${assetImageRoot}cloudy_night.png';
        }
      case 45:
      case 48:
        if (currentTime.isAfter(dayTime) && currentTime.isBefore(nightTime)) {
          return '${assetImageRoot}fog_day.png';
        } else {
          return '${assetImageRoot}fog_night.png';
        }
      case 51:
      case 53:
      case 55:
      case 56:
      case 57:
      case 61:
      case 63:
      case 65:
      case 66:
      case 67:
      case 80:
      case 81:
      case 82:
        if (currentTime.isAfter(dayTime) && currentTime.isBefore(nightTime)) {
          return '${assetImageRoot}rain_day.png';
        } else {
          return '${assetImageRoot}rain_night.png';
        }
      case 71:
      case 73:
      case 75:
      case 77:
      case 85:
      case 86:
        if (currentTime.isAfter(dayTime) && currentTime.isBefore(nightTime)) {
          return '${assetImageRoot}snow_day.png';
        } else {
          return '${assetImageRoot}snow_night.png';
        }
      case 95:
      case 96:
      case 99:
        if (currentTime.isAfter(dayTime) && currentTime.isBefore(nightTime)) {
          return '${assetImageRoot}thunder_day.png';
        } else {
          return '${assetImageRoot}thunder_night.png';
        }
      default:
        return '';
    }
  }

  String getImage7Day(int? weather) {
    switch (weather) {
      case 0:
        return '${assetImageRoot}clear_day.png';
      case 1:
      case 2:
      case 3:
        return '${assetImageRoot}cloudy_day.png';
      case 45:
      case 48:
        return '${assetImageRoot}fog_day.png';
      case 51:
      case 53:
      case 55:
      case 56:
      case 57:
      case 61:
      case 63:
      case 65:
      case 66:
      case 67:
      case 80:
      case 81:
      case 82:
        return '${assetImageRoot}rain_day.png';
      case 71:
      case 73:
      case 75:
      case 77:
      case 85:
      case 86:
        return '${assetImageRoot}snow_day.png';
      case 95:
      case 96:
      case 99:
        return '${assetImageRoot}thunder_day.png';
      default:
        return '';
    }
  }

  String getText(int? weather) {
    switch (weather) {
      case 0:
        return 'clear_sky'.tr;
      case 1:
        return 'cloudy'.tr;
      case 2:
        return 'scattered_clouds'.tr;
      case 3:
        return 'overcast'.tr;
      case 45:
      case 48:
        return 'fog'.tr;
      case 51:
        return 'light_drizzle'.tr;
      case 53:
        return 'drizzle'.tr;
      case 55:
        return 'heavy_drizzle'.tr;
      case 56:
      case 57:
        return 'freezing_drizzle'.tr;
      case 61:
        return 'light_rain'.tr;
      case 63:
        return 'mid_rain'.tr;
      case 65:
        return 'heavy_rain'.tr;
      case 66:
      case 67:
        return 'freezing_rain_2'.tr;
      case 80:
        return 'light_rain_showers'.tr;
      case 81:
        return 'rain_showers'.tr;
      case 82:
        return 'heavy_rain_showers'.tr;
      case 71:
      case 73:
      case 75:
      case 77:
      case 85:
      case 86:
        return 'snow'.tr;
      case 95:
        return 'thunderstorm'.tr;
      case 96:
      case 99:
        return 'heavy_thunderstorm'.tr;
      default:
        return '';
    }
  }

  String getImageNotification(
    int weather,
    String time,
    String timeDay,
    String timeNight,
  ) {
    final currentTime = DateTime.parse(time);
    final day = DateTime.parse(timeDay);
    final night = DateTime.parse(timeNight);

    final dayTime = DateTime(
      day.year,
      day.month,
      day.day,
      day.hour,
      day.minute,
    );
    final nightTime = DateTime(
      night.year,
      night.month,
      night.day,
      night.hour,
      night.minute,
    );

    switch (weather) {
      case 0:
        if (currentTime.isAfter(dayTime) && currentTime.isBefore(nightTime)) {
          return 'sun.png';
        } else {
          return 'full-moon.png';
        }
      case 1:
      case 2:
      case 3:
        if (currentTime.isAfter(dayTime) && currentTime.isBefore(nightTime)) {
          return 'cloudy.png';
        } else {
          return 'moon.png';
        }
      case 45:
      case 48:
        if (currentTime.isAfter(dayTime) && currentTime.isBefore(nightTime)) {
          return 'fog.png';
        } else {
          return 'fog_moon.png';
        }
      case 51:
      case 53:
      case 55:
      case 56:
      case 57:
      case 61:
      case 63:
      case 65:
      case 66:
      case 67:
        return 'rain.png';
      case 80:
      case 81:
      case 82:
        return 'rain-fall.png';
      case 71:
      case 73:
      case 75:
      case 77:
      case 85:
      case 86:
        return 'snow.png';
      case 95:
        return 'thunder.png';
      case 96:
      case 99:
        return 'storm.png';
      default:
        return '';
    }
  }

  String getWeatherImpact(int? weather) {
    switch (weather) {
      case 0:
      case 1:
        return 'weather_impact_clear'.tr;
      case 2:
      case 3:
        return 'weather_impact_cloudy'.tr;
      case 45:
      case 48:
        return 'weather_impact_fog'.tr;
      case 51:
      case 53:
      case 55:
      case 61:
      case 63:
        return 'weather_impact_rain'.tr;
      case 65:
      case 66:
      case 67:
      case 80:
      case 81:
      case 82:
        return 'weather_impact_heavy_rain'.tr;
      case 95:
      case 96:
      case 99:
        return 'weather_impact_storm'.tr;
      default:
        return '';
    }
  }

  String getTemperatureFeel(double temperature) {
    if (temperature >= 35) {
      return 'feels_very_hot'.tr;
    } else if (temperature >= 30) {
      return 'feels_hot'.tr;
    } else if (temperature >= 25) {
      return 'feels_warm'.tr;
    } else if (temperature >= 20) {
      return 'feels_pleasant'.tr;
    } else if (temperature >= 15) {
      return 'feels_cool'.tr;
    } else if (temperature >= 10) {
      return 'feels_cold'.tr;
    } else {
      return 'feels_very_cold'.tr;
    }
  }

  String getWindDescription(double windSpeed) {
    if (windSpeed < 5) {
      return 'wind_calm'.tr;
    } else if (windSpeed < 15) {
      return 'wind_light'.tr;
    } else if (windSpeed < 25) {
      return 'wind_moderate'.tr;
    } else if (windSpeed < 35) {
      return 'wind_strong'.tr;
    } else {
      return 'wind_storm'.tr;
    }
  }

  String getHumidityDescription(int humidity) {
    if (humidity < 40) {
      return 'humidity_low'.tr;
    } else if (humidity < 70) {
      return 'humidity_normal'.tr;
    } else {
      return 'humidity_high'.tr;
    }
  }

  String getTimeBasedGreeting(DateTime time) {
    final hour = time.hour;
    if (hour >= 5 && hour < 12) {
      return 'morning_weather'.tr;
    } else if (hour >= 12 && hour < 17) {
      return 'afternoon_weather'.tr;
    } else if (hour >= 17 && hour < 20) {
      return 'evening_weather'.tr;
    } else {
      return 'night_weather'.tr;
    }
  }
}
