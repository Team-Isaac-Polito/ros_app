import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/control_panel_page/data/gazebo_screenshot_manager/gazebo_screenshot_manager.dart';
import 'package:isaac_app/features/control_panel_page/data/useGazebomap_notifier/useGazebomap_notifier.dart';
import 'package:isaac_app/features/main_page/data/dark_mode_provider/dark_mode_provider.dart';
import 'package:isaac_app/utils/palette.dart';

class GazeboRunningButtons extends ConsumerWidget {
  const GazeboRunningButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(darkModeProvider);

    return Container(
      color: isDark ? black : white,
      padding: const EdgeInsets.all(20),
      child: Row(
        spacing: 10,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            onPressed: () {
              ref.read(useGazebomapProvider.notifier).toggleGazebo();
            },
            child: Text("2d Map"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            onPressed: () {
              ref
                  .read(gazeboScreenshotManagerProvider.notifier)
                  .takeScreenshot();
            },
            child: Text("Richiedi screenshot da Gazebo"),
          ),
        ],
      ),
    );
  }
}
