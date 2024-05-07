import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import '../../../shared/helpers/hive_helper.dart';

List<Locale> supportLanguages = [
  const Locale('en', 'US'),
  const Locale('vi', 'VN'),
];

String languageName(String languageCode) {
  switch (languageCode) {
    case 'en':
      return "English";
    case 'vi':
      return "Tiếng Việt";
    default:
      return "Unknown Language";
  }
}

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit() : super(supportLanguages[0]);

  HiveHelper hive = HiveHelper.instance;
  final String _languageKey = 'languageKey';
  final String _countryKey = 'countryKey';

  void loadCurrentLocale() async {
    String? languageCode = await hive.get(key: _languageKey);
    String? countryCode = await hive.get(key: _countryKey);
    if (languageCode != null && countryCode != null) {
      emit(Locale(languageCode, countryCode));
    }
  }

  void changeLocale(context, Locale locale) {
    hive.put(key: _languageKey, value: locale.languageCode);
    hive.put(key: _countryKey, value: locale.countryCode);
    emit(locale);
  }
}
