import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';


// ONLY READ PROVIDER!
// This provider starts the connection to the WebSocket and automatically close
// it. It returns the opened channel.
final rosBridgeProvider = Provider<WebSocketChannel>((ref){
  // Connect to the websocket
  final WebSocketChannel channel = WebSocketChannel.connect(
    Uri.parse("ws://localhost:9090"),
  );

  channel.stream.listen(
        (message) {
      print("✅ ROS message: $message");
    },
    onError: (error) {
      print("❌ ROS connection error: $error");
    },
    onDone: () {
      print("⚠️ ROS connection closed");
    },
  );

  // close the connection when the connection is finished
  // in order to avoid memory leak
  ref.onDispose(() => channel.sink.close());

  return channel;
});