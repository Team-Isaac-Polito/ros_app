import 'package:flutter/material.dart';
import 'package:isaac_app/utils/index.dart';

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.deepPurple,
    brightness: Brightness.dark,
  ),
  scaffoldBackgroundColor: Colors.black,
  appBarTheme: AppBarTheme(
    backgroundColor: gray,
    titleTextStyle: const TextStyle(color: white),
    iconTheme: const IconThemeData(color: white),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.all(Colors.deepPurple),
    trackColor: WidgetStateProperty.all(Colors.deepPurple.shade200),
  ),
);