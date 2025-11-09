// It returns the traffic of a channel
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/data/ros_bridge_stream_provider/ros_bridge_stream_provider.dart';

final rosMessagesProvider = StreamProvider<Map<String, dynamic>>((ref) {
  // rosBridgeStreamProvider ritorna lo stream dei dati e io lo ascolto
  final stream = ref.watch(rosBridgeStreamProvider);

  return stream.map((event) {
    final data = jsonDecode(event);
    if (data['op'] == 'publish') {
      return {"topic": data["topic"], "msg": data["msg"]};
    }
    return {};
  });
});
