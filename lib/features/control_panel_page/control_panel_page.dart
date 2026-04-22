import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/control_panel_page/data/autonomy_providers.dart';
import 'package:isaac_app/features/main_page/components/index.dart';
import 'package:isaac_app/features/main_page/data/ros_bridgeclient_provider/ros_bridgeclient_provider.dart';

/// A 2-D waypoint in the map frame (meters).
class MapWaypoint {
  final double x;
  final double y;
  const MapWaypoint({required this.x, required this.y});
}

/// Page that shows the live SLAM map and lets the operator draw a path.
class ControlPanelPage extends ConsumerStatefulWidget {
  const ControlPanelPage({super.key});

  @override
  ConsumerState<ControlPanelPage> createState() => _ControlPanelPageState();
}

class _ControlPanelPageState extends ConsumerState<ControlPanelPage> {
  static const double _minPointSpacingMeters = 0.02;

  final TransformationController _transformCtrl = TransformationController();
  final GlobalKey _mapContainerKey = GlobalKey();
  final List<MapWaypoint> _waypoints = [];
  bool _showScan = true;
  bool _drawMode = true;
  bool _isTap = false;

  // --- Teleop state -------------------------------------------------------
  double _rightJoyX = 0.0;
  double _rightJoyY = 0.0;
  double _leftJoyX = 0.0;
  double _leftJoyY = 0.0;
  double _leftJoyZ = 0.0;
  double _rightJoyZ = 0.0;
  /// Switch states (S1–S5, index 0–4). False = up (default).
  final List<bool> _switchStates = [false, false, false, false, false];
  /// Button states (BGREEN–BBLUE, index 0–4). True = released (active-low).
  final List<bool> _buttonStates = [true, true, true, true, true];

  Timer? _teleopTimer;

  @override
  void initState() {
    super.initState();
    // Publish teleop at 10 Hz so cmd_vel_mux doesn't time out while held.
    _teleopTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!mounted) return;
      _sendRemote();
    });
  }

  @override
  void dispose() {
    _teleopTimer?.cancel();
    _transformCtrl.dispose();
    super.dispose();
  }

  // -- coordinate transforms ------------------------------------------------

  Offset _worldToCanvas(MapWaypoint wp, OccupancyGridData map, double cellSize,
      int cropMinX, int cropMinY, int cropH) {
    final mx = (wp.x - map.originX) / map.resolution - cropMinX;
    final my = (wp.y - map.originY) / map.resolution - cropMinY;
    return Offset(mx * cellSize, (cropH - 1 - my) * cellSize);
  }

  MapWaypoint? _canvasToWorld(Offset canvasPoint, OccupancyGridData map,
      double cellSize, int cropMinX, int cropMinY, int cropW, int cropH) {
    final mx = canvasPoint.dx / cellSize + cropMinX;
    final my = cropMinY + cropH - canvasPoint.dy / cellSize;
    final cellX = mx.floor();
    final cellY = my.floor();

    if (cellX < 0 || cellX >= map.width || cellY < 0 || cellY >= map.height) {
      return null;
    }
    // Allow drawing on free and unknown cells, block only obstacles
    if (map.valueAt(cellX, cellY) > 50) return null;

    final wx = map.originX + mx * map.resolution;
    final wy = map.originY + my * map.resolution;
    return MapWaypoint(x: wx, y: wy);
  }

  /// Get the bounding box of non-unknown cells (explored area) with margin.
  (int, int, int, int) _getCropBounds(OccupancyGridData map) {
    int minX = map.width, minY = map.height, maxX = 0, maxY = 0;
    for (var y = 0; y < map.height; y++) {
      for (var x = 0; x < map.width; x++) {
        if (map.valueAt(x, y) >= 0) {
          if (x < minX) minX = x;
          if (x > maxX) maxX = x;
          if (y < minY) minY = y;
          if (y > maxY) maxY = y;
        }
      }
    }
    if (maxX < minX) return (0, 0, map.width, map.height);
    return (minX, minY, maxX + 1, maxY + 1);
  }

  /// Handle freehand drawing via pan gesture.
  void _handleDraw(Offset globalPos, OccupancyGridData map, double cellSize,
      int cropMinX, int cropMinY, int cropW, int cropH) {
    final box =
        _mapContainerKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final localInWidget = box.globalToLocal(globalPos);
    // In draw mode, Listener sits directly on the map (no InteractiveViewer),
    // so localInWidget IS the canvas point.
    final canvasPoint = _drawMode
        ? localInWidget
        : MatrixUtils.transformPoint(
            Matrix4.inverted(_transformCtrl.value), localInWidget);

    final wp = _canvasToWorld(canvasPoint, map, cellSize, cropMinX, cropMinY,
        cropW, cropH);
    if (wp == null) return;

    if (_waypoints.isNotEmpty && !_isTap) {
      final prev = _waypoints.last;
      final dist = math.sqrt(
          math.pow(wp.x - prev.x, 2) + math.pow(wp.y - prev.y, 2));
      if (dist < _minPointSpacingMeters) return;

      // Interpolate intermediate points for smooth lines
      final steps = (dist / _minPointSpacingMeters).ceil();
      if (steps > 1) {
        final newPoints = <MapWaypoint>[];
        for (var i = 1; i < steps; i++) {
          final t = i / steps;
          newPoints.add(MapWaypoint(
            x: prev.x + (wp.x - prev.x) * t,
            y: prev.y + (wp.y - prev.y) * t,
          ));
        }
        newPoints.add(wp);
        setState(() => _waypoints.addAll(newPoints));
        return;
      }
    }
    _isTap = false;

    setState(() => _waypoints.add(wp));
  }

  void _clearPath() => setState(_waypoints.clear);

  void _undoLastPoint() {
    if (_waypoints.isEmpty) return;
    setState(() => _waypoints.removeLast());
  }

  void _publishPath() {
    if (_waypoints.isEmpty) return;

    final health = ref.read(autonomyHealthProvider).value ?? '';
    if (health == 'manual_mode' || health.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Autonomy is in manual mode. Enable it first!'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
    }

    final client = ref.read(rosBridgeClientProvider);
    final now = DateTime.now();
    final stamp = {
      'sec': now.millisecondsSinceEpoch ~/ 1000,
      'nanosec': (now.microsecondsSinceEpoch % 1000000) * 1000,
    };
    final poses = _waypoints
        .map((wp) => {
              'header': {'frame_id': 'map', 'stamp': stamp},
              'pose': {
                'position': {'x': wp.x, 'y': wp.y, 'z': 0.0},
                'orientation': {'x': 0.0, 'y': 0.0, 'z': 0.0, 'w': 1.0},
              },
            })
        .toList();
    client.publish('/autonomy/user_path', {
      'header': {'frame_id': 'map', 'stamp': stamp},
      'poses': poses,
    }, type: 'nav_msgs/msg/Path');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Published ${_waypoints.length} waypoints'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleAutonomy(bool enable) {
    final client = ref.read(rosBridgeClientProvider);
    client.publish(
        '/autonomy/enabled', {'data': enable}, type: 'std_msgs/msg/Bool');
  }

  // -- teleop helpers --------------------------------------------------------

  void _publishArmVel(double x, double y, double z) {
    final client = ref.read(rosBridgeClientProvider);
    client.publish(
      '/mk2_arm_vel',
      {'x': x * 0.3, 'y': y * 0.3, 'z': z * 0.3},
      type: 'geometry_msgs/msg/Vector3',
    );
  }

  /// Publish a full /remote message.  toggleSwitch flips switch state;
  /// pulseButton sends active-low then releases after 150 ms.
  /// Joystick axes are included every call so the scaler receives drive/arm
  /// commands on the same topic as the physical remote controller ([-1, 1]).
  void _sendRemote({int? toggleSwitch, int? pulseButton}) {
    if (toggleSwitch != null) {
      _switchStates[toggleSwitch] = !_switchStates[toggleSwitch];
    }
    final buttons = List<bool>.from(_switchStates)..addAll(_buttonStates);
    if (pulseButton != null) {
      buttons[5 + pulseButton] = false; // active-low: false = pressed
    }
    final client = ref.read(rosBridgeClientProvider);
    client.publish(
      '/remote',
      {
        'left': {'x': _leftJoyX, 'y': _leftJoyY, 'z': _leftJoyZ},
        'right': {'x': _rightJoyX, 'y': _rightJoyY, 'z': _rightJoyZ},
        'buttons': buttons,
      },
      type: 'reseq_interfaces/msg/Remote',
    );
    if (pulseButton != null) {
      Future.delayed(const Duration(milliseconds: 150), () {
        if (!mounted) return;
        final rel = List<bool>.from(_switchStates)..addAll(_buttonStates);
        ref.read(rosBridgeClientProvider).publish(
          '/remote',
          {
            'left': {'x': 0.0, 'y': 0.0, 'z': 0.0},
            'right': {'x': 0.0, 'y': 0.0, 'z': 0.0},
            'buttons': rel,
          },
          type: 'reseq_interfaces/msg/Remote',
        );
      });
    }
  }

  // -- build -----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final mapAsync = ref.watch(mapProvider);
    final mapScanPoints = ref.watch(mapFrameScanProvider);
    final poseAsync = ref.watch(robotPoseProvider);
    final robotSegments = ref.watch(robotSegmentsProvider).value ?? [];
    final statusAsync = ref.watch(autonomyStatusProvider);
    final healthAsync = ref.watch(autonomyHealthProvider);
    final cmdSrcAsync = ref.watch(autonomyCmdSourceProvider);
    final colorScheme = Theme.of(context).colorScheme;

    const switchLabels = [
      (0, 'S1 – Beak Open/Close'),
      (1, 'S2'),
      (2, 'S3'),
      (3, 'S4'),
      (4, 'S5 – Pivot on Head'),
    ];
    const buttonLabels = [
      (0, 'BGREEN – Arm Vel Type'),
      (1, 'BBLACK'),
      (2, 'BRED'),
      (3, 'BWHITE'),
      (4, 'BBLUE – Agevar/Pivot'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Control Panel'),
        actions: [AppbarActions()],
      ),
      body: Row(
        children: [
          // ── Centre: map + toolbar (with joystick overlays) ────────────
          Expanded(
            child: Container(
              color: colorScheme.surfaceContainerLowest,
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      FilledButton.icon(
                        onPressed: _publishPath,
                        icon: const Icon(Icons.send_rounded, size: 18),
                        label: Text('Send (${_waypoints.length})'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _undoLastPoint,
                        icon: const Icon(Icons.undo_rounded, size: 18),
                        label: const Text('Undo'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _clearPath,
                        icon: const Icon(Icons.delete_outline_rounded, size: 18),
                        label: const Text('Clear'),
                      ),
                      FilterChip(
                        label: const Text('Scan'),
                        selected: _showScan,
                        onSelected: (v) => setState(() => _showScan = v),
                      ),
                      FilterChip(
                        label: Text(_drawMode ? 'Draw' : 'Pan'),
                        selected: _drawMode,
                        onSelected: (v) => setState(() => _drawMode = v),
                        avatar: Icon(
                          _drawMode ? Icons.edit : Icons.pan_tool,
                          size: 16,
                        ),
                      ),
                      // ── Switches popup ──────────────────────────────
                      PopupMenuButton<int>(
                        tooltip: 'Switches',
                        child: const Chip(
                          avatar: Icon(Icons.toggle_on_rounded, size: 16),
                          label: Text('Switches'),
                        ),
                        onSelected: (idx) => setState(() => _sendRemote(toggleSwitch: idx)),
                        itemBuilder: (_) => [
                          for (final e in switchLabels)
                            PopupMenuItem<int>(
                              value: e.$1,
                              child: Row(
                                children: [
                                  Icon(
                                    _switchStates[e.$1] ? Icons.toggle_on : Icons.toggle_off,
                                    size: 18,
                                    color: _switchStates[e.$1] ? Colors.green : Colors.grey,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(e.$2),
                                ],
                              ),
                            ),
                        ],
                      ),
                      // ── Buttons popup ───────────────────────────────
                      PopupMenuButton<int>(
                        tooltip: 'Buttons',
                        child: const Chip(
                          avatar: Icon(Icons.radio_button_checked_rounded, size: 16),
                          label: Text('Buttons'),
                        ),
                        onSelected: (idx) => _sendRemote(pulseButton: idx),
                        itemBuilder: (_) => [
                          for (final e in buttonLabels)
                            PopupMenuItem<int>(value: e.$1, child: Text(e.$2)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Stack(
                      children: [
                        // ── Map ──────────────────────────────────────────
                        Positioned.fill(
                          child: mapAsync.when(
                      loading: () => const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 12),
                            Text('Waiting for /map ...'),
                          ],
                        ),
                      ),
                      error: (err, _) => Center(child: Text('Map error: $err')),
                      data: (map) {
                        final crop = _getCropBounds(map);
                        final cropMinX = crop.$1;
                        final cropMinY = crop.$2;
                        final cropW = crop.$3 - crop.$1;
                        final cropH = crop.$4 - crop.$2;

                        return LayoutBuilder(
                          builder: (context, constraints) {
                            final availW = constraints.maxWidth;
                            final availH = constraints.maxHeight;
                            final cellSize = math.min(
                                availW / cropW, availH / cropH);
                            final canvasW = cropW * cellSize;
                            final canvasH = cropH * cellSize;

                            final scanPoints =
                                _showScan ? mapScanPoints : <LaserPoint>[];
                            final robotPose = poseAsync.value;

                            final mapWidget = CustomPaint(
                              size: Size(canvasW, canvasH),
                              painter: _MapPainter(
                                map: map,
                                cellSize: cellSize,
                                cropMinX: cropMinX,
                                cropMinY: cropMinY,
                                cropW: cropW,
                                cropH: cropH,
                                waypoints: _waypoints,
                                scanPoints: scanPoints,
                                robotPose: robotPose,
                                robotSegments: robotSegments,
                                worldToCanvas: (wp) => _worldToCanvas(
                                    wp, map, cellSize, cropMinX, cropMinY, cropH),
                              ),
                            );

                            return Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  key: _mapContainerKey,
                                  width: canvasW,
                                  height: canvasH,
                                color: const Color(0xFF1A2332),
                                  child: _drawMode
                                      ? Listener(
                                          onPointerDown: (e) {
                                            if (e.buttons != 1) return;
                                            _isTap = true;
                                            _handleDraw(
                                              e.position,
                                              map,
                                              cellSize,
                                              cropMinX,
                                              cropMinY,
                                              cropW,
                                              cropH);
                                          },
                                          onPointerMove: (e) {
                                            if (e.buttons != 1) return;
                                            _handleDraw(
                                              e.position,
                                              map,
                                              cellSize,
                                              cropMinX,
                                              cropMinY,
                                              cropW,
                                              cropH);
                                          },
                                          child: mapWidget,
                                        )
                                      : Listener(
                                          onPointerSignal: (event) {
                                            if (event is PointerScrollEvent) {
                                              setState(() {
                                                final scaleFactor =
                                                    event.scrollDelta.dy > 0
                                                        ? 0.9
                                                        : 1.1;
                                                final m = _transformCtrl
                                                    .value
                                                    .clone();
                                                final focal =
                                                    event.localPosition;
                                                m.translate(
                                                    focal.dx, focal.dy);
                                                m.scale(scaleFactor,
                                                    scaleFactor);
                                                m.translate(
                                                    -focal.dx, -focal.dy);
                                                _transformCtrl.value = m;
                                              });
                                            }
                                          },
                                          child: GestureDetector(
                                            onPanUpdate: (details) {
                                              setState(() {
                                                final m = _transformCtrl
                                                    .value
                                                    .clone();
                                                m.translate(
                                                    details.delta.dx /
                                                        m.getMaxScaleOnAxis(),
                                                    details.delta.dy /
                                                        m.getMaxScaleOnAxis());
                                                _transformCtrl.value = m;
                                              });
                                            },
                                            child: ClipRect(
                                              child: AnimatedBuilder(
                                                animation: _transformCtrl,
                                                builder: (context, child) =>
                                                    Transform(
                                                  transform:
                                                      _transformCtrl.value,
                                                  child: child,
                                                ),
                                                child: mapWidget,
                                              ),
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                        // ── Arm joystick + Z slider (bottom-left) ────────
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _AxisSlider(
                                  label: 'Arm Z',
                                  trackWidth: 130.0,
                                  onChanged: (v) {
                                    setState(() => _leftJoyZ = v);
                                    _publishArmVel(_leftJoyX, _leftJoyY, v);
                                  },
                                ),
                                const SizedBox(height: 6),
                                _JoystickPad(
                                  label: 'Arm XY',
                                  size: 130.0,
                                  onMove: (dx, dy) {
                                    _leftJoyX = dx;
                                    _leftJoyY = dy;
                                    _publishArmVel(dx, dy, _leftJoyZ);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        // ── Drive joystick + Pitch slider (bottom-right) ─────
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _AxisSlider(
                                  label: 'Pitch',
                                  trackWidth: 130.0,
                                  onChanged: (v) => setState(() => _rightJoyZ = v),
                                ),
                                const SizedBox(height: 6),
                                _JoystickPad(
                                  label: 'Drive',
                                  size: 130.0,
                                  onMove: (dx, dy) {
                                    setState(() {
                                      _rightJoyX = dx;
                                      _rightJoyY = dy;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 280,
            child: Container(
              color: colorScheme.surface,
              padding: const EdgeInsets.all(10),
              child: ListView(
                children: [
                  // ── Autonomy ────────────────────────────────────────────
                  Text('Autonomy',
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed: () => _toggleAutonomy(true),
                          icon: const Icon(Icons.play_arrow_rounded, size: 16),
                          label: const Text('Enable'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _toggleAutonomy(false),
                          icon: const Icon(Icons.stop_rounded, size: 16),
                          label: const Text('Disable'),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  // ── Status ─────────────────────────────────────────────
                  _StatusCard(title: 'Status', value: statusAsync.value ?? '\u2014'),
                  _StatusCard(title: 'Health', value: healthAsync.value ?? '\u2014'),
                  _StatusCard(title: 'Cmd Source', value: cmdSrcAsync.value ?? '\u2014'),
                  const SizedBox(height: 8),
                  mapAsync.whenOrNull(
                        data: (map) => _StatusCard(
                          title: 'Map',
                          value:
                              '${map.width}\u00D7${map.height} @ ${map.resolution.toStringAsFixed(3)} m',
                        ),
                      ) ??
                      const SizedBox.shrink(),
                  _StatusCard(
                    title: 'Waypoints',
                    value: _waypoints.isEmpty
                        ? 'None'
                        : _waypoints
                            .map((wp) =>
                                '(${wp.x.toStringAsFixed(2)}, ${wp.y.toStringAsFixed(2)})')
                            .join('\n'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -- painter -----------------------------------------------------------------

class _MapPainter extends CustomPainter {
  final OccupancyGridData map;
  final double cellSize;
  final int cropMinX, cropMinY, cropW, cropH;
  final List<MapWaypoint> waypoints;
  final List<LaserPoint> scanPoints;
  final RobotPose? robotPose;
  final List<SegmentPose> robotSegments;
  final Offset Function(MapWaypoint) worldToCanvas;

  const _MapPainter({
    required this.map,
    required this.cellSize,
    required this.cropMinX,
    required this.cropMinY,
    required this.cropW,
    required this.cropH,
    required this.waypoints,
    required this.scanPoints,
    required this.robotPose,
    required this.robotSegments,
    required this.worldToCanvas,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final freePaint = Paint()..color = const Color(0xFFFFFFFF);
    final unknownPaint = Paint()..color = const Color(0xFFC8C8C8);
    final occupiedPaint = Paint()..color = const Color(0xFF000000);
    final gridPaint = Paint()
      ..color = const Color(0xFFD0D0D0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    final pathPaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    final waypointPaint = Paint()..color = const Color(0xFF8B5CF6);
    final scanPaint = Paint()..color = const Color(0xFFFF0000);

    // Draw cropped occupancy grid
    for (var cy = 0; cy < cropH; cy++) {
      for (var cx = 0; cx < cropW; cx++) {
        final mapX = cx + cropMinX;
        final mapY = cy + cropMinY;
        if (mapX >= map.width || mapY >= map.height) continue;
        final value = map.valueAt(mapX, mapY);
        // Flip Y: ROS y=0 at bottom, canvas y=0 at top
        final canvasY = (cropH - 1 - cy) * cellSize;
        final rect = Rect.fromLTWH(cx * cellSize, canvasY, cellSize, cellSize);
        canvas.drawRect(
          rect,
          value < 0 ? unknownPaint : value > 50 ? occupiedPaint : freePaint,
        );
        // Draw grid border on free/occupied cells only
        if (value >= 0 && cellSize > 3) {
          canvas.drawRect(rect, gridPaint);
        }
      }
    }

    // Laser scan
    for (final pt in scanPoints) {
      final canvasPt = worldToCanvas(MapWaypoint(x: pt.x, y: pt.y));
      if (canvasPt.dx >= 0 &&
          canvasPt.dx < size.width &&
          canvasPt.dy >= 0 &&
          canvasPt.dy < size.height) {
        canvas.drawCircle(canvasPt, 2.0, scanPaint);
      }
    }

    // Robot body segments
    if (robotSegments.isNotEmpty) {
      const moduleLength = 0.2059;
      const moduleWidth = 0.2046;
      const trackWidth = 0.051;
      const jointDiam = 0.0709;
      final segFill = Paint()..color = const Color(0xFF4ADE80).withOpacity(0.4);
      final segOutline = Paint()
        ..color = const Color(0xFF16A34A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      final trackFill =
          Paint()..color = const Color(0xFF1F2937).withOpacity(0.7);
      final jointFill =
          Paint()..color = const Color(0xFF9CA3AF).withOpacity(0.6);
      final jointOutline = Paint()
        ..color = const Color(0xFF6B7280)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      final metersToPx = cellSize / map.resolution;
      final rectW = moduleLength * metersToPx;
      final trackW = moduleLength * metersToPx;
      final trackH = trackWidth * metersToPx;
      final jointR = (jointDiam / 2) * metersToPx;

      for (var i = 0; i < robotSegments.length; i++) {
        final seg = robotSegments[i];
        final center = worldToCanvas(MapWaypoint(x: seg.x, y: seg.y));
        canvas.save();
        canvas.translate(center.dx, center.dy);
        canvas.rotate(-seg.yaw);

        final trackOffsetY = (moduleWidth / 2 - trackWidth / 2) * metersToPx;
        canvas.drawRect(
          Rect.fromCenter(
              center: Offset(0, -trackOffsetY),
              width: trackW,
              height: trackH),
          trackFill,
        );
        canvas.drawRect(
          Rect.fromCenter(
              center: Offset(0, trackOffsetY),
              width: trackW,
              height: trackH),
          trackFill,
        );

        final bodyH = (moduleWidth - 2 * trackWidth - 0.002) * metersToPx;
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: rectW, height: bodyH),
          segFill,
        );
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: rectW, height: bodyH),
          segOutline,
        );
        canvas.restore();

        if (i < robotSegments.length - 1) {
          final next = robotSegments[i + 1];
          final p1 = worldToCanvas(MapWaypoint(x: seg.x, y: seg.y));
          final p2 = worldToCanvas(MapWaypoint(x: next.x, y: next.y));
          final jx = (p1.dx + p2.dx) / 2;
          final jy = (p1.dy + p2.dy) / 2;
          canvas.drawLine(p1, p2, jointOutline);
          canvas.drawCircle(Offset(jx, jy), jointR, jointFill);
          canvas.drawCircle(Offset(jx, jy), jointR, jointOutline);
        }
      }

    }

    // Path
    if (waypoints.isNotEmpty) {
      final path = Path();
      final first = worldToCanvas(waypoints.first);
      path.moveTo(first.dx, first.dy);
      for (final wp in waypoints.skip(1)) {
        final pt = worldToCanvas(wp);
        path.lineTo(pt.dx, pt.dy);
      }
      canvas.drawPath(path, pathPaint);
    }

    // Waypoint dots
    for (final wp in waypoints) {
      final pt = worldToCanvas(wp);
      canvas.drawCircle(pt, math.max(3.0, cellSize * 0.4), waypointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MapPainter old) => true;
}

// -- widgets -----------------------------------------------------------------

// ── Virtual joystick ────────────────────────────────────────────────────────

class _JoystickPad extends StatefulWidget {
  final String label;
  final void Function(double dx, double dy) onMove;
  final double size;

  const _JoystickPad({
    required this.label,
    required this.onMove,
    this.size = 120.0,
  });

  @override
  State<_JoystickPad> createState() => _JoystickPadState();
}

class _JoystickPadState extends State<_JoystickPad> {
  double _dx = 0.0;
  double _dy = 0.0;

  void _update(Offset local) {
    final half = widget.size / 2;
    double nx = (local.dx - half) / half;
    double ny = -((local.dy - half) / half); // up = positive
    // Square: clamp each axis independently so full ±1 is reachable on both axes
    nx = nx.clamp(-1.0, 1.0);
    ny = ny.clamp(-1.0, 1.0);
    setState(() {
      _dx = nx;
      _dy = ny;
    });
    widget.onMove(_dx, _dy);
  }

  void _reset() {
    setState(() {
      _dx = 0.0;
      _dy = 0.0;
    });
    widget.onMove(0.0, 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(widget.label,
            style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 4),
        GestureDetector(
          onPanStart: (d) => _update(d.localPosition),
          onPanUpdate: (d) => _update(d.localPosition),
          onPanEnd: (_) => _reset(),
          onPanCancel: _reset,
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _JoystickPainter(dx: _dx, dy: _dy),
          ),
        ),
      ],
    );
  }
}

class _JoystickPainter extends CustomPainter {
  final double dx;
  final double dy;

  const _JoystickPainter({required this.dx, required this.dy});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final thumbR = cx * 0.28;
    final maxOff = cx - thumbR - 2;

    // Square background
    final bgRect = Rect.fromLTRB(2, 2, size.width - 2, size.height - 2);
    canvas.drawRect(
      bgRect,
      Paint()..color = const Color(0xFFE0E0E0),
    );
    canvas.drawRect(
      bgRect,
      Paint()
        ..color = const Color(0xFF9E9E9E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    // Crosshairs
    final cross = Paint()
      ..color = const Color(0xFFBDBDBD)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(cx, 4), Offset(cx, size.height - 4), cross);
    canvas.drawLine(Offset(4, cy), Offset(size.width - 4, cy), cross);

    // Thumb
    final tx = cx + dx * maxOff;
    final ty = cy - dy * maxOff; // dy positive = up
    canvas.drawCircle(
      Offset(tx, ty),
      thumbR,
      Paint()..color = const Color(0xFF1E88E5),
    );
    canvas.drawCircle(
      Offset(tx, ty),
      thumbR,
      Paint()
        ..color = const Color(0xFF1565C0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant _JoystickPainter old) =>
      old.dx != dx || old.dy != dy;
}

// ── Vertical single-axis slider (for arm Z control) ─────────────────────────

class _AxisSlider extends StatefulWidget {
  final String label;
  final double trackWidth;
  final void Function(double v) onChanged;

  const _AxisSlider({
    required this.label,
    required this.onChanged,
    this.trackWidth = 130.0,
  });

  @override
  State<_AxisSlider> createState() => _AxisSliderState();
}

class _AxisSliderState extends State<_AxisSlider> {
  double _value = 0.0;
  static const double _trackHeight = 70.0;

  void _update(Offset local) {
    final v = (1.0 - 2.0 * local.dy / _trackHeight).clamp(-1.0, 1.0);
    setState(() => _value = v);
    widget.onChanged(_value);
  }

  void _reset() {
    setState(() => _value = 0.0);
    widget.onChanged(0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(widget.label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 4),
        GestureDetector(
          onPanStart: (d) => _update(d.localPosition),
          onPanUpdate: (d) => _update(d.localPosition),
          onPanEnd: (_) => _reset(),
          onPanCancel: _reset,
          child: CustomPaint(
            size: Size(widget.trackWidth, _trackHeight),
            painter: _AxisSliderPainter(value: _value),
          ),
        ),
      ],
    );
  }
}

class _AxisSliderPainter extends CustomPainter {
  final double value;
  const _AxisSliderPainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    const trackHalfW = 12.0;
    const thumbR = 10.0;

    // Background track
    final bgRect = Rect.fromLTRB(cx - trackHalfW, 2, cx + trackHalfW, size.height - 2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, const Radius.circular(6)),
      Paint()..color = const Color(0xFFE0E0E0),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, const Radius.circular(6)),
      Paint()
        ..color = const Color(0xFF9E9E9E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Center tick
    canvas.drawLine(
      Offset(cx - trackHalfW, cy),
      Offset(cx + trackHalfW, cy),
      Paint()
        ..color = const Color(0xFFBDBDBD)
        ..strokeWidth = 1.0,
    );

    // Fill bar from center toward thumb
    final thumbY = cy - value * (cy - thumbR - 2);
    if (value.abs() > 0.01) {
      final fillTop = value > 0 ? thumbY : cy;
      final fillBot = value > 0 ? cy : thumbY;
      canvas.drawRect(
        Rect.fromLTRB(cx - trackHalfW + 2, fillTop, cx + trackHalfW - 2, fillBot),
        Paint()..color = const Color(0xFF1E88E5).withOpacity(0.35),
      );
    }

    // Thumb
    canvas.drawCircle(Offset(cx, thumbY), thumbR, Paint()..color = const Color(0xFF1E88E5));
    canvas.drawCircle(
      Offset(cx, thumbY),
      thumbR,
      Paint()
        ..color = const Color(0xFF1565C0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant _AxisSliderPainter old) => old.value != value;
}

// ── Status card ─────────────────────────────────────────────────────────────

class _StatusCard extends StatelessWidget {
  final String title;
  final String value;
  const _StatusCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 2),
            Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
