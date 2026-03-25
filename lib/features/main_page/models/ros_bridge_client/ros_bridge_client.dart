import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:isaac_app/utils/convert_raw_to_png_image.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class RosBridgeClient {
  final WebSocketChannel channel;
  final Stream<String> stream;

  // Map to send duplicated subscription to the same topic
  final Map<String, Stream<Map<String, dynamic>>> _topicStreams = {};

  RosBridgeClient(this.channel, this.stream);

  /// Publish a message to a topic
  void publish(String topic, Map<String, dynamic> message) {
    channel.sink.add(
      jsonEncode({"op": "publish", "topic": topic, "msg": message}),
    );
  }

  /// Subscribe to a topic and returns the stream of that topic
  Stream<Map<String, dynamic>> subscribe(String topic) {
    if (!_topicStreams.containsKey(topic)) {
      channel.sink.add(jsonEncode({"op": "subscribe", "topic": topic}));

      _topicStreams[topic] = stream
          .map((event) {
            try {
              final data = jsonDecode(event);
              if (data["op"] == "publish" && data["topic"] == topic) {
                return data["msg"] as Map<String, dynamic>;
              }
            } catch (e) {
              print("Errore nel parsing messaggio ROS ($topic): $e");
            }
            return <String, dynamic>{};
          })
          .where((msg) => msg.isNotEmpty)
          .asBroadcastStream();
      // asBroascastStream() permette a piu ascoltatori di ascoltare contemporaneamente
    }
    return _topicStreams[topic]!;
  }

  Future<Map<String, dynamic>> callService({
    required String service,
    Map<String, dynamic>? args,
    Duration timeout = const Duration(seconds: 3),
  }) async {
    final String requestId =
        "call_${service}_${DateTime.now().millisecondsSinceEpoch}";
    final completer = Completer<Map<String, dynamic>>();

    final sub = stream.listen((message) {
      try {
        final data = jsonDecode(message);
        if (data["op"] == "service_response" && data["id"] == requestId) {
          if (!completer.isCompleted) {
            completer.complete(data["values"] ?? {});
          }
        }
      } catch (_) {}
    });

    try {
      channel.sink.add(
        jsonEncode({
          "op": "call_service",
          "service": service,
          if (args != null) "args": args,
          "id": requestId,
        }),
      );

      return await completer.future.timeout(timeout);
    } finally {
      sub.cancel();
    }
  }

  Stream<Map<String, dynamic>> allMessages() {
    return stream
        .map((event) {
          try {
            final data = jsonDecode(event);
            if (data['op'] == "publish") {
              return {
                "topic": data["topic"] as String,
                "msg": data["msg"] as Map<String, dynamic>,
              };
            }
          } catch (e) {
            print("Global Stream Error: $e");
          }
          return <String, dynamic>{};
        })
        .where((data) => data.isNotEmpty);
  }

  // we need to subscribe and after getting the first message unsubscribe directly
  Future<String> subscribeOnce(String topic) async {
    channel.sink.add(jsonEncode({"op": "subscribe", "topic": topic}));

    try {
      Map<String, dynamic>? decodedEvent;
      await stream
          .firstWhere((e) {
            final d = jsonDecode(e);
            decodedEvent = d;
            return d["op"] == "publish" && d["topic"] == topic;
          })
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              throw TimeoutException(
                "Il robot non ha risposto sul topic $topic entro 5 secondi",
              );
            },
          );

      channel.sink.add(jsonEncode({"op": "unsubscribe", "topic": topic}));

      final msg = decodedEvent?["msg"];
      final dynamic rawData = msg["data"];

      if (topic.endsWith("/compressed")) {
        if (rawData is String) {
          return rawData.replaceAll(RegExp(r'[\s\n\r]'), '');
        } else if (rawData is List) {
          return base64Encode(Uint8List.fromList(List<int>.from(rawData)));
        }
      } else {
        final int width = msg['width'];
        final int height = msg['height'];
        final String encoding = msg['encoding']; // es: "rgb8" o "bgr8"
        final List<int> bytes = rawData is String 
            ? base64Decode(rawData.replaceAll(RegExp(r'[\s\n\r]'), '')) 
            : List<int>.from(rawData);
            
        return await compute(_convertWrapper, {
          'bytes': bytes,
          'width': width,
          'height': height,
          'encoding': encoding,
        });
      }

      throw Exception("Dati immagine non validi");
    } catch (e) {
      channel.sink.add(jsonEncode({"op": "unsubscribe", "topic": topic}));
      rethrow;
    }
  }
}

String _convertWrapper(Map<String, dynamic> map) {
  return convertRawToPngBase64(
    map['bytes'],
    map['width'],
    map['height'],
    map['encoding'],
  );
}
