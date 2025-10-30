import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/data/dark_mode_provider/dark_mode_provider.dart';
import 'package:isaac_app/features/main_page/index.dart';
import 'package:isaac_app/utils/index.dart';

void main() {
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final darkModeAsync = ref.watch(darkModeProvider);

    return darkModeAsync.when(
        data: (isDarkMode){
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Robot Controls',
            themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
            theme: lightTheme,
            darkTheme: darkTheme,
            home: MainPage(),
          );
        },
        error: (err, st) =>  MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: Center(
              child: Text('Error: $err'),
            ),
          ),
        ),
        loading: () {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Robot Controls',
            home: Center(child: CircularProgressIndicator(),),
          );
        }
    );
  }
}
