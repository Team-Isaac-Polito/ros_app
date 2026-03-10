import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/data/ros_bridge_provider/ros_bridge_provider.dart';

class RefreshSocketConnection extends ConsumerWidget {
  const RefreshSocketConnection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: Icon(Icons.refresh),
      onPressed: () {
        ref.refresh(rosBridgeProvider);
      },
    );
  }
}
