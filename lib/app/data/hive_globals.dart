import 'package:hive/hive.dart';
import 'hive_db.dart';

// Global Hive boxes
late Box<Settings> settingsBox;
late Box<MainWeatherCache> mainWeatherCacheBox;
late Box<LocationCache> locationCacheBox;
late Box<WeatherCard> weatherCardBox;

// Global instances (for compatibility with existing code)
late Settings settings;
late LocationCache locationCache;