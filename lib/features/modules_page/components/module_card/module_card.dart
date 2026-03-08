import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/data/index.dart';
import 'package:isaac_app/features/modules_page/components/module_card/provider/module_status_provider/data/enum/modul_state.dart';
import 'package:isaac_app/features/modules_page/components/module_card/provider/module_status_provider/module_status_provider.dart' hide ModuleState;

class ModuleCard extends ConsumerWidget {
  final String moduleName;
  final IconData icon;
  final Color accentColor;
  final Widget? trailing;
  final String serviceName;

  const ModuleCard({
    super.key,
    required this.moduleName,
    required this.icon,
    required this.serviceName,
    this.accentColor = Colors.blueAccent,
    this.trailing,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(darkModeProvider);
    final moduleStatus = ref.watch(moduleStatusProvider(serviceName));

    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [Colors.white.withValues(alpha: 0.05), Colors.transparent]
                : [Colors.black.withValues(alpha: 0.01), Colors.transparent],
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: accentColor, size: 28),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text(
                  moduleName.toUpperCase(),
                  style: TextStyle(
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                // Handle AsyncValue states for robust error handling
                moduleStatus.when(
                  // Node status loaded successfully
                  data: (status) {
                    final isActive = status == ModuleState.active;
                    return Switch(
                      value: isActive,
                      onChanged: (bool value) {
                        ref
                            .read(moduleStatusProvider(serviceName).notifier)
                            .toggle(value);
                      },
                    );
                  },
                  // Loading state during initialization or toggle operation
                  loading: () => const SizedBox(
                    height: 24,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.blue),
                      ),
                    ),
                  ),
                  error: (error, stackTrace) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 10,
                    children: [
                      Icon(Icons.warning),
                      Text('Error communicating with node: $error'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
