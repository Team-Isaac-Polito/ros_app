import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/camera_page/data/index.dart';

class HazmatBanner extends ConsumerWidget {
  const HazmatBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hazmatAsync = ref.watch(hazMatProvider);

    return hazmatAsync.when(
      data: (hazmat) {
        if (hazmat.isEmpty) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 18),
          width: double.infinity,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          child: Text("Hazmat value: $hazmat"),
        );
      },
      error: (err, st) => Text("Hazmat err: ${err.toString()}"),
      loading: () => const CircularProgressIndicator(),
    );
  }
}
