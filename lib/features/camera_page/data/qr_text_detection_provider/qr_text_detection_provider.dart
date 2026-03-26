import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/data/topic_subscription_provider/topic_subscription_provider.dart';

final qrTextDetectionProvider =
    AsyncNotifierProvider<QrTextDetectionNotifier, Set<String>>(
      QrTextDetectionNotifier.new,
    );

class QrTextDetectionNotifier extends AsyncNotifier<Set<String>> {
  @override
  FutureOr<Set<String>> build() {
    ref.listen(topicSubscriptionProvider("/qr_text"), (previous, next) {
      next.whenData((data) {
        final info = data['data'] ?? data['msg'] ?? "Detection not found";
        String scannedValue = info.toString();
        final currenState = state.value ?? {};
        state = AsyncData({...currenState, scannedValue});
      });
    });

    return {};
  }
}
