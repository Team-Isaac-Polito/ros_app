import 'package:flutter_riverpod/flutter_riverpod.dart';

final numberOfActiveModulesProvider = NotifierProvider<NumberOfActiveModule, int>(
  NumberOfActiveModule.new
);

class NumberOfActiveModule extends Notifier<int> {
  void increment() {
    state++;
  }

  void decrement() {
    if (state > 0) {
      state--;
    }
  }

  @override
  int build() {
    return 0;
  }
}
