import 'package:flutter/material.dart';
import 'package:isaac_app/features/sensor_page/components/sensor_card.dart';

class SensorsPage extends StatelessWidget {
  const SensorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sensors"), centerTitle: true),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Text("Active modules: 5 su 60"),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.3,
                child: ExpansionTile(
                  title: Text('Legenda simboli'),
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.check),
                      title: Text('working ok'),
                    ),
                    ListTile(
                      leading: Icon(Icons.warning),
                      title: Text('Warning'),
                    ),
                    ListTile(
                      leading: Icon(Icons.offline_bolt),
                      title: Text('Offline'),
                    ),
                  ],
                ),
              ),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SensorCard(),
                  SensorCard(),
                  SensorCard()
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
