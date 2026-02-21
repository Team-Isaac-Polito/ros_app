import 'package:flutter/material.dart';

Color getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'active':
      return Colors.greenAccent;
    case 'error':
      return Colors.redAccent;
    case 'standby':
      return Colors.orangeAccent;
    default:
      return Colors.grey;
  }
}
