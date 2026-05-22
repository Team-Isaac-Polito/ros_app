import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/components/change_ip_dropdown/change_ip_dropdown.dart';
import 'package:isaac_app/features/main_page/components/index.dart';

class AppbarActions extends ConsumerWidget {
  const AppbarActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        const ChangeIpDropdown(),
        const DarkModeSwitcher(),
        const RefreshSocketConnection(),
      ],
    );
  }
}