import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/camera_page/data/camera_status_service_provider/camera_status_service_notifier.dart';
import 'package:isaac_app/features/camera_page/data/manual_screenshot_provider/manual_screenshot_provider.dart';
import 'package:isaac_app/features/main_page/data/dark_mode_provider/dark_mode_provider.dart';
import 'package:isaac_app/utils/palette.dart';

class CaptureScreenshot extends ConsumerWidget {
  final bool isEmpty;
  final int activeMonitor;

  const CaptureScreenshot({
    super.key,
    required this.activeMonitor,
    required this.isEmpty,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(darkModeProvider);
    
    return ElevatedButton.icon(
      onPressed: () => isEmpty
          ? ref.read(cameraProvider.notifier).requestScreenshot(activeMonitor)
          : ref
                .read(manualScreenShotProvider.notifier)
                .clearScreenshot(activeMonitor),
      icon: Icon(isEmpty ? Icons.camera : Icons.refresh),
      label: Text(
        isEmpty ? "Cattura Slot ${activeMonitor + 1}" : "Reset Slot",
        style: TextStyle(color: isDark ? white : black),
      ),
    );
  }
}
