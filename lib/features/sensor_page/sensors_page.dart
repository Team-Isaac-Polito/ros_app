import 'package:flutter/material.dart';
import 'package:isaac_app/features/sensor_page/components/sensor_card.dart';

class SensorsPage extends StatelessWidget {
  const SensorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sensors"), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            Text("Active modules: 5 su 60"),
            ExpansionTile(
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
            SizedBox(
              height: 150,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: 2,
                    itemBuilder: (BuildContext context, int index) {
                      return SensorCard();
                    },
                )
            ),
          ],
        ),
      ),
    );
  }
}
