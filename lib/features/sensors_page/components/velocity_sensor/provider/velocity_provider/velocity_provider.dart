import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/data/ros_bridge_stream_provider/ros_bridge_stream_provider.dart';

final velocityProvider = StreamProvider<double?>((ref) {
  final rawStream = ref.watch(rosBridgeStreamProvider);

  return rawStream.map((event) {
    try {
      final data = jsonDecode(event);
      if (data["op"] == "publish" &&
          data["publish"] == "/camera/color/image_raw") {
        return data["msg"]["data"] as double;
      }
    } catch (e) {
      print("Errore decodifica immagine: $e");
    }
    return null;
  }).where((data) => data != null);
});
