import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/data/ros_publisher_provider/ros_publisher_provider.dart';

final moduleListProvider = AsyncNotifierProvider<ModuleListNotifier, List<String>>(
      ModuleListNotifier.new,
);

class ModuleListNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async {
    return await _fetchModulesFromGateway();
  }

  Future<List<String>> _fetchModulesFromGateway() async {
    final helper = ref.read(rosBridgeClientProvider);

    final response = await helper.callService(
      service: '/ui/node_status',
      args: {},
      timeout: const Duration(seconds: 5),
    );

    if (response['success'] == true) {
      final dynamic rawData = response['message'] ?? "";
      final String rawStatus = (rawData != null) ? rawData.toString() : "";
      if (rawStatus.isEmpty) return [];
      final List<String> lines = rawStatus.split('\n');
      final List<String> detectedModules = lines
          .map((line) {
            final parts = line.split(':');
            return parts[0].trim(); 
          })
          .where((name) => name.isNotEmpty)
          .map((name) => '/ui/$name')
          .toList();

      return detectedModules;
    } else {
      return [];
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchModulesFromGateway());
  }
}
