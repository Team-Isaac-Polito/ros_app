import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/data/dark_mode_provider/dark_mode_provider.dart';
import 'package:isaac_app/features/main_page/data/topic_subscription_provider/topic_subscription_provider.dart';
import 'package:isaac_app/features/main_page/models/topic/topic.dart';

<<<<<<< HEAD
class TopicExpansionTile extends ConsumerWidget {
  final Topic topic;
=======
/// A reactive UI component designed to display real-time telemetry from a specific ROS 2 topic.
/// 
/// In **Riverpod 3.0**, this [ConsumerWidget] demonstrates the **Sub-Subscription** pattern. 
/// By watching a specific family instance of [topicSubscriptionProvider], the widget 
/// isolates its rebuild scope to only the data packets belonging to its assigned [topic].
///
/// References:
/// * Riverpod - AsyncValue.when: https://riverpod.dev/docs/concepts/reading#asyncvalue
/// * ROS 2 - Introspection: https://docs.ros.org/en/foxy/Concepts/About-Topic-Communication.html
/// * Material Design - Expansion Panels: https://m3.material.io/components/expansion-panels/overview
///
/// Design Rationale:
/// * **Lazy Rebuilding**: The widget only re-renders the 'monospace' text block 
///   when a new message is published on the specific [topic.topicName].
/// * **Data Visualization**: Employs [jsonEncode] to format the dynamic ROS message 
///   payload into a human-readable string for debugging and system introspection.
/// * **Thematic Adaptation**: Dynamically adjusts the background contrast of the 
///   message area based on the [darkModeProvider] state.
class TopicExpansionTile extends ConsumerWidget {
  /// The specific topic metadata (name and type) used to initialize the subscription.
  final Topic topic;
  
>>>>>>> ed34974 (Modifiche a modules_page)
  const TopicExpansionTile({super.key, required this.topic});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
<<<<<<< HEAD
    final messageAsync = ref.watch(topicSubscriptionProvider(topic.topicName));
    final isDark = ref.watch(darkModeProvider);
=======
    // Dynamically subscribes to the specific topic stream based on topicName.
    final messageAsync = ref.watch(topicSubscriptionProvider(topic.topicName));
    
    // Monitors the global theme state for local color adaptation.
    final isDark = ref.watch(darkModeProvider);

>>>>>>> ed34974 (Modifiche a modules_page)
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      child: ExpansionTile(
        leading: const Icon(Icons.hub_outlined),
        title: Text(
          topic.topicName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(topic.topicType),
        children: [
<<<<<<< HEAD
=======
          // Telemetry Output Container: Styled as a code-block for readability.
>>>>>>> ed34974 (Modifiche a modules_page)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: isDark
                ? Colors.black26
                : Colors.grey[100],
            child: messageAsync.when(
<<<<<<< HEAD
=======
              // Data State: Renders the serialized JSON payload.
>>>>>>> ed34974 (Modifiche a modules_page)
              data: (data) => Text(
                jsonEncode(data),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
<<<<<<< HEAD
              loading: () => const Text("Waiting for messages..."),
=======
              // Loading State: Indicates a successful subscription waiting for the first message.
              loading: () => const Text("Waiting for messages..."),
              // Error State: Handles stream exceptions or connection drops.
>>>>>>> ed34974 (Modifiche a modules_page)
              error: (e, _) => Text("Error: $e"),
            ),
          ),
        ],
      ),
    );
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> ed34974 (Modifiche a modules_page)
