import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/control_panel/components/control_panel_card/control_panel_card.dart';
import 'package:isaac_app/features/control_panel/data/folders_provider/folder_list_provider.dart';
import 'package:isaac_app/features/control_panel/models/folder/folder.dart';
import 'package:isaac_app/features/main_page/data/index.dart';

class ControlPanel extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRobot = ref.watch(selectedRobotProvider);
    final folders = ref.watch(folderListProvider);

    return Scaffold(
        appBar: AppBar(
          title: Text(selectedRobot!.robotName),
          centerTitle: true,
        ),
      body: Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: folders.length,
            itemBuilder: (BuildContext context, int index) {
              final Folder currentFolder = folders[index];
              return ControlPanelCard(
                element: currentFolder
              );
            }),
      ),
    );
  }
}
