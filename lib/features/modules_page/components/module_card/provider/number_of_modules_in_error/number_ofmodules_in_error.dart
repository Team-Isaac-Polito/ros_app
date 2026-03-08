import 'package:flutter_riverpod/flutter_riverpod.dart';

final numberOfModulesInErrorProvider = NotifierProvider(
  NumberOfmodulesInError.new,
);

class NumberOfmodulesInError extends Notifier<int> {

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
