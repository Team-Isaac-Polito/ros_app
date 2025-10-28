import 'package:flutter/material.dart';
import 'package:isaac_app/features/control_panel/models/folder/folder.dart';

class ControlPanelCard extends StatelessWidget {
  final Folder element;
  const ControlPanelCard({super.key, required this.element});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: Colors.blue,
            ),
            child: Icon(
                element.icon,
                size: Theme.of(context).textTheme.displayLarge!.fontSize,
              color: Colors.white,
            ),
          ),
          Text(element.name),
        ],
      ),
    );
  }
}
