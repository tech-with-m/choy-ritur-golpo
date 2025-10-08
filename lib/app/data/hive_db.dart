import 'package:hive/hive.dart';

part 'hive_db.g.dart';

@HiveType(typeId: 0)
class Settings extends HiveObject {
  @HiveField(0)
  bool onboard = false;
  
  @HiveField(1)
  String? theme = 'system';
  
  @HiveField(2)
  bool location = false;
  
  @HiveField(3)
  bool notifications = false;
  
  @HiveField(4)
  bool materialColor = false;
  
  @HiveField(5)
  bool amoledTheme = false;
  
  @HiveField(6)
  bool roundDegree = false;
  
  @HiveField(7)
  bool largeElement = false;
  
  @HiveField(8)
  bool hideMap = true;
  
  @HiveField(9)
  bool? glassTheme;
  
  @HiveField(10)
  bool? useLightText;
  
  @HiveField(11)
  String? widgetBackgroundColor;
  
  @HiveField(12)
  String? widgetTextColor;
  
  @HiveField(13)
  String measurements = 'metric';
  
  @HiveField(14)
  String degrees = 'celsius';
  
  @HiveField(15)
  String wind = 'kph';
  
  @HiveField(16)
  String pressure = 'hPa';
  
  @HiveField(17)
  String timeformat = '12';
  
  @HiveField(18)
  String? language = 'bn_IN';
  
  @HiveField(19)
  int? timeRange;
  
  @HiveField(20)
  String? timeStart;
  
  @HiveField(21)
  String? timeEnd;
}

@HiveType(typeId: 1)
class MainWeatherCache extends HiveObject {
  @HiveField(0)
  List<String>? time;
  
  @HiveField(1)
  List<int>? weathercode;
  
  @HiveField(2)
  List<double>? temperature2M;
  
  @HiveField(3)
  List<double?>? apparentTemperature;
  
  @HiveField(4)
  List<int?>? relativehumidity2M;
  
  @HiveField(5)
  List<double?>? precipitation;
  
  @HiveField(6)
  List<double?>? rain;
  
  @HiveField(7)
  List<double?>? surfacePressure;
  
  @HiveField(8)
  List<double?>? visibility;
  
  @HiveField(9)
  List<double?>? evapotranspiration;
  
  @HiveField(10)
  List<double?>? windspeed10M;
  
  @HiveField(11)
  List<int?>? winddirection10M;
  
  @HiveField(12)
  List<double?>? windgusts10M;
  
  @HiveField(13)
  List<int?>? cloudcover;
  
  @HiveField(14)
  List<double?>? uvIndex;
  
  @HiveField(15)
  List<double?>? dewpoint2M;
  
  @HiveField(16)
  List<int?>? precipitationProbability;
  
  @HiveField(17)
  List<double?>? shortwaveRadiation;
  
  @HiveField(18)
  List<DateTime>? timeDaily;
  
  @HiveField(19)
  List<int?>? weathercodeDaily;
  
  @HiveField(20)
  List<double?>? temperature2MMax;
  
  @HiveField(21)
  List<double?>? temperature2MMin;
  
  @HiveField(22)
  List<double?>? apparentTemperatureMax;
  
  @HiveField(23)
  List<double?>? apparentTemperatureMin;
  
  @HiveField(24)
  List<String>? sunrise;
  
  @HiveField(25)
  List<String>? sunset;
  
  @HiveField(26)
  List<double?>? precipitationSum;
  
  @HiveField(27)
  List<int?>? precipitationProbabilityMax;
  
  @HiveField(28)
  List<double?>? windspeed10MMax;
  
  @HiveField(29)
  List<double?>? windgusts10MMax;
  
  @HiveField(30)
  List<double?>? uvIndexMax;
  
  @HiveField(31)
  List<double?>? rainSum;
  
  @HiveField(32)
  List<int?>? winddirection10MDominant;
  
  @HiveField(33)
  String? timezone;
  
  @HiveField(34)
  DateTime? timestamp;

  MainWeatherCache({
    this.time,
    this.temperature2M,
    this.relativehumidity2M,
    this.apparentTemperature,
    this.precipitation,
    this.rain,
    this.weathercode,
    this.surfacePressure,
    this.visibility,
    this.evapotranspiration,
    this.windspeed10M,
    this.winddirection10M,
    this.windgusts10M,
    this.cloudcover,
    this.uvIndex,
    this.dewpoint2M,
    this.precipitationProbability,
    this.shortwaveRadiation,
    this.timeDaily,
    this.weathercodeDaily,
    this.temperature2MMax,
    this.temperature2MMin,
    this.apparentTemperatureMax,
    this.apparentTemperatureMin,
    this.sunrise,
    this.sunset,
    this.precipitationSum,
    this.precipitationProbabilityMax,
    this.windspeed10MMax,
    this.windgusts10MMax,
    this.uvIndexMax,
    this.rainSum,
    this.winddirection10MDominant,
    this.timezone,
    this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'time': time,
    'weathercode': weathercode,
    'temperature2M': temperature2M,
    'apparentTemperature': apparentTemperature,
    'relativehumidity2M': relativehumidity2M,
    'precipitation': precipitation,
    'rain': rain,
    'surfacePressure': surfacePressure,
    'visibility': visibility,
    'evapotranspiration': evapotranspiration,
    'windspeed10M': windspeed10M,
    'winddirection10M': winddirection10M,
    'windgusts10M': windgusts10M,
    'cloudcover': cloudcover,
    'uvIndex': uvIndex,
    'dewpoint2M': dewpoint2M,
    'precipitationProbability': precipitationProbability,
    'shortwaveRadiation': shortwaveRadiation,
    'timeDaily': timeDaily,
    'weathercodeDaily': weathercodeDaily,
    'temperature2MMax': temperature2MMax,
    'temperature2MMin': temperature2MMin,
    'apparentTemperatureMax': apparentTemperatureMax,
    'apparentTemperatureMin': apparentTemperatureMin,
    'sunrise': sunrise,
    'sunset': sunset,
    'precipitationSum': precipitationSum,
    'precipitationProbabilityMax': precipitationProbabilityMax,
    'windspeed10MMax': windspeed10MMax,
    'windgusts10MMax': windgusts10MMax,
    'uvIndexMax': uvIndexMax,
    'rainSum': rainSum,
    'winddirection10MDominant': winddirection10MDominant,
    'timezone': timezone,
    'timestamp': timestamp,
  };
}

@HiveType(typeId: 2)
class LocationCache extends HiveObject {
  @HiveField(0)
  double? lat;
  
  @HiveField(1)
  double? lon;
  
  @HiveField(2)
  String? city;
  
  @HiveField(3)
  String? district;

  LocationCache({this.lat, this.lon, this.city, this.district});

  Map<String, dynamic> toJson() => {
    'lat': lat,
    'lon': lon,
    'city': city,
    'district': district,
  };
}

@HiveType(typeId: 3)
class WeatherCard extends HiveObject {
  @HiveField(0)
  List<String>? time;
  
  @HiveField(1)
  List<int>? weathercode;
  
  @HiveField(2)
  List<double>? temperature2M;
  
  @HiveField(3)
  List<double?>? apparentTemperature;
  
  @HiveField(4)
  List<int?>? relativehumidity2M;
  
  @HiveField(5)
  List<double?>? precipitation;
  
  @HiveField(6)
  List<double?>? rain;
  
  @HiveField(7)
  List<double?>? surfacePressure;
  
  @HiveField(8)
  List<double?>? visibility;
  
  @HiveField(9)
  List<double?>? evapotranspiration;
  
  @HiveField(10)
  List<double?>? windspeed10M;
  
  @HiveField(11)
  List<int?>? winddirection10M;
  
  @HiveField(12)
  List<double?>? windgusts10M;
  
  @HiveField(13)
  List<int?>? cloudcover;
  
  @HiveField(14)
  List<double?>? uvIndex;
  
  @HiveField(15)
  List<double?>? dewpoint2M;
  
  @HiveField(16)
  List<int?>? precipitationProbability;
  
  @HiveField(17)
  List<double?>? shortwaveRadiation;
  
  @HiveField(18)
  List<DateTime>? timeDaily;
  
  @HiveField(19)
  List<int?>? weathercodeDaily;
  
  @HiveField(20)
  List<double?>? temperature2MMax;
  
  @HiveField(21)
  List<double?>? temperature2MMin;
  
  @HiveField(22)
  List<double?>? apparentTemperatureMax;
  
  @HiveField(23)
  List<double?>? apparentTemperatureMin;
  
  @HiveField(24)
  List<String>? sunrise;
  
  @HiveField(25)
  List<String>? sunset;
  
  @HiveField(26)
  List<double?>? precipitationSum;
  
  @HiveField(27)
  List<int?>? precipitationProbabilityMax;
  
  @HiveField(28)
  List<double?>? windspeed10MMax;
  
  @HiveField(29)
  List<double?>? windgusts10MMax;
  
  @HiveField(30)
  List<double?>? uvIndexMax;
  
  @HiveField(31)
  List<double?>? rainSum;
  
  @HiveField(32)
  List<int?>? winddirection10MDominant;
  
  @HiveField(33)
  double? lat;
  
  @HiveField(34)
  double? lon;
  
  @HiveField(35)
  String? city;
  
  @HiveField(36)
  String? district;
  
  @HiveField(37)
  String? timezone;
  
  @HiveField(38)
  DateTime? timestamp;
  
  @HiveField(39)
  int? index;

  WeatherCard({
    this.time,
    this.temperature2M,
    this.relativehumidity2M,
    this.apparentTemperature,
    this.precipitation,
    this.rain,
    this.weathercode,
    this.surfacePressure,
    this.visibility,
    this.evapotranspiration,
    this.windspeed10M,
    this.winddirection10M,
    this.windgusts10M,
    this.cloudcover,
    this.uvIndex,
    this.dewpoint2M,
    this.precipitationProbability,
    this.shortwaveRadiation,
    this.timeDaily,
    this.weathercodeDaily,
    this.temperature2MMax,
    this.temperature2MMin,
    this.apparentTemperatureMax,
    this.apparentTemperatureMin,
    this.sunrise,
    this.sunset,
    this.precipitationSum,
    this.precipitationProbabilityMax,
    this.windspeed10MMax,
    this.windgusts10MMax,
    this.uvIndexMax,
    this.rainSum,
    this.winddirection10MDominant,
    this.lat,
    this.lon,
    this.city,
    this.district,
    this.timezone,
    this.timestamp,
    this.index,
  });

  Map<String, dynamic> toJson() => {
    'time': time,
    'weathercode': weathercode,
    'temperature2M': temperature2M,
    'apparentTemperature': apparentTemperature,
    'relativehumidity2M': relativehumidity2M,
    'precipitation': precipitation,
    'rain': rain,
    'surfacePressure': surfacePressure,
    'visibility': visibility,
    'evapotranspiration': evapotranspiration,
    'windspeed10M': windspeed10M,
    'winddirection10M': winddirection10M,
    'windgusts10M': windgusts10M,
    'cloudcover': cloudcover,
    'uvIndex': uvIndex,
    'dewpoint2M': dewpoint2M,
    'precipitationProbability': precipitationProbability,
    'shortwaveRadiation': shortwaveRadiation,
    'timeDaily': timeDaily,
    'weathercodeDaily': weathercodeDaily,
    'temperature2MMax': temperature2MMax,
    'temperature2MMin': temperature2MMin,
    'apparentTemperatureMax': apparentTemperatureMax,
    'apparentTemperatureMin': apparentTemperatureMin,
    'sunrise': sunrise,
    'sunset': sunset,
    'precipitationSum': precipitationSum,
    'precipitationProbabilityMax': precipitationProbabilityMax,
    'windspeed10MMax': windspeed10MMax,
    'windgusts10MMax': windgusts10MMax,
    'uvIndexMax': uvIndexMax,
    'rainSum': rainSum,
    'winddirection10MDominant': winddirection10MDominant,
    'timezone': timezone,
    'timestamp': timestamp,
    'lat': lat,
    'lon': lon,
    'city': city,
    'district': district,
    'index': index,
  };

  factory WeatherCard.fromJson(Map<String, dynamic> json) {
    return WeatherCard(
      time: List<String>.from(json['time'] ?? []),
      weathercode: List<int>.from(json['weathercode'] ?? []),
      temperature2M: List<double>.from(json['temperature2M'] ?? []),
      apparentTemperature: List<double?>.from(
        json['apparentTemperature'] ?? [],
      ),
      relativehumidity2M: List<int?>.from(json['relativehumidity2M'] ?? []),
      precipitation: List<double>.from(json['precipitation'] ?? []),
      rain: List<double?>.from(json['rain'] ?? []),
      surfacePressure: List<double?>.from(json['surfacePressure'] ?? []),
      visibility: List<double?>.from(json['visibility'] ?? []),
      evapotranspiration: List<double?>.from(json['evapotranspiration'] ?? []),
      windspeed10M: List<double?>.from(json['windspeed10M'] ?? []),
      winddirection10M: List<int?>.from(json['winddirection10M'] ?? []),
      windgusts10M: List<double?>.from(json['windgusts10M'] ?? []),
      cloudcover: List<int?>.from(json['cloudcover'] ?? []),
      uvIndex: List<double?>.from(json['uvIndex'] ?? []),
      dewpoint2M: List<double?>.from(json['dewpoint2M'] ?? []),
      precipitationProbability: List<int?>.from(
        json['precipitationProbability'] ?? [],
      ),
      shortwaveRadiation: List<double?>.from(json['shortwaveRadiation'] ?? []),
      timeDaily: List<DateTime>.from(json['timeDaily'] ?? []),
      weathercodeDaily: List<int?>.from(json['weathercodeDaily'] ?? []),
      temperature2MMax: List<double?>.from(json['temperature2MMax'] ?? []),
      temperature2MMin: List<double?>.from(json['temperature2MMin'] ?? []),
      apparentTemperatureMax: List<double?>.from(
        json['apparentTemperatureMax'] ?? [],
      ),
      apparentTemperatureMin: List<double?>.from(
        json['apparentTemperatureMin'] ?? [],
      ),
      windspeed10MMax: List<double?>.from(json['windspeed10MMax'] ?? []),
      windgusts10MMax: List<double?>.from(json['windgusts10MMax'] ?? []),
      uvIndexMax: List<double?>.from(json['uvIndexMax'] ?? []),
      rainSum: List<double?>.from(json['rainSum'] ?? []),
      winddirection10MDominant: List<int?>.from(
        json['winddirection10MDominant'] ?? [],
      ),
      precipitationSum: List<double?>.from(json['precipitationSum'] ?? []),
      precipitationProbabilityMax: List<int?>.from(
        json['precipitationProbabilityMax'] ?? [],
      ),
      sunrise: List<String>.from(json['sunrise'] ?? []),
      sunset: List<String>.from(json['sunset'] ?? []),
      lat: json['lat'],
      lon: json['lon'],
      city: json['city'],
      district: json['district'],
      timezone: json['timezone'],
      timestamp: json['timestamp'],
      index: json['index'],
    );
  }
}