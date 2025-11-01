import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/components/index.dart';
import 'package:isaac_app/features/main_page/data/index.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  late final WebSocketChannel channel;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final robots = ref.watch(robotsProvider);
    final topics = ref.watch(rosTopicsProvider);

    return Scaffold(
      appBar: AppBar(title: Text("Choose the robot"), centerTitle: true),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          children: [
            DarkModeSwitcher(),
            SizedBox(
              height: 200,
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
            topics.when(
                data: (list) => ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, i) => ListTile(
                    title: Text(list[i].topicName),
                    subtitle: Text(list[i].topicType),
                  ),
                ),
                error: (err, st) => Text(err.toString()),
                loading: () => const CircularProgressIndicator(),
            )
          ],
        ),
      ),
    );
  }
}
