import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/data/ros_bridge_provider/ros_bridge_provider.dart';
import 'package:isaac_app/features/main_page/data/ros_bridge_stream_provider/ros_bridge_stream_provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// A generic ROS 2 service call helper that handles request-response matching,
/// timeouts, and proper resource cleanup.
///
/// This helper centralizes the "call service" logic used across multiple providers,
/// eliminating code duplication and ensuring consistent error handling.
///
/// Usage:
/// ```dart
/// final result = await ref.read(rosServiceCallHelperProvider).call(
///   service: '/my/service',
///   args: {'param': 'value'},
///   timeout: Duration(seconds: 3),
/// );
/// ```
final rosServiceCallHelperProvider = Provider<RosServiceCallHelper>(
  (ref) => RosServiceCallHelper(ref),
);

class RosServiceCallHelper {
  final Ref ref;

  RosServiceCallHelper(this.ref);

  /// Executes a ROS 2 service call with proper request-response matching.
  ///
  /// Parameters:
  /// - [service]: The ROS 2 service path (e.g., '/my/service')
  /// - [args]: Service arguments as a Map (optional)
  /// - [timeout]: Maximum time to wait for response (default: 3 seconds)
  ///
  /// Returns a Map containing the service response values.
  /// Throws an exception if the service call times out or fails.
  Future<Map<String, dynamic>> call({
    required String service,
    Map<String, dynamic>? args,
    Duration timeout = const Duration(seconds: 3),
  }) async {
    final WebSocketChannel channel = ref.read(rosBridgeProvider);
    final String requestId =
        "${service}_${DateTime.now().millisecondsSinceEpoch}";
    final completer = Completer<Map<String, dynamic>>();
    final Stream stream = ref.read(rosBridgeStreamProvider);

    // Establishing a temporary listener for the specific service response.
    final sub = stream.listen((message) {
      try {
        final data = jsonDecode(message);
        if (data["op"] == 'service_response' && data["id"] == requestId) {
          if (!completer.isCompleted) {
            completer.complete(data["values"] ?? {});
          }
        }
      } catch (e) {
        // Ignore parsing errors for unrelated messages
      }
    });

    // Serializing and dispatching the JSON-RPC call.
    try {
      channel.sink.add(
        jsonEncode({
          "op": "call_service",
          "service": service,
          if (args != null) "args": args,
          "id": requestId,
        }),
      );

      return await completer.future.timeout(timeout);
    } on TimeoutException catch (_) {
      throw TimeoutException(
        'Service call to $service timed out after ${timeout.inSeconds}s',
      );
    } catch (e) {
      rethrow;
    } finally {
      // Mandatory cleanup of the transient stream subscription.
      sub.cancel();
    }
  }
}
