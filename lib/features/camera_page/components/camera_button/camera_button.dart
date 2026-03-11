import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/camera_page/data/camera_status_service_provider/camera_status_service_notifier.dart';
import 'package:isaac_app/features/camera_page/models/camera_modes.dart';
import 'package:isaac_app/features/main_page/data/index.dart';
import 'package:isaac_app/utils/palette.dart';

class CameraButton extends ConsumerWidget {
  final CAMERA_MODE mode;
  final CAMERA_MODE currentMode;
  const CameraButton({
    super.key,
    required this.mode,
    required this.currentMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(darkModeProvider);

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: currentMode == mode ? Colors.blue : null,
      ),
      onPressed: () => ref.read(cameraProvider.notifier).setMode(mode),
      child: Text(
        mode.name.toUpperCase(),
        style: TextStyle(fontSize: 11, color: isDark ? white :  currentMode == mode ? white : black),
      ),
    );
  }
}
