import 'package:flutter/material.dart';
import 'package:isaac_app/utils/palette.dart';

class NoScreenshot extends StatelessWidget {
  const NoScreenshot({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: gray,
      child: const Center(child: Text("No screenshot")),
    );
  }
}
