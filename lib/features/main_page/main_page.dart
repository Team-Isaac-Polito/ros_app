import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/components/index.dart';
import 'package:isaac_app/features/main_page/data/index.dart';
import 'package:web_socket_channel/web_socket_channel.dart';


/*
* This is the main page of the app
* It renders basic widgets like robots card (THE ROBOT ARE DETECTED AUTOMATICALLY)
* and the dark mode team switcher
*
* */
class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  late final WebSocketChannel channel;

  /* This method is called when widget is rendered for the first time */
  @override
  void initState() {
    super.initState();
  }

  /* This method is called every time when widget is cancelled */
  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final robots = ref.watch(robotsProvider);
    final rosNodesAsync = ref.watch(rosNodesStreamProvider);

    rosNodesAsync.whenData((nodeList) {
      // Aggiorniamo lo stato dei robot con i nodi ROS trovati
      final notifier = ref.read(robotsProvider.notifier);
      notifier.state = nodeList.map((node) =>
      {
        "robotName": node,
      }).toList();
    });

    return Scaffold(
      appBar: AppBar(title: Text("Choose the robot"), centerTitle: true),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          children: [
            DarkModeSwitcher(),
            SizedBox(
              height: 200,
              child: robots.isEmpty
                  ? const Center(child: Text("Nessun robot trovato 🤖"))
                  : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: robots.length,
                itemBuilder: (context, index) {
                  final currentRobot = robots[index];
                  return RobotCard(currentRobot: currentRobot);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
