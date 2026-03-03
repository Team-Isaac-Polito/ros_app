import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/camera_page/data/manual_screenshot_provider/manual_screenshot_provider.dart';
import 'package:isaac_app/features/camera_page/models/camera_modes.dart';
import 'package:isaac_app/features/main_page/data/ros_bridge_provider/ros_bridge_provider.dart';
import 'package:isaac_app/features/main_page/data/ros_bridge_stream_provider/ros_bridge_stream_provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

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
  /// Triggers a remote capture service to acquire a high-quality static frame.
  ///
  /// This method bypasses the live stream to request a specific 'capture_frame'
  /// operation, subsequently updating the [manualScreenShotProvider] with the
  /// returned Base64 image data.
  Future<void> requestScreenshot() async {
    try {
      final response = await _callCameraService("/detection/capture_frame", {
        "quality": 100,
      });
      if (response.containsKey("image")) {
        // Dispatches the received image to the persistent screenshot state.
        ref
            .read(manualScreenShotProvider.notifier)
            .setScreenshot(response["image"] as String);
      }
    } catch (e) {
      print("Error during screenshot request: $e");
    }
  }

  /// Internal helper to execute a ROS 2 Service Call using the Rosbridge Protocol.
  ///
  /// Logic Implementation:
  /// * **Idempotency**: Generates a timestamp-based `requestId` to ensure the
  ///   response is matched correctly in a multi-message stream environment.
  /// * **Subscription Lifecycle**: Opens a transient listener on the broadcast
  ///   stream and ensures its disposal via a [finally] block to prevent memory leaks.
  /// * **Fault Tolerance**: Implements a 3-second timeout to handle cases where
  ///   the robot hardware or Rosbridge server is unresponsive.
  Future<Map<String, dynamic>> _callCameraService(
    String service,
    Map<String, dynamic> args,
  ) async {
    final WebSocketChannel channel = ref.read(rosBridgeProvider);
    final String requestId =
        "${service}_${DateTime.now().millisecondsSinceEpoch}";
    final completer = Completer<Map<String, dynamic>>();
    final Stream stream = ref.read(rosBridgeStreamProvider);

    // Establishing a temporary listener for the specific service response.
    final sub = stream.listen((message) {
      final data = jsonDecode(message);
      if (data["op"] == 'service_response' && data["id"] == requestId) {
        completer.complete(data["values"]);
      }
    });

    // Serializing and dispatching the JSON-RPC call.
    channel.sink.add(
      jsonEncode({
        "op": "call_service",
        "service": service,
        'args': args,
        "id": requestId,
      }),
    );

    try {
      return await completer.future.timeout(const Duration(seconds: 3));
    } catch (e, stackTrace) {
      // Propagating errors to the Riverpod state for UI feedback.
      state = AsyncError(e, stackTrace);
      return {};
    } finally {
      // Mandatory cleanup of the transient stream subscription.
      sub.cancel();
    }
  }

  /// Switches the camera operation mode (e.g., MAPPING, THERMAL, OFF).
  ///
  /// Transitions the UI into a loading state during the hardware handshaking
  /// process and updates the [state] upon successful confirmation from ROS 2.
  Future<void> setMode(CAMERA_MODE value) async {
    state = const AsyncLoading();
    try {
      await _callCameraService("/detection/set_mode", {"mode": value.index});
      state = AsyncData(value);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Initializes the provider by fetching the current hardware status from the robot.
  @override
  Future<CAMERA_MODE> build() async {
    final res = await _callCameraService("/detection/get_status", {});
    return CAMERA_MODE.values[res["current_mode"]];
  }
}
