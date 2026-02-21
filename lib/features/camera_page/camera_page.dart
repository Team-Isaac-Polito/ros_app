import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/camera_page/data/camera_status_service_provider/camera_status_service_notifier.dart';
import 'package:isaac_app/features/camera_page/data/manual_screenshot_provider/manual_screenshot_provider.dart';
import 'package:isaac_app/features/camera_page/models/camera_modes.dart';
import 'package:isaac_app/utils/index.dart';

class CameraPage extends ConsumerStatefulWidget {
  const CameraPage({super.key});

  @override
  ConsumerState<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends ConsumerState<CameraPage> {
  @override
  Widget build(BuildContext context) {
    // Listen the mode for buttons and status
    final cameraState = ref.watch(cameraProvider);
    // notifier to access cameraProvider methods
    final cameraNotifier = ref.read(cameraProvider.notifier);
    // value of the screenshot
    final screenshot = ref.watch(manualScreenShotProvider);
    // notifier to the screenshot methods
    final screenshotNotifier = ref.read(manualScreenShotProvider.notifier);
    // just calculate it one 
    final bool screenshotEmpty = screenshot == "";
    
    return Scaffold(
      appBar: AppBar(title: const Text("Camera Focus")),
      body: Column(
        children: [
          // Area Video con Zoom
          Expanded(
            child: InteractiveViewer(
              clipBehavior: Clip.none,
              maxScale: 5.0,
              child: Center(
                child: !screenshotEmpty
                    ? Image.memory(base64Decode(screenshot))
                    : Container(color: gray, child: Text("No screenshot")),
              ),
            ),
          ),
          // Controlli
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    if (screenshotEmpty) {
                      // Congela l'ultimo frame
                      cameraNotifier.requestScreenshot();
                    } else {
                      screenshotNotifier.clearScreenshot();
                    }
                  },
                  icon: Icon(screenshotEmpty ? Icons.camera : Icons.refresh),
                  label: Text("Richiedi screenshot"),
                ),
              ],
            ),
          ),
          cameraState.when(
            data: (currentMode) => Container(
              margin: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 10,
                children: CAMERA_MODE.values
                    .map(
                      (mode) => ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: currentMode == mode
                              ? Colors.blue
                              : null,
                        ),
                        onPressed: () =>
                            ref.read(cameraProvider.notifier).setMode(mode),
                        child: Text(mode.name),
                      ),
                    )
                    .toList(),
              ),
            ),
            loading: () => const CircularProgressIndicator(),
            error: (e, _) => Text("Errore: $e"),
          ),
        ],
      ),
    );
  }
}
