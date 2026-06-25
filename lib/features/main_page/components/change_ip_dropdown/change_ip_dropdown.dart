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
    final ipListNotifier = ref.read(robotIpListProvider.notifier);

    final isValidIp = possibleRobotIps.containsKey(currentRobotIp);

    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: isValidIp ? currentRobotIp : null,
        borderRadius: BorderRadius.circular(12),
        dropdownColor: Theme.of(context).colorScheme.surface,
        items: possibleRobotIps.entries.map((entry) {
          final isDefault = entry.key == "ws://localhost:9090" || entry.key == "ws://192.168.8.104:9090";

          return DropdownMenuItem<String>(
            value: entry.key,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    entry.key.contains('localhost') ? Icons.computer : Icons.precision_manufacturing,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    entry.value,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  if (!isDefault) ...[
                    const SizedBox(width: 20),
                    InkWell(
                      onTap: () {
                        ipListNotifier.removeIp(entry.key);
                        if (currentRobotIp == entry.key) {
                           robotIpNotifier.changeIp("ws://localhost:9090");
                        }
                      },
                      child: const Icon(Icons.close, size: 16, color: Colors.red),
                    )
                  ]
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