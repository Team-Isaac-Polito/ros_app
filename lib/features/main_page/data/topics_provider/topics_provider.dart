import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/data/ros_bridge_provider/ros_bridge_provider.dart';
import 'package:isaac_app/features/main_page/models/index.dart';
/*
* This provider returns to us an editable list of nodes with topics to use in
* the UI (use it with AsyncValue!!!!!)
* */
final rosTopicsProvider =
AsyncNotifierProvider<RosTopicsNotifier, List<Topic>>(
      RosTopicsNotifier.new,
);

class RosTopicsNotifier extends AsyncNotifier<List<Topic>> {

  @override
  Future<List<Topic>> build() async {
    await loadTopics();
    return [];
  }

  Future<void> loadTopics() async {
    final channel = ref.read(rosBridgeProvider);
    final completer = Completer<List<Topic>>();

    late final StreamSubscription subscription;
    subscription = channel.stream.listen((message) {
      final data = jsonDecode(message);
      if (data['service'] == "/rosapi/topics_and_types") {
        final topics = (data['values']['topics'] as List).cast<String>();
        final types = (data['values']['types'] as List).cast<String>();

        final result = List.generate(
          topics.length,
              (i) => Topic(topicName: topics[i], topicType: types[i]),
        );

        if (!completer.isCompleted) completer.complete(result);
        subscription.cancel();
      }
    });

    channel.sink.add(jsonEncode({
      "op": "call_service",
      "service": "rosapi/topics_and_types",
      "id": "topics_and_types_request"
    }));

    final list = await completer.future;
    state = AsyncData(list);
  }
}
