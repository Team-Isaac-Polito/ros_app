import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/camera_page/intent/zoom_intent.dart';
import 'package:isaac_app/features/control_panel_page/components/req_gazebo_screen_page/components/gazebo_running_banner/gazebo_running_banner.dart';
import 'package:isaac_app/features/control_panel_page/components/gazebo_running_buttons/gazebo_running_buttons.dart';
import 'package:isaac_app/features/control_panel_page/data/gazebo_process_manager/gazebo_process_manager.dart';
import 'package:isaac_app/features/control_panel_page/data/gazebo_screenshot_manager/gazebo_screenshot_manager.dart';
import 'package:isaac_app/features/main_page/data/dark_mode_provider/dark_mode_provider.dart';
import 'package:isaac_app/utils/index.dart';

class ReqGazeboScreenPage extends ConsumerStatefulWidget {
  const ReqGazeboScreenPage({super.key});

  @override
  ConsumerState<ReqGazeboScreenPage> createState() => _CameraPageState();
}

class _CameraPageState extends ConsumerState<ReqGazeboScreenPage> {
  @override
  Widget build(BuildContext context) {
    final gazeboProcessStatus = ref.watch(gazeboProcessManagerProvider);
    final gazeboScreenshot = ref.watch(gazeboScreenshotManagerProvider);
    final isDark = ref.watch(darkModeProvider);

    final TransformationController _transformationController =
        TransformationController();
    double _currentScale = 1.0;
    Size _lastSize = Size.zero;

    void _zoom(double delta) {
      if (!mounted || _lastSize == Size.zero) return;
      setState(() {
        double oldScale = _currentScale;
        _currentScale = (_currentScale + delta).clamp(1.0, 5.0);
        double factor = _currentScale / oldScale;

        final double centerX = _lastSize.width / 2;
        final double centerY = _lastSize.height / 2;

        _transformationController.value =
            _transformationController.value.clone()
              ..translate(centerX, centerY)
              ..scale(factor)
              ..translate(-centerX, -centerY);
      });
    }

    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        const SingleActivator(LogicalKeyboardKey.greater): const ZoomIntent(
          0.2,
        ),
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
          child: Container(
            color: isDark ? black : white,
            child: Column(
              children: [
                Column(
                  children: [
                    gazeboProcessStatus
                        ? SizedBox.shrink()
                        : GazeboRunningBanner(),
                    GazeboRunningButtons(),
                    gazeboScreenshot != null
                        ? Image.memory(gazeboScreenshot)
                        : SizedBox.shrink(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
