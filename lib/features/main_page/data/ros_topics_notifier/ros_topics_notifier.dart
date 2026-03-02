import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/data/ros_bridge_provider/ros_bridge_provider.dart';
import 'package:isaac_app/features/main_page/data/ros_bridge_stream_provider/ros_bridge_stream_provider.dart';
import 'package:isaac_app/features/main_page/models/index.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

<<<<<<< HEAD
=======
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
>>>>>>> ed34974 (Modifiche a modules_page)
final rosTopicsProvider = AsyncNotifierProvider<RosTopicsNotifier, List<Topic>>(
  RosTopicsNotifier.new,
);

class RosTopicsNotifier extends AsyncNotifier<List<Topic>> {
<<<<<<< HEAD
=======
  /// The entry point for state initialization.
  ///
  /// This method triggers the initial service call to populate the topic list
  /// as soon as the provider is first read or watched.
>>>>>>> ed34974 (Modifiche a modules_page)
  @override
  Future<List<Topic>> build() async {
    return loadTopics();
  }

<<<<<<< HEAD
  Future<List<Topic>> loadTopics() async {
    final WebSocketChannel channel = ref.watch(rosBridgeProvider);
    final Stream<String> stream = ref.read(rosBridgeStreamProvider);
    // Creiamo un ID univoco per questa specifica chiamata
    final requestId = "get_topics_${DateTime.now().millisecondsSinceEpoch}";
    final completer = Completer<List<Topic>>();
    // Usiamo lo stream già filtrato dal provider per non appesantire la CPU
=======
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
    final WebSocketChannel channel = ref.watch(rosBridgeProvider);
    final Stream<String> stream = ref.read(rosBridgeStreamProvider);

    final requestId = "get_topics_${DateTime.now().millisecondsSinceEpoch}";
    final completer = Completer<List<Topic>>();

    // Listening to the centralized stream for the service response opcode.
>>>>>>> ed34974 (Modifiche a modules_page)
    final subscription = stream.listen((message) {
      final Map<String, dynamic> data = jsonDecode(message);

      if (data['op'] == 'service_response' &&
          data['service'] == '/rosapi/topics' &&
          data['id'] == requestId) {
        final Map<String, dynamic> values = data['values'];
        final List<Topic> result = [];

<<<<<<< HEAD
=======
        // Parallel processing of ROS 2 topic names and their respective message types.
>>>>>>> ed34974 (Modifiche a modules_page)
        for (int i = 0; i < values['topics'].length; i++) {
          result.add(
            Topic(
              topicName: values['topics'][i],
              topicType: values['types'][i],
            ),
          );
        }

        if (!completer.isCompleted) completer.complete(result);
      }
    });

<<<<<<< HEAD
=======
    // Dispatching the service request to the Rosbridge server.
>>>>>>> ed34974 (Modifiche a modules_page)
    channel.sink.add(
      jsonEncode({
        "op": "call_service",
        "service": "/rosapi/topics",
<<<<<<< HEAD
        "id": requestId, // Usiamo l'ID univoco
=======
        "id": requestId,
>>>>>>> ed34974 (Modifiche a modules_page)
      }),
    );

    try {
      return await completer.future.timeout(const Duration(seconds: 5));
    } finally {
<<<<<<< HEAD
      // Pulizia: cancelliamo SEMPRE la sottoscrizione, sia in successo che in errore/timeout
=======
      // Cleanup: Mandatory cancellation of the stream listener to free resources.
>>>>>>> ed34974 (Modifiche a modules_page)
      subscription.cancel();
    }
  }
}
