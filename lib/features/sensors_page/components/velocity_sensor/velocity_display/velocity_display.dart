import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/sensors_page/components/velocity_sensor/velocity_sensor.dart';

class VelocityDisplay extends ConsumerWidget {
  const VelocityDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //final velocityAsync = ref.watch(velocityProvider);

    // return velocityAsync.when(
    //   data: (velocity) => VelocitySensor(velocity: velocity ?? 0),
    //   error: (err, st) => Text(err.toString()),
    //   loading: () => const CircularProgressIndicator()
    // );
    return VelocitySensor(velocity: 20);
  }
}
