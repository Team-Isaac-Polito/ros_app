import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/data/dark_mode_provider/dark_mode_provider.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class VelocitySensor extends ConsumerWidget {
  final double velocity;
  const VelocitySensor({super.key, required this.velocity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(darkModeProvider);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            spacing: 20,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Velocity'"),
              Expanded(
                child: SfRadialGauge(
                  axes: <RadialAxis>[
                    RadialAxis(
                      minimum: 0,
                      maximum: 0.25,
                      ranges: <GaugeRange>[
                        GaugeRange(
                          startValue: 0,
                          endValue: 0.1,
                          color: Colors.green,
                        ),
                        GaugeRange(
                          startValue: 0.1,
                          endValue: 0.2,
                          color: Colors.orange,
                        ),
                        GaugeRange(
                          startValue: 0.2,
                          endValue: 0.25,
                          color: Colors.red,
                        ),
                      ],
                      pointers: <GaugePointer>[
                        NeedlePointer(
                          value: velocity, // Ensure this isn't NaN or Null
                          enableAnimation: true,
                          needleColor: isDark ? Colors.white : Colors.black,
                        ),
                      ],
                      annotations: <GaugeAnnotation>[
                        GaugeAnnotation(
                          widget: Text(
                            '${velocity.toStringAsFixed(1)} m/s',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          angle: 90,
                          positionFactor: 0.5,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
