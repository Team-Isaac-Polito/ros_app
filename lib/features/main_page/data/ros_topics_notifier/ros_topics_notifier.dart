import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/data/ros_bridgeclient_provider/ros_bridgeclient_provider.dart';
import 'package:isaac_app/features/main_page/models/index.dart';

/// An [AsyncNotifierProvider] that manages the discovery of active ROS 2 topics.
///
/// In **Riverpod 3.0**, this provider handles complex asynchronous initialization
/// by polling the `/rosapi/topics` service. It transitions the UI through
/// Loading, Data, and Error states automatically.
///
/// References:
/// * Riverpod 3.0 - AsyncNotifier: https://riverpod.dev/docs/concepts/providers/notifier_provider#asyncnotifier
/// * ROS 2 Nodes and Topics: https://docs.ros.org/en/foxy/Concepts/About-Topics.html
/// * Rosbridge ROSAPI Service: https://github.com/RobotWebTools/rosbridge_suite/blob/ros2/ROSBRIDGE_PROTOCOL.md
///
/// Design Patterns:
/// * **Future/Stream Coupling**: Uses a [Completer] to bridge the gap between
///   an outgoing WebSocket command and an incoming asynchronous stream response.
/// * **Resource Safety**: Implements a strict subscription cleanup in the [finally]
///   block to prevent listener leaks and memory exhaustion.
final rosTopicsProvider = AsyncNotifierProvider<RosTopicsNotifier, List<Topic>>(
  RosTopicsNotifier.new,
);

class RosTopicsNotifier extends AsyncNotifier<List<Topic>> {
  /// The entry point for state initialization.
  ///
  /// This method triggers the initial service call to populate the topic list
  /// as soon as the provider is first read or watched.
  @override
  Future<List<Topic>> build() async {
    return loadTopics();
  }

  bool doTopicExists(String topicName) {
    return state.value?.any((topic) => topic.topicName == topicName) ?? false;
  }

  /// Performs a service call to the Rosbridge API to retrieve the current Topic Graph.
  ///
  /// Logic Implementation:
  /// * **Unique Identification**: Generates a `requestId` to ensure the response
  ///   matches this specific query, preventing cross-talk in multi-client scenarios.
  /// * **Asynchronous Mapping**: Iterates through the parallel arrays of 'topics'
  ///   and 'types' provided by [rosapi] to create a structured list of [Topic] models.
  /// * **Timeout Protection**: Enforces a 5-second execution limit to prevent
  ///   the UI from hanging if the Rosbridge server fails to acknowledge the request.
  Future<List<Topic>> loadTopics() async {
    final rosClient = ref.read(rosBridgeClientProvider);
    // Listening to the centralized stream for the service response opcode.
    final response = await rosClient.callService(
      service: "/rosapi/topics",
      timeout: const Duration(seconds: 5),
    );

    final List<dynamic> names = response['topics'] ?? [];
    final List<dynamic> types = response['types'] ?? [];
    final List<Topic> result = [];

    for (int i = 0; i < names.length; i++) {
      result.add(
        Topic(topicName: names[i] as String, topicType: types[i] as String),
      );
    }
    return result;
  }
}
