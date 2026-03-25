import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/data/ros_topics_notifier/ros_topics_notifier.dart';

final activeCameraTopicProvider = Provider.family<String, int>((ref, monitorIndex) {
  final topics = ref.watch(rosTopicsProvider).value ?? [];
  
  if (monitorIndex == 1) {
    final hasAligned = topics.any((t) => t.topicName == "/camera/color/image_raw/compressed");
    return hasAligned 
        ? "/camera/color/image_raw/compressed" 
        : "/realsense/color/image_raw/compressed";
  }
  
  return monitorIndex == 2 ? "/detector/model_output" : "/thermal/compressed";
});