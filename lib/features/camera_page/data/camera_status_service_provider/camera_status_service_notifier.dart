import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/camera_page/data/manual_screenshot_provider/manual_screenshot_provider.dart';
import 'package:isaac_app/features/camera_page/models/camera_modes.dart';
import 'package:isaac_app/features/main_page/data/ros_bridge_provider/ros_bridge_provider.dart';
import 'package:isaac_app/features/main_page/data/ros_bridge_stream_provider/ros_bridge_stream_provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

final cameraProvider =
    AsyncNotifierProvider<CameraStatusServiceNotifier, CAMERA_MODE>(
      CameraStatusServiceNotifier.new,
);

class CameraStatusServiceNotifier extends AsyncNotifier<CAMERA_MODE> {
  Future<void> requestScreenshot() async {
    try {
      final response = await _callCameraService("/detection/capture_frame", {
        "quality": 100,
      });
      if (response.containsKey("image")) {
        ref
            .read(manualScreenShotProvider.notifier)
            .setScreenshot(response["image"] as String);
      }
    } catch (e) {
      print("Errore durante la richiesta di screenshot: $e");
    }
  }

  Future<Map<String, dynamic>> _callCameraService(
    String service,
    Map<String, dynamic> args,
  ) async {
    final WebSocketChannel channel = ref.read(rosBridgeProvider);
    final String requestId =
        "${service}_${DateTime.now().millisecondsSinceEpoch}";
    final completer = Completer<Map<String, dynamic>>();
    final Stream stream = ref.read(rosBridgeStreamProvider);
    final sub = stream.listen((message) {
      final data = jsonDecode(message);
      if (data["op"] == 'service_response' && data["id"] == requestId) {
        completer.complete(data["values"]);
      }
    });

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
      state = AsyncError(e, stackTrace);
      return {};
    } finally {
      sub.cancel();
    }
  }

  Future<void> setMode(CAMERA_MODE value) async {
    state = const AsyncLoading();
    final WebSocketChannel channel = ref.watch(rosBridgeProvider);
    try {
      await _callCameraService("/detection/set_mode", {"mode": value.index});
      state = AsyncData(value);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  @override
  Future<CAMERA_MODE> build() async {
    final res = await _callCameraService("/detection/get_status", {});
    return CAMERA_MODE.values[res["current_mode"]];
  }
}
