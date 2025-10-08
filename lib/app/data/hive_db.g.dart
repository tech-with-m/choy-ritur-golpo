// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_db.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingsAdapter extends TypeAdapter<Settings> {
  @override
  final int typeId = 0;

  @override
  Settings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Settings()
      ..onboard = fields[0] as bool
      ..theme = fields[1] as String?
      ..location = fields[2] as bool
      ..notifications = fields[3] as bool
      ..materialColor = fields[4] as bool
      ..amoledTheme = fields[5] as bool
      ..roundDegree = fields[6] as bool
      ..largeElement = fields[7] as bool
      ..hideMap = fields[8] as bool
      ..glassTheme = fields[9] as bool?
      ..useLightText = fields[10] as bool?
      ..widgetBackgroundColor = fields[11] as String?
      ..widgetTextColor = fields[12] as String?
      ..measurements = fields[13] as String
      ..degrees = fields[14] as String
      ..wind = fields[15] as String
      ..pressure = fields[16] as String
      ..timeformat = fields[17] as String
      ..language = fields[18] as String?
      ..timeRange = fields[19] as int?
      ..timeStart = fields[20] as String?
      ..timeEnd = fields[21] as String?;
  }

  @override
  void write(BinaryWriter writer, Settings obj) {
    writer
      ..writeByte(22)
      ..writeByte(0)
      ..write(obj.onboard)
      ..writeByte(1)
      ..write(obj.theme)
      ..writeByte(2)
      ..write(obj.location)
      ..writeByte(3)
      ..write(obj.notifications)
      ..writeByte(4)
      ..write(obj.materialColor)
      ..writeByte(5)
      ..write(obj.amoledTheme)
      ..writeByte(6)
      ..write(obj.roundDegree)
      ..writeByte(7)
      ..write(obj.largeElement)
      ..writeByte(8)
      ..write(obj.hideMap)
      ..writeByte(9)
      ..write(obj.glassTheme)
      ..writeByte(10)
      ..write(obj.useLightText)
      ..writeByte(11)
      ..write(obj.widgetBackgroundColor)
      ..writeByte(12)
      ..write(obj.widgetTextColor)
      ..writeByte(13)
      ..write(obj.measurements)
      ..writeByte(14)
      ..write(obj.degrees)
      ..writeByte(15)
      ..write(obj.wind)
      ..writeByte(16)
      ..write(obj.pressure)
      ..writeByte(17)
      ..write(obj.timeformat)
      ..writeByte(18)
      ..write(obj.language)
      ..writeByte(19)
      ..write(obj.timeRange)
      ..writeByte(20)
      ..write(obj.timeStart)
      ..writeByte(21)
      ..write(obj.timeEnd);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MainWeatherCacheAdapter extends TypeAdapter<MainWeatherCache> {
  @override
  final int typeId = 1;

  @override
  MainWeatherCache read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MainWeatherCache(
      time: (fields[0] as List?)?.cast<String>(),
      temperature2M: (fields[2] as List?)?.cast<double>(),
      relativehumidity2M: (fields[4] as List?)?.cast<int?>(),
      apparentTemperature: (fields[3] as List?)?.cast<double?>(),
      precipitation: (fields[5] as List?)?.cast<double?>(),
      rain: (fields[6] as List?)?.cast<double?>(),
      weathercode: (fields[1] as List?)?.cast<int>(),
      surfacePressure: (fields[7] as List?)?.cast<double?>(),
      visibility: (fields[8] as List?)?.cast<double?>(),
      evapotranspiration: (fields[9] as List?)?.cast<double?>(),
      windspeed10M: (fields[10] as List?)?.cast<double?>(),
      winddirection10M: (fields[11] as List?)?.cast<int?>(),
      windgusts10M: (fields[12] as List?)?.cast<double?>(),
      cloudcover: (fields[13] as List?)?.cast<int?>(),
      uvIndex: (fields[14] as List?)?.cast<double?>(),
      dewpoint2M: (fields[15] as List?)?.cast<double?>(),
      precipitationProbability: (fields[16] as List?)?.cast<int?>(),
      shortwaveRadiation: (fields[17] as List?)?.cast<double?>(),
      timeDaily: (fields[18] as List?)?.cast<DateTime>(),
      weathercodeDaily: (fields[19] as List?)?.cast<int?>(),
      temperature2MMax: (fields[20] as List?)?.cast<double?>(),
      temperature2MMin: (fields[21] as List?)?.cast<double?>(),
      apparentTemperatureMax: (fields[22] as List?)?.cast<double?>(),
      apparentTemperatureMin: (fields[23] as List?)?.cast<double?>(),
      sunrise: (fields[24] as List?)?.cast<String>(),
      sunset: (fields[25] as List?)?.cast<String>(),
      precipitationSum: (fields[26] as List?)?.cast<double?>(),
      precipitationProbabilityMax: (fields[27] as List?)?.cast<int?>(),
      windspeed10MMax: (fields[28] as List?)?.cast<double?>(),
      windgusts10MMax: (fields[29] as List?)?.cast<double?>(),
      uvIndexMax: (fields[30] as List?)?.cast<double?>(),
      rainSum: (fields[31] as List?)?.cast<double?>(),
      winddirection10MDominant: (fields[32] as List?)?.cast<int?>(),
      timezone: fields[33] as String?,
      timestamp: fields[34] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, MainWeatherCache obj) {
    writer
      ..writeByte(35)
      ..writeByte(0)
      ..write(obj.time)
      ..writeByte(1)
      ..write(obj.weathercode)
      ..writeByte(2)
      ..write(obj.temperature2M)
      ..writeByte(3)
      ..write(obj.apparentTemperature)
      ..writeByte(4)
      ..write(obj.relativehumidity2M)
      ..writeByte(5)
      ..write(obj.precipitation)
      ..writeByte(6)
      ..write(obj.rain)
      ..writeByte(7)
      ..write(obj.surfacePressure)
      ..writeByte(8)
      ..write(obj.visibility)
      ..writeByte(9)
      ..write(obj.evapotranspiration)
      ..writeByte(10)
      ..write(obj.windspeed10M)
      ..writeByte(11)
      ..write(obj.winddirection10M)
      ..writeByte(12)
      ..write(obj.windgusts10M)
      ..writeByte(13)
      ..write(obj.cloudcover)
      ..writeByte(14)
      ..write(obj.uvIndex)
      ..writeByte(15)
      ..write(obj.dewpoint2M)
      ..writeByte(16)
      ..write(obj.precipitationProbability)
      ..writeByte(17)
      ..write(obj.shortwaveRadiation)
      ..writeByte(18)
      ..write(obj.timeDaily)
      ..writeByte(19)
      ..write(obj.weathercodeDaily)
      ..writeByte(20)
      ..write(obj.temperature2MMax)
      ..writeByte(21)
      ..write(obj.temperature2MMin)
      ..writeByte(22)
      ..write(obj.apparentTemperatureMax)
      ..writeByte(23)
      ..write(obj.apparentTemperatureMin)
      ..writeByte(24)
      ..write(obj.sunrise)
      ..writeByte(25)
      ..write(obj.sunset)
      ..writeByte(26)
      ..write(obj.precipitationSum)
      ..writeByte(27)
      ..write(obj.precipitationProbabilityMax)
      ..writeByte(28)
      ..write(obj.windspeed10MMax)
      ..writeByte(29)
      ..write(obj.windgusts10MMax)
      ..writeByte(30)
      ..write(obj.uvIndexMax)
      ..writeByte(31)
      ..write(obj.rainSum)
      ..writeByte(32)
      ..write(obj.winddirection10MDominant)
      ..writeByte(33)
      ..write(obj.timezone)
      ..writeByte(34)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MainWeatherCacheAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LocationCacheAdapter extends TypeAdapter<LocationCache> {
  @override
  final int typeId = 2;

  @override
  LocationCache read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocationCache(
      lat: fields[0] as double?,
      lon: fields[1] as double?,
      city: fields[2] as String?,
      district: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, LocationCache obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.lat)
      ..writeByte(1)
      ..write(obj.lon)
      ..writeByte(2)
      ..write(obj.city)
      ..writeByte(3)
      ..write(obj.district);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationCacheAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WeatherCardAdapter extends TypeAdapter<WeatherCard> {
  @override
  final int typeId = 3;

  @override
  WeatherCard read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WeatherCard(
      time: (fields[0] as List?)?.cast<String>(),
      temperature2M: (fields[2] as List?)?.cast<double>(),
      relativehumidity2M: (fields[4] as List?)?.cast<int?>(),
      apparentTemperature: (fields[3] as List?)?.cast<double?>(),
      precipitation: (fields[5] as List?)?.cast<double?>(),
      rain: (fields[6] as List?)?.cast<double?>(),
      weathercode: (fields[1] as List?)?.cast<int>(),
      surfacePressure: (fields[7] as List?)?.cast<double?>(),
      visibility: (fields[8] as List?)?.cast<double?>(),
      evapotranspiration: (fields[9] as List?)?.cast<double?>(),
      windspeed10M: (fields[10] as List?)?.cast<double?>(),
      winddirection10M: (fields[11] as List?)?.cast<int?>(),
      windgusts10M: (fields[12] as List?)?.cast<double?>(),
      cloudcover: (fields[13] as List?)?.cast<int?>(),
      uvIndex: (fields[14] as List?)?.cast<double?>(),
      dewpoint2M: (fields[15] as List?)?.cast<double?>(),
      precipitationProbability: (fields[16] as List?)?.cast<int?>(),
      shortwaveRadiation: (fields[17] as List?)?.cast<double?>(),
      timeDaily: (fields[18] as List?)?.cast<DateTime>(),
      weathercodeDaily: (fields[19] as List?)?.cast<int?>(),
      temperature2MMax: (fields[20] as List?)?.cast<double?>(),
      temperature2MMin: (fields[21] as List?)?.cast<double?>(),
      apparentTemperatureMax: (fields[22] as List?)?.cast<double?>(),
      apparentTemperatureMin: (fields[23] as List?)?.cast<double?>(),
      sunrise: (fields[24] as List?)?.cast<String>(),
      sunset: (fields[25] as List?)?.cast<String>(),
      precipitationSum: (fields[26] as List?)?.cast<double?>(),
      precipitationProbabilityMax: (fields[27] as List?)?.cast<int?>(),
      windspeed10MMax: (fields[28] as List?)?.cast<double?>(),
      windgusts10MMax: (fields[29] as List?)?.cast<double?>(),
      uvIndexMax: (fields[30] as List?)?.cast<double?>(),
      rainSum: (fields[31] as List?)?.cast<double?>(),
      winddirection10MDominant: (fields[32] as List?)?.cast<int?>(),
      lat: fields[33] as double?,
      lon: fields[34] as double?,
      city: fields[35] as String?,
      district: fields[36] as String?,
      timezone: fields[37] as String?,
      timestamp: fields[38] as DateTime?,
      index: fields[39] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, WeatherCard obj) {
    writer
      ..writeByte(40)
      ..writeByte(0)
      ..write(obj.time)
      ..writeByte(1)
      ..write(obj.weathercode)
      ..writeByte(2)
      ..write(obj.temperature2M)
      ..writeByte(3)
      ..write(obj.apparentTemperature)
      ..writeByte(4)
      ..write(obj.relativehumidity2M)
      ..writeByte(5)
      ..write(obj.precipitation)
      ..writeByte(6)
      ..write(obj.rain)
      ..writeByte(7)
      ..write(obj.surfacePressure)
      ..writeByte(8)
      ..write(obj.visibility)
      ..writeByte(9)
      ..write(obj.evapotranspiration)
      ..writeByte(10)
      ..write(obj.windspeed10M)
      ..writeByte(11)
      ..write(obj.winddirection10M)
      ..writeByte(12)
      ..write(obj.windgusts10M)
      ..writeByte(13)
      ..write(obj.cloudcover)
      ..writeByte(14)
      ..write(obj.uvIndex)
      ..writeByte(15)
      ..write(obj.dewpoint2M)
      ..writeByte(16)
      ..write(obj.precipitationProbability)
      ..writeByte(17)
      ..write(obj.shortwaveRadiation)
      ..writeByte(18)
      ..write(obj.timeDaily)
      ..writeByte(19)
      ..write(obj.weathercodeDaily)
      ..writeByte(20)
      ..write(obj.temperature2MMax)
      ..writeByte(21)
      ..write(obj.temperature2MMin)
      ..writeByte(22)
      ..write(obj.apparentTemperatureMax)
      ..writeByte(23)
      ..write(obj.apparentTemperatureMin)
      ..writeByte(24)
      ..write(obj.sunrise)
      ..writeByte(25)
      ..write(obj.sunset)
      ..writeByte(26)
      ..write(obj.precipitationSum)
      ..writeByte(27)
      ..write(obj.precipitationProbabilityMax)
      ..writeByte(28)
      ..write(obj.windspeed10MMax)
      ..writeByte(29)
      ..write(obj.windgusts10MMax)
      ..writeByte(30)
      ..write(obj.uvIndexMax)
      ..writeByte(31)
      ..write(obj.rainSum)
      ..writeByte(32)
      ..write(obj.winddirection10MDominant)
      ..writeByte(33)
      ..write(obj.lat)
      ..writeByte(34)
      ..write(obj.lon)
      ..writeByte(35)
      ..write(obj.city)
      ..writeByte(36)
      ..write(obj.district)
      ..writeByte(37)
      ..write(obj.timezone)
      ..writeByte(38)
      ..write(obj.timestamp)
      ..writeByte(39)
      ..write(obj.index);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeatherCardAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
