import 'package:flutter_riverpod/flutter_riverpod.dart';

/*
* This is the robots list notifier. You can use it to add, edit, remove robots
*
* */
final robotsProvider = NotifierProvider(
  RobotsNotifier.new
);

class RobotsNotifier extends Notifier<List<Map<String, String>>> {

  void addRobot(Map<String, String> robot) {
    state = [...state, robot];
  }

  void removeRobot(String robotName) => state.where(
      (Map<String, String> r) => r["robotName"] != robotName
  ).toList();

  @override
  List<Map<String, String>> build() {
    return [];
  }
}
