import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/camera_page/data/index.dart';

class QrCodeBanner extends ConsumerWidget {
  const QrCodeBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qrCodeAsync = ref.watch(qrTextDetectionProvider);

    return qrCodeAsync.when(
      data: (qrCode) {
        if (qrCode.isEmpty) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 18),
          width: double.infinity,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          child: Text("Qrcode value: $qrCode"),
        );
      },
      error: (err, st) => Text("QR error ${err.toString()}"),
      loading: () => const CircularProgressIndicator(),
    );
  }
}
