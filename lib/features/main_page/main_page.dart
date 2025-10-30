import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/components/index.dart';
import 'package:isaac_app/features/main_page/data/index.dart';

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final robots = ref.watch(robotsProvider);
    return Scaffold(
      appBar: AppBar(
          title: Text("Choose the robot"),
          centerTitle: true,
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          children: [
            DarkModeSwitcher(),
            Expanded(
              child: Row(
                children: [
                  SizedBox(
                    width: 155.0 * robots.length,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: robots.length,
                      itemBuilder: (BuildContext context, int index) {
                        final currentRobot = robots[index];
                        return RobotCard(currentRobot: currentRobot);
                      },
                    ),
                  ),
                  AddRobotButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
