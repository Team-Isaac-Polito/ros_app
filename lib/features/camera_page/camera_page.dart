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
            data: (currentMode) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: GridView.builder(
                      // Fondamentale: permette al GridView di stare dentro la Column
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: CAMERA_MODE.values.length,
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent:
                            150, // Larghezza massima di ogni bottone
                        mainAxisSpacing: 10, // Spazio verticale tra bottoni
                        crossAxisSpacing: 10, // Spazio orizzontale tra bottoni
                        childAspectRatio:
                            2.5, // Rapporto larghezza/altezza (più alto = più sottile)
                      ),
                      itemBuilder: (context, index) {
                        final mode = CAMERA_MODE.values[index];
                        final isSelected = currentMode == mode;
                    
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSelected ? Colors.blue : null,
                            foregroundColor: isSelected ? Colors.white : null,
                            padding: EdgeInsets
                                .zero, // Per evitare ritagli su schermi piccoli
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () =>
                              ref.read(cameraProvider.notifier).setMode(mode),
                          child: Text(
                            mode.name.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
            error: (e, tr) => Text("Errore: $e"),
          ),
        ],
      ),
    );
  }
}
