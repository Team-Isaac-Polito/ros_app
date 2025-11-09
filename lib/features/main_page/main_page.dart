import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/components/control_panel_card/control_panel_card.dart';
import 'package:isaac_app/features/main_page/components/index.dart';
import 'package:isaac_app/features/main_page/data/folders_provider/folder_list_provider.dart';
import 'package:isaac_app/features/main_page/data/index.dart';
import 'package:isaac_app/features/main_page/data/ros_publisher_provider/ros_publisher_provider.dart';
import 'package:isaac_app/features/main_page/data/ros_topics_notifier/ros_topics_notifier.dart';
import 'package:isaac_app/features/main_page/models/folder/folder.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {

  @override
  Widget build(BuildContext context) {
    // Inizializza la connessione ROS
    final channel = ref.watch(rosBridgeProvider);
    final folders = ref.watch(folderListProvider);
    final topics = ref.watch(rosTopicsProvider);
    final rosPublisher = ref.watch(rosPublisherProvider(channel));

    return Scaffold(
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 18),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DarkModeSwitcher(),
              SizedBox(height: 16),

              // Form per inviare comandi
              // Card(
              //   child: Padding(
              //     padding: EdgeInsets.all(16),
              //     child: Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         Text(
              //           'Invia comandi al robot',
              //           style: Theme.of(context).textTheme.titleMedium,
              //         ),
              //         SizedBox(height: 16),

              //         TextField(
              //           controller: _linearXController,
              //           decoration: InputDecoration(
              //             labelText: 'Velocità Lineare (X)',
              //             border: OutlineInputBorder(),
              //             hintText: '0.5',
              //           ),
              //           keyboardType: TextInputType.numberWithOptions(
              //             decimal: true,
              //           ),
              //         ),

              //         SizedBox(height: 12),

              //         TextField(
              //           controller: _angularZController,
              //           decoration: InputDecoration(
              //             labelText: 'Velocità Angolare (Z)',
              //             border: OutlineInputBorder(),
              //             hintText: '0.0',
              //           ),
              //           keyboardType: TextInputType.numberWithOptions(
              //             decimal: true,
              //           ),
              //         ),

              //         SizedBox(height: 16),

              //         Row(
              //           children: [
              //             Expanded(
              //               child: ElevatedButton.icon(
              //                 onPressed: _sendCommand,
              //                 icon: Icon(Icons.send),
              //                 label: Text('Invia'),
              //               ),
              //             ),
              //             SizedBox(width: 8),
              //             ElevatedButton.icon(
              //               onPressed: _stopRobot,
              //               icon: Icon(Icons.stop),
              //               label: Text('Stop'),
              //               style: ElevatedButton.styleFrom(
              //                 backgroundColor: Colors.red,
              //               ),
              //             ),
              //           ],
              //         ),
              //       ],
              //     ),
              //   ),
              // ),

              // SizedBox(height: 16),

              // Lista dei folders
              SizedBox(
                height: 200,
                child: Wrap(
                  children: folders.map((Folder f) {
                    return ControlPanelCard(element: f);
                  }).toList(),
                ),
              ),

              SizedBox(height: 150),

              // Lista topics disponibili
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Topics disponibili',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 8),
                      topics.when(
                        data: (list) => list.isEmpty
                            ? Text('Nessun topic disponibile')
                            : SizedBox(
                                height: 300,
                                child: ListView.builder(
                                  itemCount: list.length,
                                  itemBuilder: (context, i) => ExpansionTile(
                                    leading: Icon(Icons.topic),
                                    title: Text(list[i].topicName),
                                    subtitle: Text(list[i].topicType),
                                    dense: true,
                                    children: [
                                      StreamBuilder<Map<String, dynamic>>(
                                        stream: rosPublisher.subscribe(
                                          list[i].topicName,
                                        ),
                                        builder:
                                            (
                                              BuildContext context,
                                              AsyncSnapshot snapshot,
                                            ) {
                                              if (!snapshot.hasData) {
                                                return Padding(
                                                  padding: EdgeInsets.all(8),
                                                  child: Text("In ascolto..."),
                                                );
                                              }
                                              return Padding(
                                                padding: EdgeInsets.all(8),
                                                child: Text(
                                                  jsonEncode(snapshot.data),
                                                  style: TextStyle(
                                                    fontFamily: 'monospace',
                                                  ),
                                                ),
                                              );
                                            },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        error: (err, st) => Text('Errore: ${err.toString()}'),
                        loading: () =>
                            Center(child: CircularProgressIndicator()),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
