import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/*
* This class takes care of dark mode
*
* */
class DarkModeNotifier extends Notifier<bool> {

  /* This function change the team from light to dark and viceversa*/
  Future<void> toggleTheme() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkTheme', state);
  }

  /*
  * This function loads the selected theme from device
  * If no theme is setted it will automatically set light
  */
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


