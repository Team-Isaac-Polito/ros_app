import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/camera_page/data/camera_status_service_provider/camera_status_service_notifier.dart';
import 'package:isaac_app/features/camera_page/data/manual_screenshot_provider/manual_screenshot_provider.dart';
import 'package:isaac_app/features/camera_page/models/camera_modes.dart';
import 'package:isaac_app/features/main_page/data/dark_mode_provider/dark_mode_provider.dart';
import 'package:isaac_app/utils/palette.dart';

class CaptureScreenshot extends ConsumerWidget {
  final bool isEmpty;
  final int activeMonitor;
  final String topicToListen;

  const CaptureScreenshot({
    super.key,
    required this.activeMonitor,
    required this.isEmpty,
    required this.topicToListen,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(darkModeProvider);
    final cameraState = ref.watch(cameraProvider);

    return ElevatedButton.icon(
      onPressed: () {
        print("Listening $topicToListen");

        if (cameraState.isLoading ||
            cameraState.value == CAMERA_MODE.INITIALIZING || cameraState.value == CAMERA_MODE.OFF) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "It's not possible to take screenshot during initialization",
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }
        if (isEmpty) {
          ref
              .read(cameraProvider.notifier)
              .requestScreenshot(activeMonitor, topicToListen);
        } else {
          ref
              .read(manualScreenShotProvider.notifier)
              .clearScreenshot(activeMonitor);
        }
      },
      icon: cameraState.isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.orange,
              ),
            )
          : Icon(isEmpty ? Icons.camera : Icons.refresh),
      label: Text(
        isEmpty ? "Capture Slot ${activeMonitor + 1}" : "Reset Slot",
        style: TextStyle(color: isDark ? white : black),
      ),
    );
  }
}
