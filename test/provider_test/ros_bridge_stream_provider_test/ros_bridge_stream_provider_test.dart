import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/data/index.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MockWebSocketChannel extends Mock implements WebSocketChannel {}

void main() {
  late ProviderContainer container;
  late MockWebSocketChannel mockChannel;
  late StreamController<String> streamController;

  setUp(() {
    mockChannel = MockWebSocketChannel();
    streamController = StreamController<String>.broadcast();

    when(() => mockChannel.stream).thenAnswer((_) => streamController.stream);
    container = ProviderContainer(
      overrides: [rosBridgeProvider.overrideWithValue(mockChannel)],
    );
  });

  tearDown(() {
    streamController.close();
    container.dispose();
  });

  test('RosBridge should transmit data received from websocket', () async {
    final stream = container.read(rosBridgeStreamProvider);
    const mockData =
        '{"op": "publish", "topic": "/thermal", "msg": "test_data"}';

    final futureExpect = expectLater(
      stream,
      emitsInOrder([mockData, 'second_message']),
    );
    streamController.add(mockData);
    streamController.add('second_message');

    await futureExpect;
  });

  test('Test if rosBridgeStreamProvider is broadcast', () {
    final stream = container.read(rosBridgeStreamProvider);

    expect(stream.isBroadcast, isTrue);
  });
}
