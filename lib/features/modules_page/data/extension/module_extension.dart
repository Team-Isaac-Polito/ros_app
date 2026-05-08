import 'package:flutter/material.dart';
import 'package:isaac_app/features/modules_page/models/module_theme/model_theme.dart';

extension ServiceXTheme on String {
  ModuleTheme get toModuleTheme {
    final key = split('/').last.toLowerCase();

    return switch (key) {
      'thermal' || 'activate_thermal' => const ModuleTheme(
          icon: Icons.thermostat,
          color: Color.fromRGBO(255, 152, 0, 1),
          displayName: 'THERMAL',
        ),
      'lidar' || 'start_motor' || 'stop_motor' => const ModuleTheme(
          icon: Icons.motorcycle,
          color: Colors.green,
          displayName: 'LIDAR',
        ),
      _ => const ModuleTheme(
          icon: Icons.device_unknown,
          color: Colors.grey,
          displayName: 'UNKNOWN',
        ),
    };
  }
}
