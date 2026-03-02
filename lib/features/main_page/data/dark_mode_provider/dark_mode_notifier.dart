import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

<<<<<<< HEAD
/*
* This class takes care of dark mode
*
* */
class DarkModeNotifier extends Notifier<bool> {

  /* This function change the team from light to dark and viceversa*/
=======
/// A [Notifier] class that orchestrates the application's brightness theme state.
/// 
/// In **Riverpod 3.0**, this class-based Notifier represents the "Side-effect" 
/// pattern, where a piece of state is tied to external persistent storage.
///
/// References:
/// * Riverpod 3.0 Notifier: https://riverpod.dev/docs/concepts/providers/notifier_provider
/// * Shared Preferences - Persistence Layer: https://pub.dev/packages/shared_preferences
///
/// Design Principles:
/// * **Reactive State Management**: Updates the UI tree automatically upon state mutations.
/// * **Persistence Integration**: Bridges the gap between volatile memory (RAM) 
///   and persistent storage (Disk).
class DarkModeNotifier extends Notifier<bool> {

  /// Toggles the current theme between Light and Dark modes.
  /// 
  /// Following the **Optimistic UI** pattern, the state is mutated immediately to 
  /// provide instantaneous feedback, while the [SharedPreferences] write operation 
  /// is executed asynchronously in the background.
>>>>>>> ed34974 (Modifiche a modules_page)
  Future<void> toggleTheme() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkTheme', state);
  }

<<<<<<< HEAD
  /*
  * This function loads the selected theme from device
  * If no theme is setted it will automatically set light
  */
=======
  /// Synchronizes the current [state] with the locally stored user preference.
  /// 
  /// This internal method handles the asynchronous transition from the 
  /// [build] method's initial value to the user's actual saved preference.
>>>>>>> ed34974 (Modifiche a modules_page)
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('darkTheme') ?? false;
  }

<<<<<<< HEAD
=======
  /// The entry point for the Notifier's state initialization in Riverpod 3.0.
  /// 
  /// Initially returns `false` (Light Mode) and triggers an asynchronous 
  /// lookup via [_loadThemePreference] to refresh the state from the device storage.
  /// 
  /// Note: [build] must be synchronous; hence the asynchronous loading 
  /// happens as a post-initialization side effect.
>>>>>>> ed34974 (Modifiche a modules_page)
  @override
  bool build() {
    _loadThemePreference();
    return false;
  }
<<<<<<< HEAD
}


=======
}
>>>>>>> ed34974 (Modifiche a modules_page)
