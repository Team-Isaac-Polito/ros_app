import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/data/dark_mode_provider/dark_mode_provider.dart';
import 'package:isaac_app/utils/index.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class VelocitySensor extends ConsumerWidget {
  final double velocity;
  const VelocitySensor({super.key, required this.velocity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(darkModeProvider);

    return Column(
      spacing: 20,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("Velocita'"),
        SfRadialGauge(
          axes: <RadialAxis>[
            RadialAxis(
              minimum: 0,
              maximum: 150,
              ranges: <GaugeRange>[
                GaugeRange(startValue: 0, endValue: 50, color: Colors.green),
                GaugeRange(startValue: 50, endValue: 100, color: Colors.orange),
                GaugeRange(startValue: 100, endValue: 150, color: Colors.red),
              ],
              pointers: <GaugePointer>[
                NeedlePointer(
                  value: velocity,
                  enableAnimation: true,
                  needleColor: isDark ? white : black,
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
      ],
    );
  }
}
