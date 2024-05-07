import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../gen/colors.gen.dart';

final robotoRegular = GoogleFonts.robotoSerif().fontFamily;

class AppThemeData {
  static final TextTheme whiteTextTheme = Typography.material2021().white
    ..apply(
        bodyColor: ColorName.onPrimaryDark,
        displayColor: ColorName.onPrimaryDark);

  static ThemeData dark = ThemeData.dark(useMaterial3: true).copyWith(
    brightness: Brightness.dark,
    textTheme: whiteTextTheme.copyWith(),
    appBarTheme:
        const AppBarTheme().copyWith(backgroundColor: ColorName.backgroundDark),
    scaffoldBackgroundColor: ColorName.backgroundDark,
    colorScheme: const ColorScheme.dark(),
    switchTheme: const SwitchThemeData().copyWith(
      thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return ColorName.primaryDark;
        }
        return Colors.white70;
      }),
      trackColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return Colors.blue[200]!;
        }
        return Colors.grey[700]!;
      }),
    ),
  );

  static ThemeData light = ThemeData.light(useMaterial3: true).copyWith(
    primaryColor: Colors.white,
    brightness: Brightness.light,
    textTheme: whiteTextTheme.copyWith(),
  );
}
