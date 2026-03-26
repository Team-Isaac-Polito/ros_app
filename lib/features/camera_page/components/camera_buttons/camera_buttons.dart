import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/camera_page/components/index.dart';
import 'package:isaac_app/features/camera_page/data/index.dart';
import 'package:isaac_app/features/camera_page/models/camera_modes.dart';

class CameraButtons extends ConsumerWidget {
  const CameraButtons({super.key});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
      final cameraState = ref.watch(cameraProvider);
    return cameraState.when(
      data: (currentMode) => ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: CAMERA_MODE.values.length,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 150,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.5,
          ),
          itemBuilder: (context, index) {
            final mode = CAMERA_MODE.values[index];
            return CameraButton(mode: mode, currentMode: currentMode);
          },
        ),
      ),
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => Text("Error camera buttons: $e"),
    );
  }
}
