import 'package:flutter_riverpod/flutter_riverpod.dart';

final useGazebomapProvider = NotifierProvider<UseGazeboMapNotifier, bool>(
  UseGazeboMapNotifier.new,
);

// It manages gazebo screen showing
class UseGazeboMapNotifier extends Notifier<bool> {
  bool toggleGazebo() {
    state = !state;
    return state;
  }

  @override
  bool build() {
    state = false;
    return false;
  }
}
