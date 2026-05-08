import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/data/robot_ip_notifier/robot_ip_list.dart';
import 'package:isaac_app/features/main_page/data/robot_ip_notifier/robot_ip_provider.dart';

class ChangeIpDropdown extends ConsumerWidget {
  const ChangeIpDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRobotIp = ref.watch(robotIpProvider);
    final robotIpNotifier = ref.read(robotIpProvider.notifier);
    final possibleRobotIps = ref.watch(robotIpListProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentRobotIp,
          icon: const Icon(Icons.sensors, size: 20),
          borderRadius: BorderRadius.circular(12),
          dropdownColor: Theme.of(context).colorScheme.surface,
          items: possibleRobotIps.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Row(
                children: [
                  Icon(
                    entry.key.contains('localhost')
                        ? Icons.computer
                        : Icons.precision_manufacturing,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    entry.value,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              robotIpNotifier.changeIp(newValue);
            }
          },
        ),
      ),
    );
  }
}
