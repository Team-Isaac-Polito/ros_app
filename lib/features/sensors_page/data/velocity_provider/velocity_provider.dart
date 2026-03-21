import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/data/ros_bridgeclient_provider/ros_bridgeclient_provider.dart';

const String VELOCITY_PROVIDER = "/diff_controller1/cmd_vel";

final velocityProvider = StreamProvider<double?>((ref) {
  final rosSubscriber = ref.watch(rosBridgeClientProvider);

  return rosSubscriber.subscribe(VELOCITY_PROVIDER).map((msg) {
    print("Msg $msg");
  });
});
