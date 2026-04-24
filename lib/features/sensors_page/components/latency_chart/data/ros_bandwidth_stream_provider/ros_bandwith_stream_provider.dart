
final bandwidthProvider = StreamProvider<List<double>>((ref) async* {
  double lastTotal = 0.0;
  List<double> history = [];

  yield* Stream.periodic(const Duration(seconds: 1), (_) {
    final currentTotal = ref.read(rosTrafficCounterProvider);
    
    double bytesThisSecond = currentTotal - lastTotal;
    
    lastTotal = currentTotal;

    double kbps = (bytesThisSecond * 8) / 1000;

    history.add(kbps);
    if (history.length > 20) history.removeAt(0);

    return List<double>.from(history);
  });
});