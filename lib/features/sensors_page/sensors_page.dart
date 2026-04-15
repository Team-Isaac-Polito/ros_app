import 'package:flutter/material.dart';
import 'package:isaac_app/features/sensors_page/components/index.dart';

import '../main_page/components/index.dart';

class SensorsPage extends StatelessWidget {
  const SensorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sensors"), centerTitle: true, actions: [AppbarActions()],
),
      body: GridView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 450,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        children: [
          VelocityDisplay(),
          TemperatureSensor(),
          LatencyChartWidget(),
        ],
      ),
    );
  }
}
