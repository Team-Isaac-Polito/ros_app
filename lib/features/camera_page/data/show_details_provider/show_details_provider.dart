import 'package:flutter_riverpod/flutter_riverpod.dart';

final showDetailProvider = NotifierProvider<ShowDetailsNotifier, bool>(
  ShowDetailsNotifier.new,
);

class ShowDetailsNotifier extends Notifier<bool> {
  void toggleBanner() {
    state = !state;
  }

  @override
  bool build() {
    return false;
  }
}
