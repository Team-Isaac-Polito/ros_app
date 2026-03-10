import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/data/ros_bridge_stream_provider/ros_bridge_stream_provider.dart';
import 'package:isaac_app/features/main_page/data/ros_publisher_provider/ros_publisher_provider.dart';

/// A [StreamProvider.family] that creates a dedicated data pipe for a specific ROS 2 topic.
///
/// In **Riverpod 3.0**, the `.family` modifier allows for dynamic parameterization.
/// This provider acts as a high-performance filter that de-multiplexes the global
/// [rosBridgeStreamProvider] into topic-specific streams.
///
/// References:
/// * Riverpod - Families: https://riverpod.dev/docs/concepts/modifiers/family
/// * ROS 2 - Topics: https://docs.ros.org/en/foxy/Concepts/About-Topics.html
/// * Rosbridge Protocol - Subscribe: https://github.com/RobotWebTools/rosbridge_suite/blob/ros2/ROSBRIDGE_PROTOCOL.md
///
/// Design Rationale:
/// * **Selective Listening**: Prevents UI components from rebuilding when data
///   arrives on topics they are not interested in, optimizing CPU usage on the
///   control tablet.
/// * **Type Safety**: Uses [.cast<Map<String, dynamic>>()] to ensure downstream
///   consumers receive a consistent data structure for ROS message payloads.
/// * **Memoization**: Riverpod automatically caches the stream for a specific
///   [topicName], ensuring that multiple widgets watching the same topic share
///   the same underlying logic.
final topicSubscriptionProvider = StreamProvider.family<Map<String, dynamic>, String>((
  ref,
  topicName,
) {
  // Watching the centralized broadcast stream for raw WebSocket packets.
  final rosClient = ref.watch(rosBridgeClientProvider);

  return rosClient.subscribe(topicName);
});
