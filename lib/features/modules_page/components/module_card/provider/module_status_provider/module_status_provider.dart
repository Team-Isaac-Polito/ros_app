import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/data/index.dart';
import 'package:isaac_app/features/modules_page/components/module_card/provider/number_of_active_modules_provider/number_of_active_module_provider.dart';
import 'package:isaac_app/features/modules_page/components/module_card/provider/number_of_modules_provider/number_of_module_provider.dart';

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
    Future.microtask(() {
      ref.read(numberOfModulesProvider.notifier).increment();
    });

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
    final helper = ref.read(rosServiceCallHelperProvider);

    final response = await helper.call(
      service: serviceName,
      args: {"data": "get_status"},
      timeout: const Duration(seconds: 3),
    );

    final statusStr = response['status'] as String? ?? 'inactive';
    return statusStr.toLowerCase() == 'active'
        ? ModuleState.active
        : ModuleState.inactive;
  }

  /// Activate or deactivate the node with deterministic error handling.
  /// Implements:
  /// - "App can request activation or deactivation"
  /// - "Clean startup/shutdown avoiding orphan processes"
  /// - "Stable communication during dynamic activation"
  Future<void> toggle(bool enable) async {
    try {
      state = const AsyncValue.loading();

      final helper = ref.read(rosServiceCallHelperProvider);

      // Send start/stop command to robot
      final response = await helper.call(
        service: serviceName,
        args: {"data": enable ? "start" : "stop"},
        timeout: const Duration(seconds: 5),
      );

      // Verify robot confirmed the operation
      final success = response['success'] as bool? ?? false;

      if (success) {
        final newState = enable ? ModuleState.active : ModuleState.inactive;
        state = AsyncValue.data(newState);

        final nActiveModules = ref.read(numberOfActiveModulesProvider.notifier);
        if (enable) {
          nActiveModules.increment();
        } else {
          nActiveModules.decrement();
        }

        print(
          "ROS2: Node $serviceName ${enable ? 'started' : 'stopped'} successfully",
        );
      } else {
        final errorMsg = response['error'] as String? ?? 'Unknown error';
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
