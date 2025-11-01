import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/data/ros_bridge_provider/ros_bridge_provider.dart';
import 'package:isaac_app/features/main_page/models/index.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/*
* This provider returns to us an editable list of nodes with topics to use in
* the UI (use it with AsyncValue!!!!!)
* */
final rosTopicsProvider = AsyncNotifierProvider<RosTopicsNotifier, List<Topic>>(
    RosTopicsNotifier.new
);

class RosTopicsNotifier extends AsyncNotifier<List<Topic>> {
  @override
  Future<List<Topic>> build() {
    final WebSocketChannel channel = ref.read(rosBridgeProvider);
    final completer = Completer<List<Topic>>();

    final subscription = channel.stream.listen((message) {
      final data = jsonDecode(message);
      if (data['service'] == "/rosapi/topics_and_types"){
        final topics = (data['values']['topics'] as List).cast<String>();
        final types = (data['values']['types'] as List).cast<String>();
        
        final result = List.generate(
          topics.length,
            (int i) => Topic(topicName: topics[i], topicType: types[i])
        );
      }
    });
    
    channel.sink.add(
      jsonEncode({
        "op": "call_service",
        "service": "rosapi/topics_and_types",
        "id": "topics_and_types_request"
      })
    );

    return completer.future;
  }
}