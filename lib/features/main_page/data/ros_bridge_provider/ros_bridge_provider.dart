import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Manages the primary [WebSocketChannel] to the ROS environment.
///
/// This provider leverages the **Rosbridge v2.0 Protocol**, which provides a JSON
/// API for ROS functionality, enabling browser-based or external applications
/// to interact with the robot's computational graph (topics, services, and parameters).
///
/// Reference:
/// * Rosbridge Protocol: https://github.com/RobotWebTools/rosbridge_suite/blob/ros2/ROSBRIDGE_PROTOCOL.md
/// * WebSocket Communication: https://pub.dev/packages/web_socket_channel
///
/// Design Decisions:
/// * **Encapsulation**: Uses a global [Provider] to ensure a single connection point.
/// * **Resource Management**: Implements [ref.onDispose] to guarantee the socket
///   is closed when the provider is no longer in use, preventing memory leaks
///   or ghost subscriptions in the robot's backend.
final rosBridgeProvider = Provider<WebSocketChannel>((ref) {
  // Establishing connection to the Rosbridge WebSocket server.
  // Standard port is 9090. Use 'ws://' for unencrypted or 'wss://' for secure sockets.
  final WebSocketChannel channel = WebSocketChannel.connect(
    Uri.parse("ws://192.168.8.104:9090"),
  );

  // According to Riverpod Documentation (https://riverpod.dev/docs/concepts/modifiers/on_dispose),
  // ref.onDispose is the safest way to perform cleanup of persistent connections.
  ref.onDispose(() => channel.sink.close());

  return channel;
});
