import 'package:flutter/material.dart';

class ZoomIntent extends Intent {
  final double delta;
  const ZoomIntent(this.delta);
}
