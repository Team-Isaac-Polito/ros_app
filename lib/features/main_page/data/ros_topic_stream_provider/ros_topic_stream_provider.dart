import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/data/index.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/*
* This is an asyncronous provider used to subscribe to a specific topic
* and read all the traffic about this topic
* */
final rosTopicsStreamProvider = StreamProvider.family<dynamic, String>((ref, topicName) async* {
  final WebSocketChannel channel = ref.read(rosBridgeProvider);

  final subscription = jsonEncode({
    "op": "subscribe",
    "topic": topicName,
  });
  channel.sink.add(subscription);

  await for (final message in channel.stream) {
    final data = jsonDecode(message);
    if (data['topic'] == topicName) {
      yield data['msg'];
    }
  }
});