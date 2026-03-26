import 'package:flutter_riverpod/flutter_riverpod.dart';

final showDetailProvider = NotifierProvider<ShowDetailsNotifier, bool>(
  ShowDetailsNotifier.new,
);

class ShowDetailsNotifier extends Notifier<bool> {
  void toggleBanner() {
    bool oldState = !state;
    state = oldState;
  }

  @override
  bool build() {
    return false;
  }
}
