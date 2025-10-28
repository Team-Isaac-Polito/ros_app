import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/control_panel/models/index.dart';
import 'package:isaac_app/features/sensor_page/sensors_page.dart';

final folderListProvider = Provider<List<Folder>>(
        (ref) => [
          Folder(
              name: "sensors",
              icon: Icons.sensors,
              goTopage: SensorsPage()
          ),
          Folder(
              name: "wheels",
              icon: Icons.wheelchair_pickup,
              goTopage: Container(),
          ),
        ]
);