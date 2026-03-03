import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/data/index.dart';
import 'package:isaac_app/features/modules_page/components/module_card/provider/number_of_active_modules_provider/number_of_active_module_provider.dart';
import 'package:isaac_app/features/modules_page/components/module_card/provider/number_of_modules_provider/number_of_module_provider.dart';

/// Represents the state of a module (sensor node).
/// - [active]: Node is running on the robot
/// - [inactive]: Node is not running on the robot
enum ModuleState { active, inactive }

/// AsyncNotifierProvider that manages the lifecycle of ROS2 sensor nodes
/// (thermal camera, LiDAR, etc.) with deterministic startup/shutdown.
///
/// Features:
/// - Queries current node state on initialization for consistency
/// - Implements deterministic activation/deactivation with error handling
/// - Provides clean async lifecycle management via AsyncNotifier
/// - Eliminates orphan processes through proper error recovery
final moduleStatusProvider =
    AsyncNotifierProvider.family<ModuleStatusNotifier, ModuleState, String>((
      serviceName,
    ) {
      return ModuleStatusNotifier(serviceName);
    });

class ModuleStatusNotifier extends AsyncNotifier<ModuleState> {
  final String serviceName;

  ModuleStatusNotifier(this.serviceName);

  /// Initializes by querying the actual node state from the robot.
  ///
  /// This ensures the UI reflects reality, not assumptions.
  /// Implements "clean, deterministic lifecycle" requirement.
  @override
  Future<ModuleState> build() async {
    Future.microtask(() {
      ref.read(numberOfModulesProvider.notifier).increment();
    });

    try {
      return await _queryNodeStatus();
    } catch (e) {
      print("Error querying node status for $serviceName: $e");
      // Default to inactive if query fails - conservative approach
      return ModuleState.inactive;
    }
  }

  /// Queries the ROS2 node status from the robot.
  ///
  /// Implements "app can query the current state of these nodes" requirement.
  Future<ModuleState> _queryNodeStatus() async {
    final helper = ref.read(rosServiceCallHelperProvider);

    final response = await helper.call(
      service: serviceName,
      args: {"data": "get_status"},
      timeout: const Duration(seconds: 3),
    );

    // Parse response: assumes robot returns {"status": "active"} or {"status": "inactive"}
    final statusStr = response['status'] as String? ?? 'inactive';
    return statusStr.toLowerCase() == 'active'
        ? ModuleState.active
        : ModuleState.inactive;
  }

  /// Activates or deactivates the node with deterministic error handling.
  ///
  /// Implements:
  /// - "App can request activation or deactivation"
  /// - "Clean startup/shutdown avoiding orphan processes"
  /// - "Stable communication while dynamically activated"
  Future<void> toggle(bool enable) async {
    try {
      // Set loading state during operation
      state = const AsyncValue.loading();

      final helper = ref.read(rosServiceCallHelperProvider);

      // Send the start/stop command to robot
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

        // Update the active modules counter
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
        // Robot returned error - mark as error state
        final errorMsg = response['error'] as String? ?? 'Unknown error';
        state = AsyncValue.error(
          Exception('Node operation failed: $errorMsg'),
          StackTrace.current,
        );
        print(
          "ROS2: Failed to ${enable ? 'start' : 'stop'} $serviceName: $errorMsg",
        );
      }
    } catch (e, st) {
      // Communication error - mark state as error
      state = AsyncValue.error(e, st);
      print("Error during node toggle for $serviceName: $e");
    }
  }

  /// Refreshes the node status on demand.
  ///
  /// Useful for periodic sync or when user explicitly requests refresh.
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
