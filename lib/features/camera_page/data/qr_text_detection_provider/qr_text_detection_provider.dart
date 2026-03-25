import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/data/topic_subscription_provider/topic_subscription_provider.dart';

final qrTextDetectionProvider =
    AsyncNotifierProvider<QrTextDetectionNotifier, String>(
      QrTextDetectionNotifier.new,
    );

class QrTextDetectionNotifier extends AsyncNotifier<String> {
  Timer? _timer;
  @override
  FutureOr<String> build() {
    ref.listen(topicSubscriptionProvider("/qr_text"), (previous, next) {
      next.whenData((data) {
        final info = data['data'] ?? data['msg'] ?? "Detection not found";
        state = AsyncData(info.toString());
        _timer?.cancel();
        _timer = Timer(const Duration(seconds: 5), () {
          state = const AsyncData("");
        });
      });
    });

    return "";
  }
}
