import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/data/dark_mode_provider/dark_mode_provider.dart';
import 'package:isaac_app/utils/index.dart';

/// A specialized UI toggle used to switch between Light and Dark application themes.
///
/// This [ConsumerWidget] subscribes to the [darkModeProvider] to reactively update
/// its state. In **Riverpod 3.0**, this represents a "Leaf Widget" that triggers
/// side effects across the entire widget tree by mutating a global notifier.
///
/// References:
/// * Riverpod 3.0 - ConsumerWidget: https://riverpod.dev/docs/concepts/components/consumer_widget
/// * Material Design - Switch: https://m3.material.io/components/switch/overview
/// * Flutter State Management: https://docs.flutter.dev/data-and-backend/state-mgmt/intro
///
/// Design Decisions:
/// * **Reactive Binding**: Uses [ref.watch] to ensure the switch position always
///   reflects the current source of truth, even if the state is changed elsewhere.
/// * **Intentional Mutation**: Employs [ref.read] within the [onChanged] callback
///   to invoke the [toggleTheme] method on the notifier without creating
///   unnecessary rebuild subscriptions.
/// * **Thematic Consistency**: References global utility constants (like `white`)
///   to maintain brand alignment within the AppBar or Settings context.
class DarkModeSwitcher extends ConsumerWidget {
  const DarkModeSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listening to the boolean state of the dark mode provider.
    final isDark = ref.watch(darkModeProvider);

    return Row(
      spacing: 20,
      children: [
        // Label styled with utility color constants for high-contrast visibility.
        Text("Dark mode:", style: TextStyle(color: white)),

        // Interactive switch that dispatches a theme toggle request.
        Switch(
          value: isDark,
          onChanged: (bool value) {
            // Accessing the notifier's logic layer to persist the change.
            ref.read(darkModeProvider.notifier).toggleTheme();
          },
        ),
      ],
    );
  }
}
