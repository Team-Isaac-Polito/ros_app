import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/camera_page/camera_page.dart';
import 'package:isaac_app/features/main_page/models/folder/folder.dart';
import 'package:isaac_app/features/modules_page/index.dart';
import 'package:isaac_app/features/sensors_page/sensors_page.dart';

/*
* This provider returns all the data for the card rendered in control
* panel.
* This is a only-read provider!!
* @params:
*    - element: the element to jump when the card is clicked
* */
final folderListProvider = Provider<List<Folder>>(
        (ref) => [
          Folder(
            name: "modules",
            icon: Icons.extension,
            goTopage: ModulesPage(),
          ),
          Folder(
              name: "sensors",
              icon: Icons.sensors,
              goTopage: SensorsPage()
          ),
          Folder(
              name: "Camera",
              icon: Icons.camera_alt_rounded,
              goTopage: CameraPage(),
          ),
          // Folder(
          //   name: "system",
          //   icon: Icons.settings,
          //   goTopage: Container(),
          // ),
        ]
);