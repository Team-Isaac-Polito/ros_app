import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/data/ros_bridge_provider/ros_bridge_provider.dart';
import 'package:test/test.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  test('Rosbridge connection should start on localhost:9090', () async {
    final container = ProviderContainer.test();
    addTearDown(container.dispose);

    final WebSocketChannel channel = container.read(rosBridgeProvider);

    await expectLater(channel.ready, completes);
  });
}
