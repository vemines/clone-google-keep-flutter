import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

// import '../../shared/helpers/hive_helper.dart';
import '../../../shared/themes/app_theme.dart';

enum AppThemeMode {
  light,
  dark,
}

final Map<AppThemeMode, ThemeData> themeData = {
  AppThemeMode.light: AppThemeData.light,
  AppThemeMode.dark: AppThemeData.dark,
};

final Map<AppThemeMode, String> supportsTheme = {
  AppThemeMode.light: "Light",
  AppThemeMode.dark: "Dark",
};

class ThemeCubit extends Cubit<AppThemeMode> {
  ThemeCubit() : super(AppThemeMode.dark);

  // final String _themeKey = 'app-theme';

  // HiveHelper hive = HiveHelper.instance;
  void loadCurrentTheme() {
    // int? themeIndex = hive.get(key: _themeKey);
    // if (themeIndex != null) {
    //   emit(AppThemeMode.values[themeIndex]);
    // }
  }
  // void setTheme(AppThemeMode theme) {
  //   hive.put(key: _themeKey, value: theme.index);
  //   emit(theme);
  // }

  /// Returns appropriate theme mode
  ThemeMode get themeMode {
    switch (state) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }

  /// Default theme
  ThemeData getDefaultTheme() {
    switch (state) {
      case AppThemeMode.light:
        return AppThemeData.light;
      case AppThemeMode.dark:
        return AppThemeData.dark;
    }
  }
}
