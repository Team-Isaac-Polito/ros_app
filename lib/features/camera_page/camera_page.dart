import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final TransformationController _transformationController =
      TransformationController();
  double _currentScale = 1.0;

  void _zoom(double delta) {
    setState(() {
      double oldScale = _currentScale;
    _currentScale = (_currentScale + delta).clamp(1.0, 5.0);
    
    // Calcoliamo il fattore di moltiplicazione rispetto allo zoom precedente
    double factor = _currentScale / oldScale;
    
    // Invece di resettare con identity(), moltiplichiamo la matrice attuale
    _transformationController.value = _transformationController.value.clone()..scale(factor);
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

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

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.add): () => _zoom(0.2),
        const SingleActivator(LogicalKeyboardKey.arrowUp): () => _zoom(0.2),
        // Zoom Out: Tasto -, Freccia Giù o L1 del Joystick
        const SingleActivator(LogicalKeyboardKey.minus): () => _zoom(-0.2),
        const SingleActivator(LogicalKeyboardKey.arrowDown): () => _zoom(-0.2),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          appBar: AppBar(title: const Text("Camera Focus")),
          body: Column(
            children: [
              // Area Video con Zoom
              Expanded(
                child: InteractiveViewer(
                  transformationController: _transformationController,
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
                      icon: Icon(
                        screenshotEmpty ? Icons.camera : Icons.refresh,
                      ),
                      label: Text("Richiedi screenshot"),
                    ),
                  ],
                ),
              ),
              cameraState.when(
                data: (currentMode) {
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: CAMERA_MODE.values.length,
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent:
                                  150, // Larghezza massima di ogni bottone
                              mainAxisSpacing:
                                  10, // Spazio verticale tra bottoni
                              crossAxisSpacing:
                                  10, // Spazio orizzontale tra bottoni
                              childAspectRatio:
                                  2.5, // Rapporto larghezza/altezza (più alto = più sottile)
                            ),
                        itemBuilder: (context, index) {
                          final mode = CAMERA_MODE.values[index];
                          final isSelected = currentMode == mode;

                          return Focus(
                            onKeyEvent: (node, event) {
                              if (event is KeyDownEvent &&
                                  (event.logicalKey ==
                                          LogicalKeyboardKey.enter ||
                                      event.logicalKey ==
                                          LogicalKeyboardKey.gameButtonA)) {
                                ref.read(cameraProvider.notifier).setMode(mode);
                                return KeyEventResult.handled;
                              }
                              return KeyEventResult.ignored;
                            },
                            child: Builder(
                              builder: (context) {
                                final bool isFocused = Focus.of(
                                  context,
                                ).hasFocus;
                                return AnimatedContainer(
                                  duration: const Duration(seconds: 2),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    // Feedback visivo del focus
                                    border: Border.all(
                                      color: isFocused
                                          ? Colors.blue.withValues(alpha: 0.8)
                                          : Colors.transparent,
                                      width: 3,
                                    ),
                                    boxShadow: isFocused
                                        ? [
                                            BoxShadow(
                                              color: Colors.blue.withValues(
                                                alpha: 0.1,
                                              ),
                                              blurRadius: 15,
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isSelected
                                          ? Colors.blue
                                          : null,
                                      foregroundColor: isSelected
                                          ? Colors.white
                                          : null,
                                      padding: EdgeInsets
                                          .zero, // Per evitare ritagli su schermi piccoli
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () => ref
                                        .read(cameraProvider.notifier)
                                        .setMode(mode),
                                    child: Text(
                                      mode.name.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
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
        ),
      ),
    );
  }
}
