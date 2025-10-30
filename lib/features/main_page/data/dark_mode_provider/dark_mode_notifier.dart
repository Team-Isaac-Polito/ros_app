import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';


class DarkModeNotifier extends AsyncNotifier<bool> {
  late SharedPreferences _prefs;

  Future<void> setDarkMode(bool value) async {
    state = AsyncData(value);
    await _prefs.setBool("dark_mode", value);
  }

  @override
  Future<bool> build() async {
    _prefs = await SharedPreferences.getInstance();
    return _prefs.getBool("dark_mode") ?? false;
  }
}