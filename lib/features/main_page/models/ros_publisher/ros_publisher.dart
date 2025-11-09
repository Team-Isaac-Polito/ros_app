import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class RosPublisher {
  final WebSocketChannel channel;
  final Stream<String> stream;

  RosPublisher(this.channel, this.stream);

  /// Publish a message to a topic
  void publish(String topic, Map<String, dynamic> message) {
    channel.sink.add(
      jsonEncode({"op": "publish", "topic": topic, "msg": message}),
    );
  }

  /// Subscribe to a topic and returns the stream of that topic
  Stream<Map<String, dynamic>> subscribe(String topic) {
    channel.sink.add(jsonEncode({"op": "subscribe", "topic": topic}));

    // Filter only messages that I requested
    return stream
        .map((event) {
          try {
            final data = jsonDecode(event);
            if (data["op"] == "publish" && data["topic"] == topic) {
              return data["msg"] as Map<String, dynamic>;
            }
          } catch (e) {
            print("Errore nel parsing messaggio ROS: $e");
          }
          return <String, dynamic>{};
        })
        .where((msg) => msg.isNotEmpty);
  }
}