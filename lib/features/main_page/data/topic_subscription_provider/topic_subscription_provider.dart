import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/data/ros_bridge_stream_provider/ros_bridge_stream_provider.dart';

final topicSubscriptionProvider =
    StreamProvider.family<Map<String, dynamic>, String>((ref, topicName) {
      final rawStream = ref.watch(rosBridgeStreamProvider);
      return rawStream.map((event) {
        try {
          final data = jsonDecode(event);
          if (data["op"] == "publish" && data["topic"] == topicName) {
            return data["msg"] as Map<String, dynamic>;
          }
        } catch (e) {
          print("Eccezione in topicSubscriptionProvider $e");
        }
        return null;
      }).where((data) => data != null).cast<Map<String, dynamic>>();
    });
