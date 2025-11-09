// Provider per lo stream broadcast
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/data/ros_bridge_provider/ros_bridge_provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

final rosBridgeStreamProvider = Provider<Stream<String>>((ref) {
  final WebSocketChannel channel = ref.watch(rosBridgeProvider);
  // Converti in broadcast stream così può avere multipli listener

  return channel.stream.cast<String>().asBroadcastStream();
});