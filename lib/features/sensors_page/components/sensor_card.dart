import 'package:flutter/material.dart';

class SensorCard extends StatelessWidget {
  const SensorCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10, top: 20, bottom: 20),
      padding: const EdgeInsets.symmetric(vertical: 10),
      width: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        border: Border.all(
          width: 1,
        )
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 10,
        children: [
          Switch(
            value: true,
            onChanged: (bool value) {},
          ),
          Icon(Icons.check, color: Colors.green,),
          Text("Nome sensore"),
        ],
      ),
    );
  }
}
