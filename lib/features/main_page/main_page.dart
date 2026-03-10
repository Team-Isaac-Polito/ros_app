import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/components/index.dart';
import 'package:isaac_app/features/main_page/data/folders_provider/folder_list_provider.dart';
import 'package:isaac_app/features/main_page/data/ros_topics_notifier/ros_topics_notifier.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  @override
  Widget build(BuildContext context) {
    // It reads all the harcoded folder
    final folders = ref.watch(folderListProvider);
    // It reads all the topics that rosBridge exposes to us the traffic
    final topics = ref.watch(rosTopicsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text("ISAAC Dashboard"),
            actions: [
              const DarkModeSwitcher(),
              const RefreshSocketConnection(),
              ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(18),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200, // Larghezza massima di ogni card
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                childAspectRatio: 1.1, // Proporzione card
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => ControlPanelCard(element: folders[index]),
                childCount: folders.length,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Text(
                'Available Topics',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          topics.when(
            data: (list) => SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => TopicExpansionTile(topic: list[i]),
                childCount: list.length,
              ),
            ),
            loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, st) =>
                SliverToBoxAdapter(child: Center(child: Text('Error: $err'))),
          ),
        ],
      ),
    );
  }
}
