import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/data/ros_bridgeclient_provider/ros_bridgeclient_provider.dart';

/// Decoded occupancy grid from `/map`.
class OccupancyGridData {
  final int width;
  final int height;
  final double resolution;
  final double originX;
  final double originY;
  final List<int> data;

  const OccupancyGridData({
    required this.width,
    required this.height,
    required this.resolution,
    required this.originX,
    required this.originY,
    required this.data,
  });

  int valueAt(int x, int y) => data[y * width + x];
  bool isFree(int x, int y) => valueAt(x, y) == 0;

  factory OccupancyGridData.fromRosMessage(Map<String, dynamic> msg) {
    final info = msg['info'] as Map<String, dynamic>;
    final origin = info['origin']['position'] as Map<String, dynamic>;
    final rawData = msg['data'] as List<dynamic>;
    return OccupancyGridData(
      width: (info['width'] as num).toInt(),
      height: (info['height'] as num).toInt(),
      resolution: (info['resolution'] as num).toDouble(),
      originX: (origin['x'] as num).toDouble(),
      originY: (origin['y'] as num).toDouble(),
      data: rawData.map((e) => (e as num).toInt()).toList(),
    );
  }
}

/// A single 2D point from a laser scan in the map frame.
class LaserPoint {
  final double x;
  final double y;
  const LaserPoint(this.x, this.y);
}

/// Decoded laser scan data.
class LaserScanData {
  final String frameId;
  final double angleMin;
  final double angleMax;
  final double angleIncrement;
  final List<double> ranges;
  final double rangeMin;
  final double rangeMax;

  const LaserScanData({
    required this.frameId,
    required this.angleMin,
    required this.angleMax,
    required this.angleIncrement,
    required this.ranges,
    required this.rangeMin,
    required this.rangeMax,
  });

  /// Convert ranges to XY points in the sensor frame.
  List<LaserPoint> toPoints() {
    final points = <LaserPoint>[];
    for (var i = 0; i < ranges.length; i++) {
      final r = ranges[i];
      if (r < rangeMin || r > rangeMax || r.isNaN || r.isInfinite) continue;
      final angle = angleMin + i * angleIncrement;
      points.add(LaserPoint(r * math.cos(angle), r * math.sin(angle)));
    }
    return points;
  }

  factory LaserScanData.fromRosMessage(Map<String, dynamic> msg) {
    final header = msg['header'] as Map<String, dynamic>?;
    return LaserScanData(
      frameId: (header?['frame_id'] as String?) ?? 'laser_frame',
      angleMin: (msg['angle_min'] as num).toDouble(),
      angleMax: (msg['angle_max'] as num).toDouble(),
      angleIncrement: (msg['angle_increment'] as num).toDouble(),
      rangeMin: (msg['range_min'] as num).toDouble(),
      rangeMax: (msg['range_max'] as num).toDouble(),
      ranges: (msg['ranges'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
    );
  }
}

/// Streams the latest occupancy grid from `/map`.
final mapProvider = StreamProvider<OccupancyGridData>((ref) {
  final client = ref.watch(rosBridgeClientProvider);
  return client.subscribe('/map').map(OccupancyGridData.fromRosMessage);
});

/// Streams the latest laser scan from `/scan`.
final laserScanProvider = StreamProvider<LaserScanData>((ref) {
  final client = ref.watch(rosBridgeClientProvider);
  return client.subscribe('/scan').map(LaserScanData.fromRosMessage);
});

/// Scan points transformed to map frame.
/// Prefer laser_frame_stabilized (fixed on base_link) when available.
final mapFrameScanProvider = Provider<List<LaserPoint>>((ref) {
  final scan = ref.watch(laserScanProvider).value;
  if (scan == null) return [];

  // Primary path: scan already published from laser_frame_stabilized.
  if (scan.frameId == 'laser_frame_stabilized') {
    final basePose = ref.watch(robotPoseProvider).value;
    if (basePose == null) return [];

    // Matches lidar.xacro: laser_frame_stabilized fixed on base_link.
    const laserOffsetX = -0.490;
    const laserOffsetY = 0.0;
    final cosYaw = math.cos(basePose.yaw);
    final sinYaw = math.sin(basePose.yaw);
    final laserX = basePose.x + laserOffsetX * cosYaw - laserOffsetY * sinYaw;
    final laserY = basePose.y + laserOffsetX * sinYaw + laserOffsetY * cosYaw;

    final pts = <LaserPoint>[];
    for (final pt in scan.toPoints()) {
      pts.add(LaserPoint(
        laserX + pt.x * cosYaw - pt.y * sinYaw,
        laserY + pt.x * sinYaw + pt.y * cosYaw,
      ));
    }
    return pts;
  }

  // Fallback for older scans that still use laser_frame mounted on chassis2_link.
  final segments = ref.watch(robotSegmentsProvider).value;
  if (segments == null || segments.length < 2) return [];
  final chassis2 = segments[1];
  const laserLocalX = -0.07;
  final cosYaw = math.cos(chassis2.yaw);
  final sinYaw = math.sin(chassis2.yaw);
  final laserX = chassis2.x + laserLocalX * cosYaw;
  final laserY = chassis2.y + laserLocalX * sinYaw;
  final pts = <LaserPoint>[];
  for (final pt in scan.toPoints()) {
    pts.add(LaserPoint(
      laserX + pt.x * cosYaw - pt.y * sinYaw,
      laserY + pt.x * sinYaw + pt.y * cosYaw,
    ));
  }
  return pts;
});

/// Robot pose in the map frame (x, y, yaw).
class RobotPose {
  final double x;
  final double y;
  final double yaw;
  const RobotPose({required this.x, required this.y, required this.yaw});
}

/// Accumulates map→odom and odom→base_link transforms to produce map→base_link.
final robotPoseProvider = StreamProvider<RobotPose>((ref) {
  final client = ref.watch(rosBridgeClientProvider);

  // Latest known transforms
  double moX = 0, moY = 0, moYaw = 0; // map→odom
  double obX = 0, obY = 0, obYaw = 0; // odom→base_link
  bool hasMapOdom = false, hasOdomBase = false;

  return client.subscribe('/tf').map((msg) {
    final transforms = msg['transforms'] as List<dynamic>;
    for (final t in transforms) {
      final parentFrame = (t['header'] as Map<String, dynamic>)['frame_id'] as String;
      final childFrame = t['child_frame_id'] as String;
      final trans = t['transform']['translation'] as Map<String, dynamic>;
      final rot = t['transform']['rotation'] as Map<String, dynamic>;
      final tx = (trans['x'] as num).toDouble();
      final ty = (trans['y'] as num).toDouble();
      final qz = (rot['z'] as num).toDouble();
      final qw = (rot['w'] as num).toDouble();
      final yaw = 2.0 * math.atan2(qz, qw);

      if (parentFrame == 'map' && childFrame == 'odom') {
        moX = tx; moY = ty; moYaw = yaw;
        hasMapOdom = true;
      } else if (parentFrame == 'odom' && childFrame == 'base_link') {
        obX = tx; obY = ty; obYaw = yaw;
        hasOdomBase = true;
      }
    }
    if (!hasMapOdom || !hasOdomBase) {
      throw Exception('Waiting for map→odom and odom→base_link transforms');
    }
    // Compose: map→base_link = map→odom * odom→base_link
    final cosM = math.cos(moYaw);
    final sinM = math.sin(moYaw);
    return RobotPose(
      x: moX + cosM * obX - sinM * obY,
      y: moY + sinM * obX + cosM * obY,
      yaw: moYaw + obYaw,
    );
  }).handleError((_) {});
});

/// Robot body segment poses in the map frame.
/// Each segment is represented by (x, y, yaw) of its center.
class SegmentPose {
  final double x, y, yaw;
  const SegmentPose(this.x, this.y, this.yaw);
}

/// Provides poses for all 4 chassis segments from TF data.
/// Accumulates map→odom, odom→base_link, and the static/dynamic chain
/// to each chassis link.
final robotSegmentsProvider = StreamProvider<List<SegmentPose>>((ref) {
  final client = ref.watch(rosBridgeClientProvider);

  // map→odom transform
  double moX = 0, moY = 0, moYaw = 0;
  bool hasMapOdom = false;

  // odom→base_link transform
  double obX = 0, obY = 0, obYaw = 0;
  bool hasOdomBase = false;

  // base_link→chassis1_link is static (Z offset only, no XY or yaw change in 2D)
  // chassis1→joint_r_2→joint_y_2→joint_p_2→chassis2, etc.
  // We track the cumulative transform from base_link to each chassis.
  // Store all TF transforms we receive and compose chains.
  final transforms = <String, _TF3D>{};

  // Subscribe to /tf_static for static transforms (chassis joints, etc.)
  final staticSub = client.subscribe('/tf_static').listen((msg) {
    final tfList = msg['transforms'] as List<dynamic>;
    for (final t in tfList) {
      final parent = (t['header'] as Map<String, dynamic>)['frame_id'] as String;
      final child = t['child_frame_id'] as String;
      final trans = t['transform']['translation'] as Map<String, dynamic>;
      final rot = t['transform']['rotation'] as Map<String, dynamic>;
      final tx = (trans['x'] as num).toDouble();
      final ty = (trans['y'] as num).toDouble();
      final qx = (rot['x'] as num).toDouble();
      final qy = (rot['y'] as num).toDouble();
      final qz = (rot['z'] as num).toDouble();
      final qw = (rot['w'] as num).toDouble();
      transforms['$parent->$child'] = _TF3D(tx, ty, qx, qy, qz, qw);
    }
  });

  ref.onDispose(() => staticSub.cancel());

  return client.subscribe('/tf').map((msg) {
    final tfList = msg['transforms'] as List<dynamic>;
    for (final t in tfList) {
      final parent = (t['header'] as Map<String, dynamic>)['frame_id'] as String;
      final child = t['child_frame_id'] as String;
      final trans = t['transform']['translation'] as Map<String, dynamic>;
      final rot = t['transform']['rotation'] as Map<String, dynamic>;
      final tx = (trans['x'] as num).toDouble();
      final ty = (trans['y'] as num).toDouble();
      final qx = (rot['x'] as num).toDouble();
      final qy = (rot['y'] as num).toDouble();
      final qz = (rot['z'] as num).toDouble();
      final qw = (rot['w'] as num).toDouble();

      if (parent == 'map' && child == 'odom') {
        final yaw = 2.0 * math.atan2(qz, qw);
        moX = tx; moY = ty; moYaw = yaw;
        hasMapOdom = true;
      } else if (parent == 'odom' && child == 'base_link') {
        final yaw = 2.0 * math.atan2(qz, qw);
        obX = tx; obY = ty; obYaw = yaw;
        hasOdomBase = true;
      } else {
        transforms['$parent->$child'] = _TF3D(tx, ty, qx, qy, qz, qw);
      }
    }

    if (!hasMapOdom || !hasOdomBase) return <SegmentPose>[];

    // Compose map→base_link
    final cosM = math.cos(moYaw);
    final sinM = math.sin(moYaw);
    final blX = moX + cosM * obX - sinM * obY;
    final blY = moY + sinM * obX + cosM * obY;
    final blYaw = moYaw + obYaw;

    // Build chain for each chassis link using proper 3D quaternion composition
    final halfYaw = blYaw / 2.0;
    final blTf = _TF3D(blX, blY, 0, 0, math.sin(halfYaw), math.cos(halfYaw));
    final segments = <SegmentPose>[];
    // chassis1: base_link→chassis1_link (static, Z only)
    final c1 = transforms['base_link->chassis1_link'];
    final c1tf = c1 != null ? _compose3D(blTf, c1) : blTf;
    segments.add(SegmentPose(c1tf.x, c1tf.y, c1tf.yaw));

    // chassis2..4: chain through joint_r, joint_y, joint_p links
    for (var i = 2; i <= 4; i++) {
      final chain = _chainFromChassis(transforms, blTf, 1, i);
      if (chain != null) {
        segments.add(SegmentPose(chain.x, chain.y, chain.yaw));
      }
    }

    return segments;
  }).handleError((_) {});
});

/// Compose transforms from base_link to target chassis through joint chain
/// using proper 3D quaternion math.
_TF3D? _chainFromChassis(
    Map<String, _TF3D> tfs, _TF3D start, int from, int to) {
  var current = start;

  // base_link→chassis1_link
  final c1 = tfs['base_link->chassis1_link'];
  if (c1 != null) {
    current = _compose3D(current, c1);
  }

  // Chain through each joint set from chassis (from+1) to chassis (to)
  for (var j = from + 1; j <= to; j++) {
    final links = [
      'chassis${j - 1}_link->joint_r_${j}_link',
      'joint_r_${j}_link->joint_y_${j}_link',
      'joint_y_${j}_link->joint_p_${j}_link',
      'joint_p_${j}_link->chassis${j}_link',
    ];
    for (final key in links) {
      final tf = tfs[key];
      if (tf == null) return null;
      current = _compose3D(current, tf);
    }
  }
  return current;
}

/// Compose parent * child using full 3D quaternion math.
/// Position uses yaw from composed parent quaternion (exact for XY-plane translations).
_TF3D _compose3D(_TF3D parent, _TF3D child) {
  final pyaw = parent.yaw;
  final cos = math.cos(pyaw);
  final sin = math.sin(pyaw);
  final nx = parent.x + cos * child.x - sin * child.y;
  final ny = parent.y + sin * child.x + cos * child.y;
  // Quaternion multiplication: parent * child
  final nqw = parent.qw * child.qw - parent.qx * child.qx -
      parent.qy * child.qy - parent.qz * child.qz;
  final nqx = parent.qw * child.qx + parent.qx * child.qw +
      parent.qy * child.qz - parent.qz * child.qy;
  final nqy = parent.qw * child.qy - parent.qx * child.qz +
      parent.qy * child.qw + parent.qz * child.qx;
  final nqz = parent.qw * child.qz + parent.qx * child.qy -
      parent.qy * child.qx + parent.qz * child.qw;
  return _TF3D(nx, ny, nqx, nqy, nqz, nqw);
}

class _TF3D {
  final double x, y;
  final double qx, qy, qz, qw;
  const _TF3D(this.x, this.y, this.qx, this.qy, this.qz, this.qw);
  double get yaw => math.atan2(
      2.0 * (qw * qz + qx * qy), 1.0 - 2.0 * (qy * qy + qz * qz));
}

/// Streams autonomy status from `/autonomy/explorer_status`.
final autonomyStatusProvider = StreamProvider<String>((ref) {
  final client = ref.watch(rosBridgeClientProvider);
  return client.subscribe('/autonomy/explorer_status').map(
    (msg) => msg['data'] as String? ?? '',
  );
});

/// Streams health from `/autonomy/health`.
final autonomyHealthProvider = StreamProvider<String>((ref) {
  final client = ref.watch(rosBridgeClientProvider);
  return client.subscribe('/autonomy/health').map(
    (msg) => msg['data'] as String? ?? '',
  );
});

/// Streams cmd source from `/autonomy/cmd_source`.
final autonomyCmdSourceProvider = StreamProvider<String>((ref) {
  final client = ref.watch(rosBridgeClientProvider);
  return client.subscribe('/autonomy/cmd_source').map(
    (msg) => msg['data'] as String? ?? '',
  );
});
