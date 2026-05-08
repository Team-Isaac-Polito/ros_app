import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/components/index.dart';
import 'package:isaac_app/features/main_page/data/folders_provider/folder_list_provider.dart';
// import 'package:isaac_app/features/main_page/data/ros_topics_notifier/ros_topics_notifier.dart';
import  'package:isaac_app/features/main_page/data/robot_ip_notifier/robot_ip_provider.dart';
import 'package:isaac_app/features/main_page/components/change_ip_dropdown/change_ip_dropdown.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  late Future<void> _layoutReady;

  @override
  void initState() {
    super.initState();
    _layoutReady = Future.delayed(Duration.zero);
  }

  @override
  Widget build(BuildContext context) {
    // It reads all the harcoded folder
    final folders = ref.watch(folderListProvider);
    // It reads all the topics that rosBridge exposes to us the traffic
    //final topics = ref.watch(rosTopicsProvider);
    final String ip = ref.watch(robotIpProvider);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Row(
              spacing: 10,
              children: [
                Text("ISAAC Dashboard"),
                ChangeIpDropdown()
              ]
            ),
            floating: true,
            snap: true,
            actions: [AppbarActions()],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Text(
                "You're currently connected to $ip",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(18),
            sliver: folders.isEmpty
                ? SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          'No folders available',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ),
                  )
                : FutureBuilder<void>(
                    future: _layoutReady,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const SliverToBoxAdapter(
                          child: SizedBox.shrink(),
                        );
                      }
                      return SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 200,
                              mainAxisSpacing: 15,
                              crossAxisSpacing: 15,
                              childAspectRatio: 1.1,
                            ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) =>
                              ControlPanelCard(element: folders[index]),
                          childCount: folders.length,
                        ),
                      );
                    },
                  ),
          ),
          // SliverToBoxAdapter(
          //   child: Padding(
          //     padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          //     child: Text(
          //       'Available Topics',
          //       style: Theme.of(context).textTheme.titleLarge,
          //     ),
          //   ),
          // ),
          // topics.when(
          //   data: (list) => SliverList(
          //     delegate: SliverChildBuilderDelegate(
          //       (context, i) => TopicExpansionTile(topic: list[i]),
          //       childCount: list.length,
          //     ),
          //   ),
          //   loading: () => const SliverToBoxAdapter(
          //     child: Center(child: CircularProgressIndicator()),
          //   ),
          //   error: (err, st) =>
          //       SliverToBoxAdapter(child: Center(child: Text('Error: $err'))),
          // ),
        ],
      ),
    );
  }
}
