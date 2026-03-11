import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/data/dark_mode_provider/dark_mode_provider.dart';
import 'package:isaac_app/utils/index.dart';

class NoScreenshot extends ConsumerWidget {
  final int index;
  const NoScreenshot({super.key, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(darkModeProvider);

    return Column(
      children: [
        Icon(
          index == 1 ? Icons.radar : Icons.analytics,
          size: 100,
          color: Colors.blueAccent,
        ),
        const SizedBox(height: 20),
        Text(
          "DATA STREAM MONITOR $index",
          style: TextStyle(color: isDark ? white : black, fontSize: 20),
        ),
      ],
    );
  }
}
