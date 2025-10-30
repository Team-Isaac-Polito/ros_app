import 'package:flutter/material.dart';
import 'package:isaac_app/utils/index.dart';

final ThemeData lightTheme =  ThemeData(
    brightness: Brightness.light,
    appBarTheme: const AppBarTheme(
      backgroundColor: gray,
      titleTextStyle: TextStyle(
        color: white,
      ),
      iconTheme: IconThemeData(
          color: white
      ),
    )
);