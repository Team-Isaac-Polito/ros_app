// number_of_active_module_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/modules_page/components/module_card/provider/module_list_provider/module_list_provider.dart';

final numberOfModulesProvider = Provider<int>((ref) {
  return ref.watch(moduleListProvider).maybeWhen(
    data: (list) => list.length,
    orElse: () => 0,
  );
});