import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/data/ros_bridge_stream_provider/ros_bridge_stream_provider.dart';
import 'package:isaac_app/features/main_page/models/ros_publisher/ros_publisher.dart';
import 'package:web_socket_channel/web_socket_channel.dart';


final rosPublisherProvider = Provider.family<RosPublisher, WebSocketChannel>((
  ref,
  WebSocketChannel channel,
) {
  final Stream<String> stream = ref.watch(rosBridgeStreamProvider);
  return RosPublisher(channel, stream);
});
