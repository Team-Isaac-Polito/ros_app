import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:isaac_app/features/control_panel_page/control_panel_page.dart';
import 'package:isaac_app/features/control_panel_page/data/autonomy_providers.dart';

/// 3D point representation in world space (x, y, z)
class Point3D {
  final double x;
  final double y;
  final double z;

  const Point3D({required this.x, required this.y, required this.z});

  Point3D rotate(double angleX, double angleY, double angleZ) {
    // Rotation matrices simplified for isometric view
    double x = this.x;
    double y = this.y;
    double z = this.z;

    // Rotate around Y axis (yaw)
    double cosY = math.cos(angleY);
    double sinY = math.sin(angleY);
    double xNew = x * cosY - z * sinY;
    double zNew = x * sinY + z * cosY;

    // Rotate around X axis (pitch)
    double cosX = math.cos(angleX);
    double sinX = math.sin(angleX);
    double yNew = y * cosX - zNew * sinX;
    zNew = y * sinX + zNew * cosX;

    // Rotate around Z axis (roll)
    double cosZ = math.cos(angleZ);
    double sinZ = math.sin(angleZ);
    double xFinal = xNew * cosZ - yNew * sinZ;
    yNew = xNew * sinZ + yNew * cosZ;

    return Point3D(x: xFinal, y: yNew, z: zNew);
  }

  Point3D translate(double dx, double dy, double dz) {
    return Point3D(x: x + dx, y: y + dy, z: z + dz);
  }

  Offset projectIsometric(double scale, Offset offset) {
    // Isometric projection: x goes diagonally right, y goes up, z goes diagonally left-up
    double screenX = (x - z) * scale * 0.866; // cos(30°)
    double screenY = (y + (x + z) * 0.5) * scale;
    return Offset(screenX + offset.dx, screenY + offset.dy);
  }
}

/// 3D Map and Robot Viewer - Isometric projection
class Map3DViewer extends StatefulWidget {
  final OccupancyGridData map;
  final List<MapWaypoint> waypoints;
  final RobotPose? robotPose;
  final List<SegmentPose> robotSegments;
  final List<LaserPoint> scanPoints;
  final bool showScan;

  const Map3DViewer({
    super.key,
    required this.map,
    required this.waypoints,
    required this.robotPose,
    required this.robotSegments,
    required this.scanPoints,
    required this.showScan,
  });

  @override
  State<Map3DViewer> createState() => _Map3DViewerState();
}

class _Map3DViewerState extends State<Map3DViewer> {
  double _rotationX = 0.3; // pitch: 0.3 rad ≈ 17°
  double _rotationY = 0.0; // yaw
  double _rotationZ = 0.0; // roll
  double _zoom = 1.0;
  Offset _panOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          // Right-click drag = rotate, Left drag = pan
          // For simplicity: two-finger drag = rotate, one-finger drag = pan
          _rotationY += details.delta.dx * 0.005;
          _rotationX += details.delta.dy * 0.005;
        });
      },
      onLongPressMoveUpdate: (details) {
        setState(() {
          _panOffset += details.offsetFromOrigin;
        });
      },
      child: MouseRegion(
        onHover: (event) {
          // Optional: implement advanced mouse control
        },
        child: Listener(
          onPointerSignal: (event) {
            if (event is PointerScrollEvent) {
              setState(() {
                _zoom *= event.scrollDelta.dy > 0 ? 0.95 : 1.05;
                _zoom = _zoom.clamp(0.5, 3.0);
              });
            }
          },
          child: CustomPaint(
            painter: _Map3DPainter(
              map: widget.map,
              waypoints: widget.waypoints,
              robotPose: widget.robotPose,
              robotSegments: widget.robotSegments,
              scanPoints: widget.showScan ? widget.scanPoints : [],
              rotationX: _rotationX,
              rotationY: _rotationY,
              rotationZ: _rotationZ,
              zoom: _zoom,
              panOffset: _panOffset,
            ),
            child: Container(),
          ),
        ),
      ),
    );
  }
}

class _Map3DPainter extends CustomPainter {
  final OccupancyGridData map;
  final List<MapWaypoint> waypoints;
  final RobotPose? robotPose;
  final List<SegmentPose> robotSegments;
  final List<LaserPoint> scanPoints;
  final double rotationX;
  final double rotationY;
  final double rotationZ;
  final double zoom;
  final Offset panOffset;

  _Map3DPainter({
    required this.map,
    required this.waypoints,
    required this.robotPose,
    required this.robotSegments,
    required this.scanPoints,
    required this.rotationX,
    required this.rotationY,
    required this.rotationZ,
    required this.zoom,
    required this.panOffset,
  });

  Offset _project3D(Point3D point, Size canvasSize) {
    // Rotate
    final rotated = point.rotate(rotationX, rotationY, rotationZ);

    // Isometric projection
    final screenX = (rotated.x - rotated.z) * zoom * 0.866;
    final screenY = (rotated.y + (rotated.x + rotated.z) * 0.5) * zoom;

    // Apply panning and center
    final centerX = canvasSize.width / 2;
    final centerY = canvasSize.height / 2;

    return Offset(
      centerX + screenX + panOffset.dx,
      centerY + screenY + panOffset.dy,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF0A0E27),
    );

    // Draw grid for reference
    _drawGrid(canvas, size);

    // Draw map as elevated floor
    _drawMapFloor(canvas, size);

    // Draw scan points if available
    if (scanPoints.isNotEmpty) {
      _drawScanPoints(canvas, size);
    }

    // Draw robot model
    if (robotPose != null) {
      _drawRobot(canvas, size);
    }

    // Draw waypoints
    if (waypoints.isNotEmpty) {
      _drawWaypoints(canvas, size);
    }

    // Draw axes indicator
    _drawAxesIndicator(canvas, size);

    // Draw help text
    _drawHelpText(canvas, size);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 0.5;

    const gridSize = 5.0; // meters
    const gridCount = 6;

    for (int i = -gridCount; i <= gridCount; i++) {
      // X-axis lines
      final p1 = _project3D(
        Point3D(x: i * gridSize, y: 0, z: -gridCount * gridSize),
        size,
      );
      final p2 = _project3D(
        Point3D(x: i * gridSize, y: 0, z: gridCount * gridSize),
        size,
      );
      canvas.drawLine(p1, p2, gridPaint);

      // Z-axis lines
      final p3 = _project3D(
        Point3D(x: -gridCount * gridSize, y: 0, z: i * gridSize),
        size,
      );
      final p4 = _project3D(
        Point3D(x: gridCount * gridSize, y: 0, z: i * gridSize),
        size,
      );
      canvas.drawLine(p3, p4, gridPaint);
    }

    // Draw ground plane center
    final center = _project3D(Point3D(x: 0, y: 0, z: 0), size);
    canvas.drawCircle(
      center,
      4,
      Paint()..color = Colors.green.withOpacity(0.5),
    );
  }

  void _drawMapFloor(Canvas canvas, Size size) {
    // Simplified: draw a few representative cells of the map as a floor texture
    final floorPaint = Paint()..color = const Color(0xFF2A3F5F);
    final obstaclePaint = Paint()..color = const Color(0xFF8B4513); // brown

    // Sample grid - draw only a subset for performance
    const sampleRate = 10; // Draw every 10th cell

    for (int y = 0; y < map.height; y += sampleRate) {
      for (int x = 0; x < map.width; x += sampleRate) {
        final value = map.valueAt(x, y);

        // Convert grid cell to world coords
        final wx = map.originX + x * map.resolution;
        final wy = map.originY + y * map.resolution;

        // Draw as a small 3D square
        final corners = [
          Point3D(x: wx, y: 0, z: wy),
          Point3D(x: wx + map.resolution * sampleRate, y: 0, z: wy),
          Point3D(
            x: wx + map.resolution * sampleRate,
            y: 0,
            z: wy + map.resolution * sampleRate,
          ),
          Point3D(x: wx, y: 0, z: wy + map.resolution * sampleRate),
        ];

        final projectedCorners = corners
            .map((p) => _project3D(p, size))
            .toList();

        // Choose color based on occupancy
        final paint = (value > 50) ? obstaclePaint : floorPaint;

        final path = Path();
        path.moveTo(projectedCorners[0].dx, projectedCorners[0].dy);
        for (final pt in projectedCorners.skip(1)) {
          path.lineTo(pt.dx, pt.dy);
        }
        path.close();
        canvas.drawPath(path, paint);
      }
    }
  }

  void _drawScanPoints(Canvas canvas, Size size) {
    final scanPaint = Paint()
      ..color = Colors.cyan.withOpacity(0.6)
      ..strokeWidth = 2;

    for (final scan in scanPoints) {
      final point3D = Point3D(
        x: scan.x,
        y: 0.1,
        z: scan.y,
      ); // Slightly above floor
      final projected = _project3D(point3D, size);
      canvas.drawCircle(projected, 1.5, scanPaint);
    }
  }

  void _drawRobot(Canvas canvas, Size size) {
    final robotPose = this.robotPose!;

    // Robot base (simplified as a box)
    const robotWidth = 0.4; // meters
    const robotLength = 0.6;
    const robotHeight = 0.3;

    // Calculate robot corners in world space
    final angle = robotPose.yaw;
    final cosA = math.cos(angle);
    final sinA = math.sin(angle);

    final corners3D = [
      // Bottom corners
      Point3D(
        x: robotPose.x - robotLength / 2 * cosA + robotWidth / 2 * sinA,
        y: 0,
        z: robotPose.y - robotLength / 2 * sinA - robotWidth / 2 * cosA,
      ),
      Point3D(
        x: robotPose.x + robotLength / 2 * cosA + robotWidth / 2 * sinA,
        y: 0,
        z: robotPose.y + robotLength / 2 * sinA - robotWidth / 2 * cosA,
      ),
      Point3D(
        x: robotPose.x + robotLength / 2 * cosA - robotWidth / 2 * sinA,
        y: 0,
        z: robotPose.y + robotLength / 2 * sinA + robotWidth / 2 * cosA,
      ),
      Point3D(
        x: robotPose.x - robotLength / 2 * cosA - robotWidth / 2 * sinA,
        y: 0,
        z: robotPose.y - robotLength / 2 * sinA + robotWidth / 2 * cosA,
      ),
      // Top corners (at height = robotHeight)
      Point3D(
        x: robotPose.x - robotLength / 2 * cosA + robotWidth / 2 * sinA,
        y: robotHeight,
        z: robotPose.y - robotLength / 2 * sinA - robotWidth / 2 * cosA,
      ),
      Point3D(
        x: robotPose.x + robotLength / 2 * cosA + robotWidth / 2 * sinA,
        y: robotHeight,
        z: robotPose.y + robotLength / 2 * sinA - robotWidth / 2 * cosA,
      ),
      Point3D(
        x: robotPose.x + robotLength / 2 * cosA - robotWidth / 2 * sinA,
        y: robotHeight,
        z: robotPose.y + robotLength / 2 * sinA + robotWidth / 2 * cosA,
      ),
      Point3D(
        x: robotPose.x - robotLength / 2 * cosA - robotWidth / 2 * sinA,
        y: robotHeight,
        z: robotPose.y - robotLength / 2 * sinA + robotWidth / 2 * cosA,
      ),
    ];

    final projected = corners3D.map((c) => _project3D(c, size)).toList();

    final robotPaint = Paint()
      ..color = const Color(0xFF1976D2)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Draw edges
    // Bottom square
    for (int i = 0; i < 4; i++) {
      canvas.drawLine(projected[i], projected[(i + 1) % 4], robotPaint);
    }
    // Top square
    for (int i = 4; i < 8; i++) {
      canvas.drawLine(projected[i], projected[4 + (i + 1) % 4], robotPaint);
    }
    // Vertical edges
    for (int i = 0; i < 4; i++) {
      canvas.drawLine(projected[i], projected[i + 4], robotPaint);
    }

    // Draw front direction indicator (arrow)
    final front = _project3D(
      Point3D(
        x: robotPose.x + robotLength / 2 * cosA,
        y: robotHeight / 2,
        z: robotPose.y + robotLength / 2 * sinA,
      ),
      size,
    );
    final center = _project3D(
      Point3D(x: robotPose.x, y: robotHeight / 2, z: robotPose.y),
      size,
    );
    final arrowPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2;
    canvas.drawLine(center, front, arrowPaint);
    canvas.drawCircle(front, 2, arrowPaint);
  }

  void _drawWaypoints(Canvas canvas, Size size) {
    final waypointPaint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 2;

    final pathPaint = Paint()
      ..color = Colors.yellow.withOpacity(0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw path
    if (waypoints.length > 1) {
      final path = Path();
      final first = _project3D(
        Point3D(x: waypoints[0].x, y: 0.05, z: waypoints[0].y),
        size,
      );
      path.moveTo(first.dx, first.dy);

      for (final wp in waypoints.skip(1)) {
        final pt = _project3D(Point3D(x: wp.x, y: 0.05, z: wp.y), size);
        path.lineTo(pt.dx, pt.dy);
      }
      canvas.drawPath(path, pathPaint);
    }

    // Draw waypoint spheres
    for (final wp in waypoints) {
      final pt = _project3D(Point3D(x: wp.x, y: 0.05, z: wp.y), size);
      canvas.drawCircle(pt, 4, waypointPaint);
    }
  }

  void _drawAxesIndicator(Canvas canvas, Size size) {
    // Draw X, Y, Z axes at top-left corner
    const axisSize = 30.0;
    const axisOffset = Offset(40, 40);

    // X axis (red)
    final xAxis = _project3D(Point3D(x: axisSize, y: 0, z: 0), Size.zero);
    canvas.drawLine(
      axisOffset,
      Offset(
        axisOffset.dx + xAxis.dx * zoom * 0.866,
        axisOffset.dy + xAxis.dy * zoom,
      ),
      Paint()
        ..color = Colors.red
        ..strokeWidth = 2,
    );

    // Label X
    final textPainterX = TextPainter(
      text: const TextSpan(
        text: 'X',
        style: TextStyle(color: Colors.red, fontSize: 14),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainterX.paint(
      canvas,
      Offset(axisOffset.dx + xAxis.dx * zoom * 0.866 + 5, axisOffset.dy),
    );

    // Y axis (green)
    final yAxis = _project3D(Point3D(x: 0, y: axisSize, z: 0), Size.zero);
    canvas.drawLine(
      axisOffset,
      Offset(
        axisOffset.dx + yAxis.dx * zoom * 0.866,
        axisOffset.dy + yAxis.dy * zoom,
      ),
      Paint()
        ..color = Colors.green
        ..strokeWidth = 2,
    );

    // Z axis (blue)
    final zAxis = _project3D(Point3D(x: 0, y: 0, z: axisSize), Size.zero);
    canvas.drawLine(
      axisOffset,
      Offset(
        axisOffset.dx + zAxis.dx * zoom * 0.866,
        axisOffset.dy + zAxis.dy * zoom,
      ),
      Paint()
        ..color = Colors.blue
        ..strokeWidth = 2,
    );
  }

  void _drawHelpText(Canvas canvas, Size size) {
    const textStyle = TextStyle(color: Colors.white70, fontSize: 12);

    final textPainter1 = TextPainter(
      text: const TextSpan(text: 'Drag to rotate • Scroll to zoom'),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter1.paint(canvas, Offset(10, size.height - 25));

    final textPainter2 = TextPainter(
      text: TextSpan(
        text:
            'Rotation: ${(rotationX * 180 / math.pi).toStringAsFixed(1)}°, '
            '${(rotationY * 180 / math.pi).toStringAsFixed(1)}°',
        style: textStyle,
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter2.paint(canvas, Offset(10, size.height - 10));
  }

  @override
  bool shouldRepaint(covariant _Map3DPainter old) => true;
}
