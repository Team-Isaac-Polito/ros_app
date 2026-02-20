import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/data/dark_mode_provider/dark_mode_provider.dart';
import 'package:isaac_app/features/main_page/data/topic_subscription_provider/topic_subscription_provider.dart';
import 'package:isaac_app/features/main_page/models/topic/topic.dart';

class TopicExpansionTile extends ConsumerWidget {
  final Topic topic;
  const TopicExpansionTile({super.key, required this.topic});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageAsync = ref.watch(topicSubscriptionProvider(topic.topicName));
    final isDark = ref.watch(darkModeProvider);
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: isDark
                ? Colors.black26
                : Colors.grey[100],
            child: messageAsync.when(
              data: (data) => Text(
                jsonEncode(data),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
              loading: () => const Text("Waiting for messages..."),
              error: (e, _) => Text("Error: $e"),
            ),
          ),
        ],
      ),
    );
  }
}
