import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/data/ros_bridge_provider/ros_bridge_provider.dart';
import 'package:isaac_app/features/main_page/data/ros_bridge_stream_provider/ros_bridge_stream_provider.dart';
import 'package:isaac_app/features/main_page/models/ros_bridge_client/ros_bridge_client.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// A [Provider.family] that acts as a Factory for the [RosBridgeClient] domain model.
///
/// In **Riverpod 3.0**, this implementation follows the **Logic Injection** pattern.
/// It encapsulates the complexity of pairing an outgoing [WebSocketChannel] with
/// an incoming [Stream] to create a unified interface for ROS 2 interactions.
///
/// References:
/// * Riverpod - Provider.family: https://riverpod.dev/docs/concepts/modifiers/family
/// * ROS 2 Concepts - Pub/Sub: https://docs.ros.org/en/foxy/Concepts/About-Topic-Communication.html
/// * Command Pattern - Software Design: https://refactoring.guru/design-patterns/command
///
/// Design Rationale:
/// * **Composition**: It injects both the 'Sink' (for sending commands) and the
///   'Stream' (for listening to feedback) into the [RosBridgeClient] instance.
/// * **Scope Management**: By using [.family], this provider can dynamically
///   link a specific publisher instance to a dedicated channel, ensuring
///   thread-safe communication within the ROS 2 ecosystem.
/// * **Reactivity**: Utilizing [ref.watch] ensures that if the centralized
///   stream resets (e.g., on reconnection), the [RosBridgeClient] automatically
///   receives the updated data pipe without manual intervention.
final rosBridgeClientProvider = Provider<RosBridgeClient>((ref) {
  // Watching the global stream provider to ensure the publisher
  // has access to real-time broadcast data.
  final WebSocketChannel channel = ref.watch(rosBridgeProvider);
  final Stream<String> stream = ref.watch(rosBridgeStreamProvider);

  // Returning a specialized instance that handles the protocol-level
  // logic of publishing and subscribing.
  return RosBridgeClient(channel, stream);
});
