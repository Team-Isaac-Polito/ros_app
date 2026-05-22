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

    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: currentRobotIp,
        borderRadius: BorderRadius.circular(12),
        dropdownColor: Theme.of(context).colorScheme.surface,
        items: possibleRobotIps.entries.map((entry) {
          return DropdownMenuItem<String>(
            value: entry.key,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                spacing: 10,
                children: [
                  Icon(
                    entry.key.contains('localhost')
                        ? Icons.computer
                        : Icons.precision_manufacturing,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  Text(
                    entry.value,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            robotIpNotifier.changeIp(newValue);
          }
        },
      ),
    );
  }
}
