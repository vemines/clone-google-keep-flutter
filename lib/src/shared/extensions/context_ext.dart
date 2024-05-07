import 'package:flutter/material.dart';

extension MyContextExt on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextStyle? get bodyStyle => textTheme.bodyMedium;
  TextStyle? get bodyBoldStyle => textTheme.bodyLarge;
  TextStyle? get titleStyle => textTheme.titleLarge;
  double get width => MediaQuery.of(this).size.width;
  void showSnackbar(SnackBar snakebar) =>
      ScaffoldMessenger.of(this).showSnackBar(snakebar);
}
