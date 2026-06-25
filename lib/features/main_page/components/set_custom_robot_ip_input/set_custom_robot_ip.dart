import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/data/robot_ip_notifier/robot_ip_list.dart';
import 'package:isaac_app/utils/palette.dart';

class SetCustomRobotIpInput extends ConsumerStatefulWidget {
  const SetCustomRobotIpInput({super.key});

  @override
  ConsumerState<SetCustomRobotIpInput> createState() =>
      _SetCustomRobotIpInputState();
}

class _SetCustomRobotIpInputState extends ConsumerState<SetCustomRobotIpInput> {
  final GlobalKey<FormState> _addIpFormKey = GlobalKey<FormState>();
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _labelController = TextEditingController(); // Aggiungiamo un nome per l'IP

  @override
  void dispose() {
    _ipController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
        ),
        color: colorScheme.surfaceContainerLow,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _addIpFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.add_link_rounded, color: colorScheme.primary, size: 22),
                    const SizedBox(width: 10),
                    Text("Add New Target Machine",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold, color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _ipController,
                  keyboardType: TextInputType.url,
                  style: const TextStyle(fontFamily: 'monospace'),
                  decoration: InputDecoration(
                    isDense: true,
                    labelText: 'IP Address / Host',
                    hintText: '192.168.1.100:9090',
                    prefixText: 'ws:// ',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
    
                TextFormField(
                  controller: _labelController,
                  decoration: InputDecoration(
                    isDense: true,
                    labelText: 'Machine Label (Optional)',
                    hintText: 'e.g. Robot Lab B',
                    prefixIcon: const Icon(Icons.label_outline, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.blue
                    ),
                    onPressed: () {
                      if (_addIpFormKey.currentState!.validate()) {
                        final cleanIp = "ws://${_ipController.text.trim()}";
                        final label = _labelController.text.trim().isEmpty 
                                    ? "Custom Robot" 
                                    : _labelController.text.trim();
                        
                        ref.read(robotIpListProvider.notifier).addIp(cleanIp, label);
                        
                        _ipController.clear();
                        _labelController.clear();
    
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('$label added to connection list!')),
                        );
                      }
                    },
                    icon: const Icon(Icons.add, size: 20,color: white),
                    label: const Text('Add to Dropdown', style: TextStyle(fontWeight: FontWeight.w600, color: white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}