import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import  'package:isaac_app/features/main_page/data/robot_ip_notifier/robot_ip_provider.dart';

class ChangeIpDropdown extends ConsumerStatefulWidget {
  const ChangeIpDropdown({ Key? key }) : super(key: key);

  @override
  _ChangeIpDropdownState createState() => _ChangeIpDropdownState();
}

class _ChangeIpDropdownState extends ConsumerState<ChangeIpDropdown> {

  final List<String> robotIps = [
    "ws://localhost:9090",
    "ws://192.168.8.104:9090"
  ];
  @override
  Widget build(BuildContext context) {
    final robotIpNotifier = ref.read(robotIpProvider.notifier);
    final currentRobotIp = ref.watch(robotIpProvider);
    String dropdownValue = currentRobotIp;
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(height: 2, color: Colors.deepPurpleAccent),
      onChanged: (String? value) {
        setState(() {
          dropdownValue = value!;
        });
        robotIpNotifier.changeIp(value!);
      },
      items: robotIps.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
    );
  }
}