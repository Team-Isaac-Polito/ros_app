import 'package:flutter_riverpod/flutter_riverpod.dart';

final robotIpListProvider = Provider<Map<String, String>>((ref) {
  return {
    "ws://localhost:9090": "Local (Simulator)",
    "ws://192.168.8.104:9090": "Robot (Physical)",
  };
});
