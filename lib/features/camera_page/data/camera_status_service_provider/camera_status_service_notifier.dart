import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/camera_page/models/camera_modes.dart';
import 'package:isaac_app/features/main_page/data/ros_bridge_provider/ros_bridge_provider.dart';
import 'package:isaac_app/features/main_page/data/ros_bridge_stream_provider/ros_bridge_stream_provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/*
* This Notifier listen to the /detection/get_status channel
* and allow to set and get the current CAMERA_MODE
*/
class CameraNotifier extends AsyncNotifier<CAMERA_MODE> {
  late final WebSocketChannel _channel;
  late final Stream _stream;

  Future<CAMERA_MODE> getCameraCurrentMode() async {
    /*
    * This function is used to retrieve the current 
    * camera mode.
    * It send a call service to /detection/get_status
    */

    // Send the message subscribe to the call service
    _channel.sink.add(
      jsonEncode({
        "op": "call_service",
        "service": "/detection/get_status",
        "args": {},
        "id": "camera_status_request",
      }),
    );

    // listen the traffic and return the interested values
    final response = await _stream
        .map((message) {
          final data = jsonDecode(message);
          print("ROS CAMERA DATA - $data");
          try {
            if (data['op'] == "service_response" &&
                data['service'] == "/detection/get_status" &&
                data["id"] == "camera_status_request") {
              return data["values"];
            }
          } catch (e) {
            print("ERROR RESPONSE CAMERA CHANNEL - ${e.toString()}");
            return null;
          }
        })
        .where((e) => e != null)
        .first;

    final res = await response;
    final int mode = res["current_mode"];
    return CAMERA_MODE.values[mode];
  }

  void setCameraCurrentMode(CAMERA_MODE mode) async {
    /* WARNING THIS FUNCTION NEED TO PASS AN INT SO 
    * YOU NEED TO CONVERT FROM CAMERA_MODE TO INT
    */
    final int modeValue = mode.index;

    _channel.sink.add(
      jsonEncode({
        "op": "call_service",
        "service": "/detection/set_status",
        "args": {"mode": modeValue},
        "id": "set_mode_request",
      }),
    );

    final response = await _stream
        .map((message) {
          final data = jsonDecode(message);

          if (data["op"] == "service_response" &&
              data["service"] == "/detection/set_status" &&
              data["id"] == "set_mode_request") {
            return data["values"];
          }
          return null;
        })
        .where((e) => e != null)
        .first;
  }

  @override
  Future<CAMERA_MODE> build() async {
    // Initialize the channel and the stream
    _channel = ref.read(rosBridgeProvider);
    _stream = ref.read(rosBridgeStreamProvider);
    return await getCameraCurrentMode();
  }
}

final cameraProvider = AsyncNotifierProvider<CameraNotifier, CAMERA_MODE>(
  CameraNotifier.new
);
