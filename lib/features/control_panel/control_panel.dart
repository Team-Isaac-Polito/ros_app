import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/control_panel/components/control_panel_card/control_panel_card.dart';
import 'package:isaac_app/features/control_panel/data/folders_provider/folder_list_provider.dart';
import 'package:isaac_app/features/control_panel/models/folder/folder.dart';
import 'package:isaac_app/features/main_page/data/index.dart';


/*
* This pages renders the control panel of the app
* where you can find all the cards that takes to
* different subsections of the app like sensor, modules, ecc
*
* */
class ControlPanel extends ConsumerWidget {
  const ControlPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRobot = ref.watch(selectedRobotProvider);
    final folders = ref.watch(folderListProvider);
    final topics = ref.watch(rosTopicsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(selectedRobot!.robotName), centerTitle: true),
      body: Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: Wrap(
                children: folders.map((Folder f) {
                  return ControlPanelCard(element: f);
                }).toList(),
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
            ),
          ],
        ),
      ),
    );
  }
}
