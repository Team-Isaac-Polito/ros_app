import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/data/ros_bridge_provider/ros_bridge_provider.dart';

class RefreshSocketConnection extends ConsumerStatefulWidget {
  const RefreshSocketConnection({super.key});

  @override
  ConsumerState<RefreshSocketConnection> createState() =>
      _RefreshSocketConnectionState();
}

class _RefreshSocketConnectionState
    extends ConsumerState<RefreshSocketConnection> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.refresh),
      onPressed: () {
        ref.refresh(rosBridgeProvider);
      },
    );
  }
}
