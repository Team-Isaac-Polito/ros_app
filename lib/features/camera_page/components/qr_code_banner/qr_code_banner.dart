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
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Scanned Qrcode",
                style: TextStyle(
                  fontWeight: FontWeight.bold
                ),
              ),
              const SizedBox(height: 8),
              Divider(),
              ...qrCode.map((elm) {
              return Text(elm);
            })
            ],
          ),
        );
      },
      error: (err, st) => Text("QR error ${err.toString()}"),
      loading: () => const CircularProgressIndicator(),
    );
  }
}
