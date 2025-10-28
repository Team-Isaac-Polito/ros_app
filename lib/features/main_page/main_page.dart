import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/data/index.dart';

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final robots = ref.watch(robotsProvider);
    final selectedRobotNotifier = ref.watch(selectedRobotProvider.notifier);

    return Scaffold(
      appBar: AppBar(
          title: Text("Choose the robot"),
          centerTitle: true,
      ),
      body: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: robots.length,
        itemBuilder: (BuildContext context, int index) {
          final currentRobot = robots[index];

          return Center(
            child: GestureDetector(
              onTap: () {
                selectedRobotNotifier.selectRobot(currentRobot["name"]!);
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
          );
        },
      ),
    );
  }
}
