import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/modules_page/components/index.dart';
import 'package:isaac_app/features/modules_page/provider/index.dart';
import 'package:isaac_app/features/modules_page/provider/module_list_provider/module_list_provider.dart';

class ModulesPage extends ConsumerWidget {
  const ModulesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modulesAsync = ref.watch(moduleListProvider);
    final nActive = ref.watch(numberOfActiveModulesProvider);
    final nTotal = ref.watch(numberOfModulesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Modules")),
      body: modulesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Errore: $err")),
        data: (services) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 20,
            children: [
              Text("Active:  $nActive / $nTotal"),
              Expanded(
                child: GridView.builder(
                  itemCount: services.length,
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 300,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemBuilder: (context, index) {
                    final service = services[index];
                    return ModuleCard(
                      serviceName: service,
                      moduleName: service.split('/').last.toUpperCase(),
                      icon: service.contains('thermal')
                          ? Icons.thermostat
                          : Icons.sensors,
                      accentColor: service.contains('thermal')
                          ? Colors.orange
                          : Colors.green,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
