import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/camera_page/data/camera_status_service_provider/camera_status_service_notifier.dart';
import 'package:isaac_app/features/camera_page/models/camera_modes.dart';

class CameraPage extends ConsumerStatefulWidget {
  const CameraPage({super.key});

  @override
  ConsumerState<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends ConsumerState<CameraPage> {
  String? screenshot;

  @override
  Widget build(BuildContext context) {
    final imageAsync = ref.watch(cameraImageProvider);
    // Listen the mode for buttons and status
    final cameraState = ref.watch(cameraProvider);

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
                child: screenshot != null
                    ? Image.memory(
                        base64Decode(screenshot!),
                      ) // Mostra lo screenshot
                    : imageAsync.when(
                        data: (base64) => Image.memory(
                          base64Decode(base64 ?? ""),
                          gaplessPlayback: true,
                        ),
                        loading: () => const CircularProgressIndicator(),
                        error: (e, _) =>
                            const Icon(Icons.videocam_off, size: 100),
                      ),
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
                    if (screenshot == null) {
                      // Congela l'ultimo frame
                      imageAsync.whenData(
                        (data) => setState(() => screenshot = data),
                      );
                    } else {
                      // Torna alla live
                      setState(() => screenshot = null);
                    }
                  },
                  icon: Icon(screenshot == null ? Icons.camera : Icons.refresh),
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
