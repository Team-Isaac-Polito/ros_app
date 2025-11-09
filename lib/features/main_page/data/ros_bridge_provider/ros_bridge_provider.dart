
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';


// Provider che gestisce la connessione WebSocket
final rosBridgeProvider = Provider<WebSocketChannel>((ref) {
  final WebSocketChannel channel = WebSocketChannel.connect(
    Uri.parse("ws://localhost:9090"),
  );

  ref.onDispose(() => channel.sink.close());
  return channel;
});


