import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/data/ros_bridge_stream_provider/ros_bridge_stream_provider.dart';
import 'package:isaac_app/features/main_page/models/ros_publisher/ros_publisher.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

<<<<<<< HEAD

=======
/// A [Provider.family] that acts as a Factory for the [RosPublisher] domain model.
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
///   'Stream' (for listening to feedback) into the [RosPublisher] instance.
/// * **Scope Management**: By using [.family], this provider can dynamically
///   link a specific publisher instance to a dedicated channel, ensuring
///   thread-safe communication within the ROS 2 ecosystem.
/// * **Reactivity**: Utilizing [ref.watch] ensures that if the centralized
///   stream resets (e.g., on reconnection), the [RosPublisher] automatically
///   receives the updated data pipe without manual intervention.
>>>>>>> ed34974 (Modifiche a modules_page)
final rosPublisherProvider = Provider.family<RosPublisher, WebSocketChannel>((
  ref,
  WebSocketChannel channel,
) {
<<<<<<< HEAD
  final Stream<String> stream = ref.watch(rosBridgeStreamProvider);
=======
  // Watching the global stream provider to ensure the publisher
  // has access to real-time broadcast data.
  final Stream<String> stream = ref.watch(rosBridgeStreamProvider);

  // Returning a specialized instance that handles the protocol-level
  // logic of publishing and subscribing.
>>>>>>> ed34974 (Modifiche a modules_page)
  return RosPublisher(channel, stream);
});
