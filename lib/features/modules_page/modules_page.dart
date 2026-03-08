import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/modules_page/components/index.dart';
import 'package:isaac_app/features/modules_page/components/module_card/provider/index.dart';

class ModulesPage extends ConsumerWidget {
  const ModulesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nActiveModules = ref.watch(numberOfActiveModulesProvider);
    final nModules = ref.watch(numberOfModulesProvider);
    final nErrorModules = ref.watch(numberOfModulesInErrorProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Modules"), centerTitle: true),
      body: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = constraints.maxWidth < 600 ? 1 : 3;
          return Container(
            margin: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 20,
                    ),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Numer of active modules: $nActiveModules/$nModules"),
                Text("Numer of modules in error: $nErrorModules/$nModules"),
                Expanded(
                  child: SingleChildScrollView(
                    child: GridView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.1,
                      ),
                      children: const [
                        ModuleCard(
                          moduleName: "Camera termica",
                          icon: Icons.thermostat,
                          accentColor: Colors.orange,
                          serviceName: "/ui/thermal",
                        ),
                        ModuleCard(
                          moduleName: "Lidar",
                          icon: Icons.sensors,
                          accentColor: Colors.green,
                          serviceName: "/ui/lidar",
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
