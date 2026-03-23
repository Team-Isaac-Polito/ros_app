import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/camera_page/components/camera_button/camera_button.dart';
import 'package:isaac_app/features/camera_page/components/capture_screenshot/capture_screenshot.dart';
import 'package:isaac_app/features/camera_page/components/displayed_info/displayed_info.dart';
import 'package:isaac_app/features/camera_page/components/no_screenshot/no_screenshot.dart';
import 'package:isaac_app/features/camera_page/data/camera_status_service_provider/camera_status_service_notifier.dart';
import 'package:isaac_app/features/camera_page/data/manual_screenshot_provider/manual_screenshot_provider.dart';
import 'package:isaac_app/features/camera_page/intent/switch_monitor_intent.dart';
import 'package:isaac_app/features/camera_page/intent/zoom_intent.dart';
import 'package:isaac_app/features/camera_page/models/camera_modes.dart';
import 'package:isaac_app/features/main_page/data/dark_mode_provider/dark_mode_provider.dart';

class CameraPage extends ConsumerStatefulWidget {
  const CameraPage({super.key});

  @override
  ConsumerState<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends ConsumerState<CameraPage> {
  final TransformationController _transformationController =
      TransformationController();
  final FocusNode _pageFocusNode = FocusNode();
  double _currentScale = 1.0;
  Size _lastSize = Size.zero;
  int _activeMonitor = 0;
  final int _totalMonitors = 3;

  void _zoom(double delta) {
    if (!mounted || _lastSize == Size.zero) return;
    setState(() {
      double oldScale = _currentScale;
      _currentScale = (_currentScale + delta).clamp(1.0, 5.0);
      double factor = _currentScale / oldScale;

      final double centerX = _lastSize.width / 2;
      final double centerY = _lastSize.height / 2;

      _transformationController.value = _transformationController.value.clone()
        ..translate(centerX, centerY)
        ..scale(factor)
        ..translate(-centerX, -centerY);
    });
  }

  void _switchMonitor(int direction) {
    setState(() {
      _activeMonitor = (_activeMonitor + direction) % _totalMonitors;
      if (_activeMonitor < 0) _activeMonitor = _totalMonitors - 1;
      // Reset zoom
      _currentScale = 1.0;
      _transformationController.value = Matrix4.identity();
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _pageFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cameraState = ref.watch(cameraProvider);
    final screenshotList = ref.watch(manualScreenShotProvider);
    final currentScreenshot = screenshotList[_activeMonitor];
    final bool isEmpty = currentScreenshot == "";

    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        const SingleActivator(LogicalKeyboardKey.equal): const ZoomIntent(0.2),
        const SingleActivator(LogicalKeyboardKey.minus): const ZoomIntent(-0.2),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          ZoomIntent: CallbackAction<ZoomIntent>(
            onInvoke: (intent) => _zoom(intent.delta),
          ),
        },
        child: FocusScope(
          autofocus: true,
          child: Scaffold(
            appBar: AppBar(
              title: Text("ISAAC MONITOR - SLOT ${_activeMonitor + 1}"),
            ),
            body: Column(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      _lastSize = Size(
                        constraints.maxWidth,
                        constraints.maxHeight,
                      );

                      return Shortcuts(
                        shortcuts: <ShortcutActivator, Intent>{
                          const SingleActivator(LogicalKeyboardKey.arrowRight):
                              SwitchMonitorIntent(1),
                          const SingleActivator(LogicalKeyboardKey.arrowLeft):
                              SwitchMonitorIntent(-1),
                        },
                        child: Actions(
                          actions: <Type, Action<Intent>>{
                            SwitchMonitorIntent:
                                CallbackAction<SwitchMonitorIntent>(
                                  onInvoke: (intent) =>
                                      _switchMonitor(intent.direction),
                                ),
                          },
                          child: Focus(
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: InteractiveViewer(
                                    transformationController:
                                        _transformationController,
                                    clipBehavior: Clip.none,
                                    maxScale: 5.0,
                                    minScale: 1.0,
                                    child: Center(
                                      child: _buildMonitorContent(
                                        _activeMonitor,
                                        currentScreenshot,
                                        isEmpty,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 20,
                                  left: 10,
                                  bottom: 20,
                                  width: 220,
                                  child: const IgnorePointer(
                                    child: DisplayedInfo(),
                                  ),
                                ),
                                Builder(
                                  builder: (context) {
                                    final bool hasFocus = Focus.of(
                                      context,
                                    ).hasFocus;

                                    return _buildNavigationOverlay(hasFocus);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                _buildActionBar(isEmpty),
                _buildModeGrid(cameraState),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonitorContent(int index, String screenshot, bool isEmpty) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!isEmpty)
          Image.memory(base64Decode(screenshot), fit: BoxFit.contain),
        if (isEmpty) NoScreenshot(index: index),
      ],
    );
  }

  Widget _buildNavigationOverlay(bool hasFocus) {
    return Positioned.fill(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blue,
            child: Center(
              child: IconButton(
                icon: const Icon(
                  Icons.chevron_left,
                  size: 45,
                  color: Colors.white,
                ),
                onPressed: () => _switchMonitor(-1),
              ),
            ),
          ),
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blue,
            child: Center(
              child: IconButton(
                icon: Icon(
                  Icons.chevron_right,
                  size: 45,
                  color: Colors.white,
                ),
                onPressed: () => _switchMonitor(1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar(bool isEmpty) {
    final isDark = ref.watch(darkModeProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: CaptureScreenshot(activeMonitor: _activeMonitor, isEmpty: isEmpty, topicToListen: _activeMonitor == 1 ? "/camera/aligned_depth_to_color/image_raw" : _activeMonitor == 2 ? "/detector/model_output" : "/thermal",),
    );
  }

  Widget _buildModeGrid(AsyncValue<CAMERA_MODE> cameraState) {
    return cameraState.when(
      data: (currentMode) => ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: CAMERA_MODE.values.length,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 150,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.5,
          ),
          itemBuilder: (context, index) {
            final mode = CAMERA_MODE.values[index];
            return CameraButton(mode: mode, currentMode: currentMode);
          },
        ),
      ),
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => Text("Errore: $e"),
    );
  }
}
