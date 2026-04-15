import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/data/ros_bridgeclient_provider/ros_bridgeclient_provider.dart';

final velocityProvider = StreamProvider<double?>((ref) {
  final rosBridgeClient = ref.read(rosBridgeClientProvider);
  final velocitySubscriber = rosBridgeClient.subscribe('/cmd_vel');
  

  return velocitySubscriber.map((msg){
    try {
      if (msg["linear"] != null && msg["linear"]["x"] != null) {
        return (msg["linear"]["x"] as num).toDouble();
      }
  } catch (e) {
    return 0.0;
  }
  }).asBroadcastStream();
});
