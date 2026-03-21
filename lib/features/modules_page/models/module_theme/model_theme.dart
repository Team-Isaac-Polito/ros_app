import 'package:flutter/material.dart';

class ModuleTheme {
  final IconData icon;
  final Color color;
  final String displayName;

  const ModuleTheme({
    required this.icon, 
    required this.color, 
    required this.displayName,
  });

  static const fallback = ModuleTheme(
    icon: Icons.help_outline,
    color: Colors.grey,
    displayName: "UNKNOWN",
  );
}