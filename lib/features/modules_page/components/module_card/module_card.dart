import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/data/index.dart';
import 'package:isaac_app/features/modules_page/components/module_card/provider/module_status_provider/module_status_provider.dart';

class ModuleCard extends ConsumerWidget {
  final String moduleName;
  final IconData icon;
  final Color accentColor;
  final Widget? trailing; // Per metterci un piccolo grafico o un badge

  const ModuleCard({
    super.key,
    required this.moduleName,
    required this.icon,
    this.accentColor = Colors.blueAccent,
    this.trailing,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(darkModeProvider);
    final isEnable = ref.watch(moduleStatusProvider(moduleName));

    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          // Sfumatura sottile per dare profondità
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
                // Icona racchiusa in un cerchio stilizzato
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
                const SizedBox(height: 4),
                // Indicatore di stato ROS2
                Switch(
                  value: isEnable,
                  onChanged: (bool value) {
                    ref
                        .read(moduleStatusProvider(moduleName).notifier)
                        .toggle(value);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
