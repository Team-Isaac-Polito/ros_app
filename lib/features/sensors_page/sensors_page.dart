import 'package:flutter/material.dart';
import 'package:isaac_app/features/sensors_page/components/index.dart';

class SensorsPage extends StatelessWidget {
  const SensorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Sensors"),
          centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 36, vertical: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              VelocityDisplay(),
              TemperatureSensor(),
              LatencyChartWidget()
            ],
          ),
        ),
      ),
    );
  }
}
