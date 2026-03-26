import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/camera_page/components/index.dart';

class DisplayedInfo extends ConsumerWidget {
  const DisplayedInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          const Expanded(
            child: HazmatBanner(),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white24,
            margin: const EdgeInsets.symmetric(horizontal: 10),
          ),
          const Expanded(
            child: QrCodeBanner(),
          ),
        ],
      ),
    );
  }
}
