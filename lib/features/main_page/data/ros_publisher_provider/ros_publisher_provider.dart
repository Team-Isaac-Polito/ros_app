import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

class RosPublisher {
  final WebSocketChannel channel;
  RosPublisher(this.channel);

  void publish(String topic, Map<String, dynamic> message) {
    channel.sink.add(
      jsonEncode({"op": "publish", "topic": topic, "msg": message}),
    );
  }

  void subscribe(String topic) {
    channel.sink.add(jsonEncode({
      "op": "subscribe",
      "topic": topic
    }));
  }
}
