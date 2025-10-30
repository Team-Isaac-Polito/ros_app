import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/data/dark_mode_provider/dark_mode_provider.dart';

class DarkModeSwitcher extends ConsumerWidget {
  const DarkModeSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkModeAsync = ref.read(darkModeProvider);
    return darkModeAsync.when(
        data: (isDarkMode) {
          return Row(
            spacing: 20,
            children: [
              Text("Dark mode:"),
              Switch(
                value: isDarkMode,
                onChanged: (bool value){
                  ref.read(darkModeProvider.notifier).setDarkMode(value);
                },
              )
            ],
          );
        },
        error: (err, st) => Text(err.toString()),
        loading: () => const Center(child: CircularProgressIndicator(),)
    );
  }
}
