import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/data/ros_bridge_stream_provider/ros_bridge_stream_provider.dart';

/// Intercepts and decodes the incoming Rosbridge stream to isolate 'publish' operations.
///
/// In **Riverpod 3.0**, this [StreamProvider] acts as a specialized filter (Middleware).
/// It transforms raw JSON strings into structured telemetry data, specifically
/// targeting ROS 2 Topic communications.
///
/// References:
/// * Rosbridge Protocol - Publish: https://github.com/RobotWebTools/rosbridge_suite/blob/ros2/ROSBRIDGE_PROTOCOL.md#344-publish--op-publish
/// * Riverpod - StreamProvider: https://riverpod.dev/docs/concepts/providers/stream_provider
/// * Dart Stream.map: https://api.dart.dev/stable/dart-async/Stream/map.html
///
/// Logic Flow:
/// * **Parsing**: Deserializes the raw WebSocket event into a [Map].
/// * **Filtering (Protocol Level)**: Validates that the operation type (`op`) is
///   strictly "publish", ignoring service responses or heartbeats at this layer.
/// * **Data Integrity**: Returns a sanitized map containing only the `topic`
///   identifier and the actual `msg` payload.
/// * **Stream Pruning**: Employs the [.where] operator to discard empty results,
///   ensuring that downstream listeners only rebuild when valid ROS data arrives.
final rosMessagesProvider = StreamProvider<Map<String, dynamic>>((ref) {
  // Subscribing to the centralized broadcast stream.
  final stream = ref.watch(rosBridgeStreamProvider);

  return stream
      .map((event) {
        try {
          final data = jsonDecode(event);

          // Filtering for the "publish" opcode per Rosbridge specification.
          if (data["op"] == "publish") {
            return {
              "topic": data["topic"] as String,
              "msg": data["msg"] as Map<String, dynamic>,
            };
          }
        } catch (e) {
          // Catching malformed JSON to prevent stream termination.
          print("Stream Decode Error: $e");
        }
        return <String, dynamic>{};
      })
      .where((data) => data.isNotEmpty);
});
