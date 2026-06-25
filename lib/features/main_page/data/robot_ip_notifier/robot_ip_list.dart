import 'package:flutter_riverpod/flutter_riverpod.dart';

class RobotIpListNotifier extends Notifier<Map<String, String>> {
  @override
  Map<String, String> build() {
    return {
      "ws://localhost:9090": "Local (Simulator)",
      "ws://192.168.8.104:9090": "Robot (Physical)",
    };
  }

  void addIp(String ip, String label) {
    state = {
      ...state,
      ip: label,
    };
  }

  void removeIp(String ip) {
    if (ip == "ws://localhost:9090" || ip == "ws://192.168.8.104:9090") return;

    final newState = Map<String, String>.from(state);
    newState.remove(ip);
    state = newState;
  }
}

final robotIpListProvider =
    NotifierProvider<RobotIpListNotifier, Map<String, String>>(() {
  return RobotIpListNotifier();
});