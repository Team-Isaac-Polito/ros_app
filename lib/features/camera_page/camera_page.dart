import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/camera_page/components/camera_switch/camera_switch.dart';
import 'package:isaac_app/features/camera_page/data/camera_status_service_provider/camera_status_service_notifier.dart';
import 'package:isaac_app/utils/palette.dart';

class CameraPage extends ConsumerWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final camera = ref.watch(cameraProvider);

    return Scaffold(
      appBar: AppBar(title: Text("Camera page"), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CameraSwitch(cameraNumber: 'Camera 1'),
                CameraSwitch(cameraNumber: 'Camera 2'),
              ],
            ),
            camera.when(
              data: (cameraValue) {
                return Text("Current camera mode: $cameraValue");
              },
               error: (err, st) => Text(err.toString()),
              loading: () => const CircularProgressIndicator(),
               )
          ],
        ),
      ),
    );
  }
}
