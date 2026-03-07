import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/modules_page/components/module_card/provider/number_of_active_modules_provider/number_of_active_module_provider.dart';
import 'package:isaac_app/features/modules_page/components/module_card/provider/number_of_modules_provider/number_of_module_provider.dart';

class SymbolLegend extends ConsumerWidget {
  const SymbolLegend({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final numberOfActiveModule = ref.watch(numberOfActiveModulesProvider);
    final totalNumberOfModules = ref.watch(numberOfModulesProvider);
    return Column(
      spacing: 15,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Active modules: $numberOfActiveModule su $totalNumberOfModules"),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: ExpansionTile(
            title: Text('Legenda simboli'),
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.check, color: Colors.green),
                title: Text('working ok'),
              ),
              ListTile(
                leading: Icon(Icons.warning, color: Colors.orange),
                title: Text('Warning'),
              ),
              ListTile(
                leading: Icon(Icons.offline_bolt, color: Colors.red),
                title: Text('Offline'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
