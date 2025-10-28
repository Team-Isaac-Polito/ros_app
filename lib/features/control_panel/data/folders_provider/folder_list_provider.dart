import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/control_panel/models/index.dart';

final folderListProvider = Provider<List<Folder>>(
        (ref) => [
          Folder(name: "sensors", icon: Icons.sensors),
          Folder(name: "wheels", icon: Icons.wheelchair_pickup),
        ]
);