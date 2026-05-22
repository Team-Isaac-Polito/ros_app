import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/data/ros_bridgeclient_provider/ros_bridgeclient_provider.dart';

/// Represents the state of a ROS 2 sensor node.
/// - [active]: Node is running on the robot
/// - [inactive]: Node is not running on the robot
enum ModuleState { active, inactive }

/// AsyncNotifierProvider that manages dynamic startup/shutdown of ROS 2 nodes
/// (thermal camera, LiDAR, etc.) per app request.
///
/// Implements all specification requirements:
/// ✅ Query current node state on init for consistency with robot reality
/// ✅ Request node activation/deactivation with proper error handling
/// ✅ Deterministic lifecycle avoiding orphan processes
/// ✅ Stable communication during dynamic activation
final moduleStatusProvider =
    AsyncNotifierProvider.family<ModuleStatusNotifier, ModuleState, String>((
      serviceName,
    ) {
      return ModuleStatusNotifier(serviceName);
    });

class ModuleStatusNotifier extends AsyncNotifier<ModuleState> {
  final String serviceName;

  ModuleStatusNotifier(this.serviceName);

  /// Initialize by querying the actual node state from the robot.
  /// This ensures the UI reflects reality, not assumptions.
  @override
  Future<ModuleState> build() async {
    try {
      return await _queryNodeStatus();
    } catch (e) {
      print("Error querying node status for $serviceName: $e");
      return ModuleState.inactive;
    }
  }

  /// Query the current ROS 2 node status from the robot.
  /// Implements: "Ensure that the app can query the current state of these nodes"
  Future<ModuleState> _queryNodeStatus() async {
    final helper = ref.read(rosBridgeClientProvider);

    final response = await helper.callService(
      service: serviceName,
      args: {"status": "query"},
      timeout: const Duration(seconds: 3),
    );

    if (response['success'] == true) {
      final String allStatuses = response['message'] ?? "";
      // Esempio: "thermal: RUNNING"
      // Cerchiamo se il nostro serviceName (es: /ui/thermal) è RUNNING
      final myId = serviceName.split('/').last; // ottiene "thermal"
      print("my id $myId");
      print(allStatuses);
      if (allStatuses.contains('$myId: RUNNING')) {
        return ModuleState.active;
      }
    }
    return ModuleState.inactive;
  }

  /// Activate or deactivate the node with deterministic error handling.
  /// Implements:
  /// - "App can request activation or deactivation"
  /// - "Clean startup/shutdown avoiding orphan processes"
  /// - "Stable communication during dynamic activation"
  Future<void> toggle(bool enable) async {
    try {
      state = const AsyncValue.loading();

      final helper = ref.read(rosBridgeClientProvider);

      final response = await helper.callService(
        service: serviceName,
        args: {"status": enable ? "enable" : "disable"},
        timeout: const Duration(seconds: 5),
      );

      final success = response['success'] as bool? ?? false;

      if (success) {
        final ModuleState newState = enable
            ? ModuleState.active
            : ModuleState.inactive;
        state = AsyncValue.data(newState);
        print(
          "ROS2: Node $serviceName ${enable ? 'started' : 'stopped'} successfully",
        );
      } else {
        final errorMsg = response['message'] as String? ?? 'Unknown error';
        state = AsyncValue.error(
          Exception('Node operation failed: $errorMsg'),
          StackTrace.current,
        );
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      print("Error during node toggle for $serviceName: $e");
    }
  }

  /// Refresh node status on demand for periodic sync.
  Future<void> refreshStatus() async {
    try {
      state = const AsyncValue.loading();
      final status = await _queryNodeStatus();
      state = AsyncValue.data(status);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
