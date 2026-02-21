import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/data/index.dart';
import 'package:isaac_app/features/main_page/index.dart';
import 'package:isaac_app/utils/index.dart';

void main() {
  runApp(
     // Provider scope is needed so that riverpod can manage the app
      ProviderScope(
          child: const MyApp()
      )
    );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(darkModeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Robot Controls',
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      theme: lightTheme,
      darkTheme: darkTheme,
      home: MainPage(),
    );
  }
}
