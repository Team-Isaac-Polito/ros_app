import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/components/control_panel_card/control_panel_card.dart';
import 'package:isaac_app/features/main_page/components/index.dart';
import 'package:isaac_app/features/main_page/data/folders_provider/folder_list_provider.dart';
import 'package:isaac_app/features/main_page/data/index.dart';
import 'package:isaac_app/features/main_page/data/ros_topics_notifier/ros_topics_notifier.dart';
import 'package:isaac_app/features/main_page/models/folder/folder.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  // Controllers per i form
  final TextEditingController _linearXController = TextEditingController();
  final TextEditingController _angularZController = TextEditingController();
  String _lastMessage = 'Nessun dato ricevuto';

  @override
  void initState() {
    super.initState();
    // Sottoscrivi ai messaggi ROS quando il widget è inizializzato
    _subscribeToRosTopic();
  }

  void _subscribeToRosTopic() {
    final stream = ref.read(rosBridgeStreamProvider);
    final channel = ref.read(rosBridgeProvider);

    // Sottoscrivi a un topic (esempio: /cmd_vel)
    channel.sink.add(jsonEncode({"op": "subscribe", "topic": "/cmd_vel"}));

    // Ascolta i messaggi in arrivo
    stream.listen((message) {
      final data = jsonDecode(message);
      if (data['topic'] == '/cmd_vel' && data['op'] == 'publish') {
        setState(() {
          _lastMessage =
              'Linear X: ${data['msg']['linear']['x']}, Angular Z: ${data['msg']['angular']['z']}';
        });
      }
    });
  }

  void _sendCommand() {
    final channel = ref.read(rosBridgeProvider);
    final linearX = double.tryParse(_linearXController.text) ?? 0.0;
    final angularZ = double.tryParse(_angularZController.text) ?? 0.0;

    // Invia il messaggio al topic
    channel.sink.add(
      jsonEncode({
        "op": "publish",
        "topic": "/cmd_vel",
        "msg": {
          "linear": {"x": linearX, "y": 0.0, "z": 0.0},
          "angular": {"x": 0.0, "y": 0.0, "z": angularZ},
        },
      }),
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Comando inviato!')));
  }

  void _stopRobot() {
    final channel = ref.read(rosBridgeProvider);

    channel.sink.add(
      jsonEncode({
        "op": "publish",
        "topic": "/cmd_vel",
        "msg": {
          "linear": {"x": 0.0, "y": 0.0, "z": 0.0},
          "angular": {"x": 0.0, "y": 0.0, "z": 0.0},
        },
      }),
    );

    _linearXController.clear();
    _angularZController.clear();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Robot fermato!')));
  }

  @override
  void dispose() {
    _linearXController.dispose();
    _angularZController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Inizializza la connessione ROS
    ref.watch(rosBridgeProvider);

    final folders = ref.watch(folderListProvider);
    final topics = ref.watch(rosTopicsProvider);

    return Scaffold(
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 18),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DarkModeSwitcher(),

              SizedBox(height: 16),

              // Card per visualizzare i dati in arrivo
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dati in tempo reale',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 8),
                      Text(_lastMessage),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Form per inviare comandi
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Invia comandi al robot',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 16),

                      TextField(
                        controller: _linearXController,
                        decoration: InputDecoration(
                          labelText: 'Velocità Lineare (X)',
                          border: OutlineInputBorder(),
                          hintText: '0.5',
                        ),
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),

                      SizedBox(height: 12),

                      TextField(
                        controller: _angularZController,
                        decoration: InputDecoration(
                          labelText: 'Velocità Angolare (Z)',
                          border: OutlineInputBorder(),
                          hintText: '0.0',
                        ),
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),

                      SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _sendCommand,
                              icon: Icon(Icons.send),
                              label: Text('Invia'),
                            ),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: _stopRobot,
                            icon: Icon(Icons.stop),
                            label: Text('Stop'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Lista dei folders
              SizedBox(
                height: 200,
                child: Wrap(
                  children: folders.map((Folder f) {
                    return ControlPanelCard(element: f);
                  }).toList(),
                ),
              ),

              SizedBox(height: 30),

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
                                  itemBuilder: (context, i) => ListTile(
                                    leading: Icon(Icons.topic),
                                    title: Text(list[i].topicName),
                                    subtitle: Text(list[i].topicType),
                                    dense: true,
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
