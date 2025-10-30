import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';


class DarkModeNotifier extends Notifier<bool> {

  Future<void> toggleTheme() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkTheme', state);
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('darkTheme') ?? false;
  }

  @override
  bool build() {
    _loadThemePreference();
    return false;
  }
}


