import 'package:flutter_riverpod/flutter_riverpod.dart';

final numberOfModulesProvider = NotifierProvider(
  NumberOfModuleProvider.new
);

class NumberOfModuleProvider extends Notifier<int> {
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
