final rosTrafficPrrovider = Provider((ref){
    ref.listen(rosBridgeStreamProvider, (previous, next) {
    next.whenData((event) {
      ref.read(rosTrafficCounterProvider.notifier).increment(
            event.toString().length.toDouble(),
          );
    });
})