import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/control_panel_page/data/gazebo_process_manager/gazebo_process_manager.dart';
import 'package:isaac_app/utils/index.dart';

class GazeboRunningBanner extends ConsumerWidget {
  const GazeboRunningBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gazeboProcessManagerNotifier = ref.read(
      gazeboProcessManagerProvider.notifier,
    );
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 20
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.blue,
      ),
      width: double.infinity,
      height: 30,
      child: Column(
        children: [
          Text(
            "Gazebo is not running now",
            style: TextStyle(color: white, fontWeight: FontWeight.bold),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              minimumSize: Size(
                double.infinity,
                30,
              )
            ),
            onPressed: () {
              gazeboProcessManagerNotifier.startGazebo();
            },
            child: Text(
              "Start it",
              style: TextStyle(
                color: black,
              )
            ),
          ),
        ],
      ),
    );
  }
}
