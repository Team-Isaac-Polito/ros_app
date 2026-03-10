import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/modules_page/provider/module_list_provider/module_list_provider.dart';
import 'package:isaac_app/features/modules_page/provider/module_status_provider/module_status_provider.dart';

final numberOfActiveModulesProvider = Provider<int>((ref) {
  final modulesAsync = ref.watch(moduleListProvider);

  return modulesAsync.maybeWhen(
    data: (services) {
      int count = 0;
      for (final service in services) {
        final status = ref.watch(moduleStatusProvider(service)).value;
        if (status == ModuleState.active) {
          count++;
        }
      }
      return count;
    },
    orElse: () => 0,
  );
});
