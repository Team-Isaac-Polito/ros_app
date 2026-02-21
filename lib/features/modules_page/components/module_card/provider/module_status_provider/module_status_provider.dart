import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/data/index.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

final moduleStatusProvider =
    NotifierProvider.family<ModuleStatusNotifier, bool, String>((arg) {
      return ModuleStatusNotifier(arg);
    });

class ModuleStatusNotifier extends Notifier<bool> {
  ModuleStatusNotifier(this.arg);
  String arg;

  @override
  bool build() {
    // intial stauts: off
    return false;
  }

  void toggle(bool enable) {
    final WebSocketChannel channel = ref.watch(rosBridgeProvider);
    final serviceName = arg;
    state = enable;

    channel.sink.add(
      jsonEncode({
        'op': "call_service",
        "service": serviceName,
        "args": {"data": enable ? "enable" : "disable"},
      }),
    );

    print("ROS2: Service $serviceName set to $enable");
  }
}
