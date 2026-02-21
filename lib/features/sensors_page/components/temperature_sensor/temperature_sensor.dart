import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class TemperatureSensor extends StatelessWidget {
  const TemperatureSensor({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 20,
      children: [
        Text("Temperatura rilevata: "),
        SfLinearGauge(
          minimum: 0,
          maximum: 100,
          orientation: LinearGaugeOrientation.vertical,
          ranges: <LinearGaugeRange>[
            LinearGaugeRange(color: Colors.blue, startValue: 0, endValue: 50),
            LinearGaugeRange(color: Colors.red, startValue: 50, endValue: 100),
          ],
          markerPointers: [LinearShapePointer(value: 50)],
        ),
      ],
    );
  }
}
