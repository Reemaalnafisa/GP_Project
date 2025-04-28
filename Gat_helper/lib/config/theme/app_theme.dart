import 'package:flutter/material.dart';

abstract class AppTheme {
  ThemeData get themeData;

  ColorScheme get colorScheme;

  Color get primary;

  Color get onPrimary;

  Color get secondary;

  Color get onSecondary;
}
