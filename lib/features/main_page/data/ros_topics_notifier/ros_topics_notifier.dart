import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/data/ros_bridge_provider/ros_bridge_provider.dart';
import 'package:isaac_app/features/main_page/data/ros_bridge_stream_provider/ros_bridge_stream_provider.dart';
import 'package:isaac_app/features/main_page/models/index.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

final rosTopicsProvider = AsyncNotifierProvider<RosTopicsNotifier, List<Topic>>(
  RosTopicsNotifier.new,
);

class RosTopicsNotifier extends AsyncNotifier<List<Topic>> {
  @override
  Future<List<Topic>> build() async {
    return loadTopics();
  }

  Future<List<Topic>> loadTopics() async {
    final WebSocketChannel channel = ref.watch(rosBridgeProvider);
    final Stream<String> stream = ref.read(rosBridgeStreamProvider);
    // Creiamo un ID univoco per questa specifica chiamata
    final requestId = "get_topics_${DateTime.now().millisecondsSinceEpoch}";
    final completer = Completer<List<Topic>>();
    // Usiamo lo stream già filtrato dal provider per non appesantire la CPU
    final subscription = stream.listen((message) {
      final Map<String, dynamic> data = jsonDecode(message);

      if (data['op'] == 'service_response' &&
          data['service'] == '/rosapi/topics' &&
          data['id'] == requestId) {
        final Map<String, dynamic> values = data['values'];
        final List<Topic> result = [];

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

    channel.sink.add(
      jsonEncode({
        "op": "call_service",
        "service": "/rosapi/topics",
        "id": requestId, // Usiamo l'ID univoco
      }),
    );

    try {
      return await completer.future.timeout(const Duration(seconds: 5));
    } finally {
      // Pulizia: cancelliamo SEMPRE la sottoscrizione, sia in successo che in errore/timeout
      subscription.cancel();
    }
  }
}
