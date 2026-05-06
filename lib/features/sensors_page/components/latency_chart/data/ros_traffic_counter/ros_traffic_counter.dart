import 'package:flutter_riverpod/flutter_riverpod.dart';

class RosTrafficCounter extends Notifier<double> {
  @override
  double build() {
    return 0.0;
  }

  void increment(double increment) {
    state = state+increment;
  }

}

final rosTrafficCounterProvider = NotifierProvider<RosTrafficCounter, double>(
  RosTrafficCounter.new
);