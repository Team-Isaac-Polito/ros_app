import 'package:flutter_riverpod/flutter_riverpod.dart';
import './robot_ip_notifier.dart';

final robotIpProvider = NotifierProvider<RobotIpNotifier, String>(
  () => RobotIpNotifier(),
);