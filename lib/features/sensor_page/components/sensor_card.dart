import 'package:flutter/material.dart';

class SensorCard extends StatelessWidget {
  const SensorCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10, top: 20, bottom: 20),
      width: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 5,
            children: [Text("77%"), Icon(Icons.battery_charging_full_rounded, color: Colors.blue,)],
          ),
        ],
      ),
    );
  }
}
