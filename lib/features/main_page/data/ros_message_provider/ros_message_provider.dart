// It returns the traffic of a channel
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/main_page/data/ros_bridge_stream_provider/ros_bridge_stream_provider.dart';


/// Provider che va a leggere ogni evento che la stream
/// torna e se e' di tipo publush ritornaa un oggetto con il
/// canale e il messaggio altrimenti torna mappa vuota
/// Nel caso in cui torni mappa vuota, verra eliminata dal filtro where
final rosMessagesProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final stream = ref.watch(rosBridgeStreamProvider);

  return stream.map((event) {
    try {
      final data = jsonDecode(event);
      if (data["op"] == "publish") {
        return {
          "topic": data["topic"] as String, 
          "msg": data["msg"] as Map<String, dynamic>
        };
      }
    } catch (e) {
      print("Errore decodifica: $e");
    }
    return <String, dynamic>{};
  }).where((data) => data.isNotEmpty);
});