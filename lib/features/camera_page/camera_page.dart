import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/camera_page/components/camera_buttons/camera_buttons.dart';
import 'package:isaac_app/features/camera_page/components/index.dart';
import 'package:isaac_app/features/camera_page/data/index.dart';
import 'package:isaac_app/features/camera_page/intent/index.dart';

class CameraPage extends ConsumerStatefulWidget {
  const CameraPage({super.key});

  @override
  ConsumerState<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends ConsumerState<CameraPage> {
  final TransformationController _transformationController = TransformationController();
  final FocusNode _pageFocusNode = FocusNode();
  double _currentScale = 1.0;
  Size _lastSize = Size.zero;
  int _activeMonitor = 0;
  final int _totalMonitors = 4;

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
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              title: Text("ISAAC MONITOR - SLOT ${_activeMonitor + 1}"),
            ),
            body: Column(
              children: [
                Expanded(
                  flex: 3,
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
                                      child: isEmpty
                                          ? NoScreenshot(index: _activeMonitor)
                                          : Image.memory(
                                              base64Decode(currentScreenshot),
                                              fit: BoxFit.contain,
                                              filterQuality:
                                                  FilterQuality.medium,
                                            ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 20,
                                  left: 10,
                                  width: 220,
                                  child: const IgnorePointer(
                                    child: DisplayedInfo(),
                                  ),
                                ),
                                Builder(
                                  builder: (context) {
                                    return Positioned.fill(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
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
                                                onPressed: () =>
                                                    _switchMonitor(-1),
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
                                                onPressed: () =>
                                                    _switchMonitor(1),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
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
                Flexible(
                  flex: 1,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          children: [
                            HazmatBanner(),
                            QrCodeBanner(),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: CaptureScreenshot(
                            activeMonitor: _activeMonitor,
                            isEmpty: isEmpty,
                            topicToListen: ref.watch(
                              activeCameraTopicProvider(_activeMonitor),
                            ),
                          ),
                        ),
                        CameraButtons(),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
