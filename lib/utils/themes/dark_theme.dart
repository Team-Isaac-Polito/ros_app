import 'package:flutter/material.dart';
import 'package:isaac_app/utils/index.dart';

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.deepPurple,
    brightness: Brightness.dark,
  ),
  scaffoldBackgroundColor: Colors.black,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black54,
    titleTextStyle: TextStyle(color: white),
    iconTheme: IconThemeData(color: white),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.all(Colors.deepPurple),
    trackColor: WidgetStateProperty.all(Colors.deepPurple.shade200),
  ),
);