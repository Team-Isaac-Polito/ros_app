import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/data/ros_bridge_stream_provider/ros_bridge_stream_provider.dart';
import 'package:isaac_app/features/sensors_page/components/latency_chart/data/ros_traffic_counter/ros_traffic_counter.dart';

final rosTrafficProvider = Provider<Stream<String>>((ref) {
  final stream = ref.watch(rosBridgeStreamProvider);
  return stream.map((event) {
    ref
        .read(rosTrafficCounterProvider.notifier)
        .increment(event.toString().length.toDouble());
    return event;
  });
});
