import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/data/ros_bridge_provider/ros_bridge_provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Exposes the centralized [Stream] of raw data originating from the Rosbridge WebSocket.
///
/// In **Riverpod 3.0**, this [Provider] serves as a reactive bridge between the
/// persistent [WebSocketChannel] and the application's downstream data consumers.
///
/// References:
/// * Riverpod - Streams: https://riverpod.dev/docs/concepts/providers/stream_provider
/// * Dart Stream.asBroadcastStream: https://api.dart.dev/stable/dart-async/Stream/asBroadcastStream.html
/// * Rosbridge v2 Protocol: https://github.com/RobotWebTools/rosbridge_suite
///
/// Implementation Details:
/// * **Type Casting**: Uses [cast<String>] to ensure incoming WebSocket packets
///   are treated as UTF-8 encoded JSON strings, matching the Rosbridge specification.
/// * **Broadcast Pattern**: Implements [asBroadcastStream] to allow multiple
///   independent providers (e.g., telemetry, camera, and logs) to listen to the
///   same hardware feed simultaneously without creating redundant connections.
/// * **Reactivity**: Since it uses [ref.watch], if the underlying [rosBridgeProvider]
///   reconnects or resets, this stream will automatically refresh to the new channel.
final rosBridgeStreamProvider = Provider<Stream<String>>((ref) {
  final WebSocketChannel channel = ref.watch(rosBridgeProvider);

  // Transformations are applied to the raw channel sink to prepare it for
  // multi-consumer subscription across the widget tree.
  return channel.stream.cast<String>().asBroadcastStream();
});
