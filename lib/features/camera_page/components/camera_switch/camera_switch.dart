import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CameraSwitch extends StatefulWidget {
  final String cameraNumber;
  const CameraSwitch({super.key, required this.cameraNumber});

  @override
  State<CameraSwitch> createState() => _CameraSwitchState();
}

class _CameraSwitchState extends State<CameraSwitch> {
  bool V = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 20,
      children: [
        Text(widget.cameraNumber),
        Switch(
          value: V,
          onChanged: (bool value) {
            setState(() {
              V = !V;
            });
          },
        ),
      ],
    );
  }
}
