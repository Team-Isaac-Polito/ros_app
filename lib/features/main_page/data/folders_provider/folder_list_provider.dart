import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/camera_page/camera_page.dart';
import 'package:isaac_app/features/main_page/models/folder/folder.dart';
import 'package:isaac_app/features/modules_page/index.dart';
import 'package:isaac_app/features/sensors_page/sensors_page.dart';

/// Provides an immutable list of [Folder] models for the dashboard navigation.
///
/// This is a **Constant Provider** (read-only). In Riverpod, using a basic [Provider]
/// for static data is an architectural best practice to achieve **Dependency Injection**.
/// It decouples the UI from the data source, making the application more testable
/// and maintainable.
///
/// Reference:
/// * Riverpod - Why Providers?: https://riverpod.dev/docs/concepts/providers
/// * Clean Architecture - Data Layer: https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html
///
/// Design Pattern:
/// * **Static Injection**: Centralizes the configuration of the main navigation
///   hub (Control Panel).
/// * **Immutability**: Since the robot's primary feature set is defined at
///   compile-time, this list remains constant to prevent unnecessary UI rebuilds.
final folderListProvider = Provider<List<Folder>>(
  (ref) => [
    Folder(
      name: "modules",
      icon: Icons.extension,
      goTopage: const ModulesPage(),
    ),
    Folder(name: "sensors", icon: Icons.sensors, goTopage: const SensorsPage()),
    Folder(
      name: "Camera",
      icon: Icons.camera_alt_rounded,
      goTopage: const CameraPage(),
    ),
  ],
);
