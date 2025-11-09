import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/data/ros_bridge_provider/ros_bridge_provider.dart';
import 'package:isaac_app/features/main_page/models/index.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

final rosTopicsProvider = AsyncNotifierProvider<RosTopicsNotifier, List<Topic>>(
  RosTopicsNotifier.new,
);

class RosTopicsNotifier extends AsyncNotifier<List<Topic>> {
  @override
  Future<List<Topic>> build() async {
    return await loadTopics();
  }

  Future<List<Topic>> loadTopics() async {
    final WebSocketChannel channel = ref.read(rosBridgeProvider);
    final Stream stream = ref.read(rosBridgeStreamProvider);

    final completer = Completer<List<Topic>>();
    late final StreamSubscription subscription;

    // ascolta il canale
    subscription = stream.listen((message) {
      try {
        final data = jsonDecode(message);

        // Debug: stampa la risposta per capire la struttura
        print('ROS Response: $data');

        // Controlla se è una risposta al servizio /rosapi/topics
        if (data['op'] == 'service_response' &&
            data['service'] == '/rosapi/topics') {
          final values = data['values'];
          if (values != null &&
              values['topics'] != null &&
              values['types'] != null) {
            final topics = (values['topics'] as List).cast<String>();
            final types = (values['types'] as List).cast<String>();

            final result = List.generate(
              topics.length,
              (i) => Topic(topicName: topics[i], topicType: types[i]),
            );

            if (!completer.isCompleted) {
              completer.complete(result);
              subscription.cancel();
            }
          }
        }
      } catch (e) {
        print('Error parsing ROS message: $e');
        if (!completer.isCompleted) {
          completer.completeError(e);
          subscription.cancel();
        }
      }
    });

    // Invia la richiesta
    channel.sink.add(
      jsonEncode({
        "op": "call_service",
        "service": "/rosapi/topics",
        "id": "topics_request_1",
      }),
    );

    return completer.future.timeout(
      Duration(seconds: 5),
      onTimeout: () {
        subscription.cancel();
        throw TimeoutException('Timeout waiting for ROS topics');
      },
    );
  }
}
