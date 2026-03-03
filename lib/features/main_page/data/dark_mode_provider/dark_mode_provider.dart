import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/data/dark_mode_provider/dark_mode_notifier.dart';

/// The global interface for the application's brightness theme state.
///
/// In **Riverpod 3.0**, this [NotifierProvider] acts as the single source of truth
/// for the theme's state. It orchestrates the [DarkModeNotifier] class,
/// enabling the UI to both watch the current state and trigger theme mutations.
///
/// References:
/// * Riverpod 3.0 - NotifierProvider: https://riverpod.dev/docs/concepts/providers/notifier_provider
/// * State Management Best Practices: https://docs.flutter.dev/data-and-backend/state-mgmt/intro
///
/// Architectural Pattern:
/// * **Separation of Concerns**: This provider isolates the theme business logic
///   from the UI components.
/// * **Dependency Injection**: It provides a mockable and testable instance of
///   [DarkModeNotifier] throughout the widget tree.
final darkModeProvider = NotifierProvider<DarkModeNotifier, bool>(
  DarkModeNotifier.new,
);
