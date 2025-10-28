import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/control_panel/control_panel.dart';
import 'package:isaac_app/features/main_page/data/index.dart';

class RobotCard extends ConsumerWidget {
  final Map<String, String> currentRobot;
  const RobotCard({super.key, required this.currentRobot});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRobotNotifier = ref.watch(selectedRobotProvider.notifier);

    return Center(
      child: GestureDetector(
        onTap: () {
          selectedRobotNotifier.selectRobot(currentRobot["name"]!);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ControlPanel(),),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            border: Border.all(width: 1.0, color: Colors.black),
          ),
          child: Text(currentRobot["name"]!),
        ),
      ),
    );;
  }
}