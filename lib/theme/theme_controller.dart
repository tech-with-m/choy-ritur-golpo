import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:choy_ritur_golpo/app/data/hive_db.dart';
import 'package:choy_ritur_golpo/app/data/hive_globals.dart';

class ThemeController extends GetxController {
  ThemeMode get theme =>
      settings.theme == 'system'
          ? ThemeMode.system
          : settings.theme == 'dark'
          ? ThemeMode.dark
          : ThemeMode.light;

  void saveOledTheme(bool isOled) {
    settings.amoledTheme = isOled;
    settingsBox.put('main', settings);
  }

  void saveMaterialTheme(bool isMaterial) {
    settings.materialColor = isMaterial;
    settingsBox.put('main', settings);
  }

  void saveTheme(String themeMode) {
    settings.theme = themeMode;
    settingsBox.put('main', settings);
  }

  void changeTheme(ThemeData theme) => Get.changeTheme(theme);

  void changeThemeMode(ThemeMode themeMode) => Get.changeThemeMode(themeMode);
}
