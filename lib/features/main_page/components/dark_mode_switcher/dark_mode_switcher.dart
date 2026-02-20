import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/data/dark_mode_provider/dark_mode_provider.dart';
import 'package:isaac_app/utils/index.dart';

class DarkModeSwitcher extends ConsumerWidget {
  const DarkModeSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(darkModeProvider);
    return Row(
      spacing: 20,
      children: [
        Text("Dark mode:", style: TextStyle(color: white)),
        Switch(
          value: isDark,
          onChanged: (bool value) {
            ref.read(darkModeProvider.notifier).toggleTheme();
          },
        ),
      ],
    );
  }
}
