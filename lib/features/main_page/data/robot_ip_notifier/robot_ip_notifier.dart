import 'package:flutter_riverpod/flutter_riverpod.dart';

class RobotIpNotifier extends Notifier<String> {
  // This is a notifier qwhich only aim is to provide the current robot ip
  void changeIp(String newRobotIp){
    state = newRobotIp;
  }

  // The build method returns by default the localhost:9090!
  @override 
  String build() {
    return 'ws://localhost:9090';
  }
}