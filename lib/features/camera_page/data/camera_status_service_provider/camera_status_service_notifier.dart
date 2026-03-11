import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/camera_page/data/manual_screenshot_provider/manual_screenshot_provider.dart';
import 'package:isaac_app/features/camera_page/models/camera_modes.dart';
import 'package:isaac_app/features/main_page/data/ros_publisher_provider/ros_publisher_provider.dart';
import 'package:isaac_app/features/main_page/models/ros_bridge_client/ros_bridge_client.dart';

/// An [AsyncNotifier] that manages the operational state and service interactions
/// of the robot's camera system.
///
/// In **Riverpod 3.0**, this class centralizes the "Call Service" logic, providing
/// a robust interface for hardware mode switching and on-demand data acquisition
/// (static screenshots) via the Rosbridge protocol.
///
/// References:
/// * Riverpod 3.0 - AsyncNotifier: https://riverpod.dev/docs/concepts/providers/notifier_provider#asyncnotifier
/// * ROS 2 Services: https://docs.ros.org/en/foxy/Concepts/About-Services.html
/// * Rosbridge Service Calls: https://github.com/RobotWebTools/rosbridge_suite/blob/ros2/ROSBRIDGE_PROTOCOL.md#347-call-service
///
/// Design Patterns:
/// * **Future Bridging**: Utilizes [Completer] to transform asynchronous WebSocket
///   stream events into a linear [Future] based on unique request IDs.
/// * **State Consistency**: Updates the provider's [state] only after successful
///   hardware confirmation from the ROS 2 service response.
final cameraProvider =
    AsyncNotifierProvider<CameraStatusServiceNotifier, CAMERA_MODE>(
      CameraStatusServiceNotifier.new,
    );

class CameraStatusServiceNotifier extends AsyncNotifier<CAMERA_MODE> {
  RosBridgeClient get _rosClient => ref.read(rosBridgeClientProvider);

  Future<void> requestScreenshot(int activeMonitor, String service) async {
    try {
      // Usiamo callService del client centralizzato
      final response = await _rosClient.callService(
        service: service,
        args: {},
      );
      
      if (response.containsKey("message")) {
        ref.read(manualScreenShotProvider.notifier)
           .setScreenshot(response["message"] as String,activeMonitor);
      }
    } catch (e) {
      print("Error during screenshot request: $e");
    }
  }

  /// Switches the camera operation mode (e.g., MAPPING, THERMAL, OFF).
  ///
  /// Transitions the UI into a loading state during the hardware handshaking
  /// process and updates the [state] upon successful confirmation from ROS 2.
  Future<void> setMode(CAMERA_MODE value) async {
    state = const AsyncLoading();
    try {
      await _rosClient.callService(service: "/detection/set_mode", args: {"mode": value.index});
      state = AsyncData(value);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Initializes the provider by fetching the current hardware status from the robot.
  @override
  Future<CAMERA_MODE> build() async {
    final res = await _rosClient.callService(service: "/detection/get_status",args: {});
    return CAMERA_MODE.values[res["current_mode"]];
  }
}
