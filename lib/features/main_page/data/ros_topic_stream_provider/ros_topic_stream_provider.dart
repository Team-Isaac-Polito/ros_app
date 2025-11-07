import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/data/index.dart';
import 'package:isaac_app/features/main_page/models/index.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/*
* This is an asyncronous provider used to subscribe to a specific topic
* and read all the traffic about this topic
* */
final rosTopicsStreamProvider = StreamProvider<dynamic>((ref) async* {
  final WebSocketChannel channel = ref.read(rosBridgeProvider);
  final completer = Completer<List<Topic>>();

  final request = {
    "op": "call_service",
    "service": "/rosapi/nodes",
    "id": "nodes_request_1"
  };
  channel.sink.add(request);

  channel.stream.listen((message) {
    final data = jsonDecode(message);
    if (data['op'] == 'set_topics' || data['op'] == 'topics') {
      final topics = (data['topics'] as List).cast<String>();
      final types = (data['types'] as List).cast<String>();
      print("DEBUG - $topics $types");
      final list = List.generate(
        topics.length,
            (i) => Topic(topicName: topics[i], topicType: types[i]),
      );
      completer.complete(list);
    }
  });
});

final rosNodesStreamProvider = StreamProvider<List<String>>((ref) async* {
  final WebSocketChannel channel = ref.read(rosBridgeProvider);

  // Chiediamo a rosapi la lista dei nodi ROS
  final request = {
    "op": "call_service",
    "service": "/rosapi/nodes",
    "id": "nodes_request_1"
  };
  channel.sink.add(jsonEncode(request));

  await for (final message in channel.stream) {
    final data = jsonDecode(message);

    // Se è la risposta del servizio /rosapi/nodes
    if (data["service"] == "/rosapi/nodes" && data["values"] != null) {
      final nodes = (data["values"]["nodes"] as List).cast<String>();
      print("📡 Nodi ROS trovati: $nodes");
      yield nodes;
    }
  }
});
