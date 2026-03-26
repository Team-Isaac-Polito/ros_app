import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/camera_page/data/index.dart';
import 'package:isaac_app/features/main_page/data/dark_mode_provider/dark_mode_provider.dart';
import 'package:isaac_app/utils/palette.dart';

class ShowDetailButton extends ConsumerWidget {
  const ShowDetailButton({super.key});

  @override
  Widget build(BuildContext contex, WidgetRef ref) {
    final isDark = ref.watch(darkModeProvider);
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
      onPressed: () => ref.read(showDetailProvider.notifier).toggleBanner(),
      child: Text(
        "Show details",
        style: TextStyle(
          fontSize: 11,
          color: isDark
              ? white
              : black,
        ),
      ),
    );
  }
}
