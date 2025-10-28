import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/data/index.dart';

class ControlPanel extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRobot = ref.watch(selectedRobotProvider);

    return Scaffold(
        appBar: AppBar(
          title: Text(selectedRobot!.robotName),
          centerTitle: true,
        ),
    );
  }
}
