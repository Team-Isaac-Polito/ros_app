import 'package:flutter_riverpod/flutter_riverpod.dart';

final numberOfActiveModulesProvider = NotifierProvider(
  NumberOfActiveModuleProvider.new
);

class NumberOfActiveModuleProvider extends Notifier<int> {
  void increment() {
    state++;
  }

  void decrement() {
    state--;
  }

  @override
  int build() {
    return 0;
  }
}
