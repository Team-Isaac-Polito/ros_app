import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/models/index.dart';

class SelectRobotNotifier extends Notifier<SelectedRobot?> {

  void selectRobot(String name){
    // Function that accept the name of the robot ad
    // create an istance of SelectedRobot
    state = SelectedRobot(robotName: name);
  }

  void clearSelection() {
    // Clear the current selection of robot
    state = null;
  }

  @override
  SelectedRobot? build() {
    // The function returns null because
    // at the start no robots is selected
    return null;
  }
}

final selectedRobotProvider = NotifierProvider<SelectRobotNotifier, SelectedRobot?>(
    SelectRobotNotifier.new
);