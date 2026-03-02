import 'package:flutter_riverpod/flutter_riverpod.dart';

<<<<<<< HEAD
final manualScreenShotProvider = NotifierProvider(ManualScreenshot.new);

class ManualScreenshot extends Notifier<String> {

=======
/// A [NotifierProvider] that holds the state of the most recently captured
/// high-resolution static frame.
///
/// In **Riverpod 3.0**, this class-based Notifier manages a single [String]
/// (Base64 encoded image data). It allows the UI to display a fixed inspection
/// image that persists independently of the live video stream.
///
/// References:
/// * Riverpod 3.0 - Notifier: https://riverpod.dev/docs/concepts/providers/notifier_provider
/// * Base64 Images in Flutter: https://api.flutter.dev/flutter/widgets/Image/Image.memory.html
///
/// Design Rationale:
/// * **State Isolation**: Separates the "Inspection View" from the "Live View,"
///   allowing the operator to analyze a specific moment without network lag
///   affecting the visualization.
/// * **Memory Efficiency**: By storing only the latest string, it prevents
///   memory bloat while providing an immediate source for [Image.memory] rendering.
final manualScreenShotProvider = NotifierProvider<ManualScreenshot, String>(
  ManualScreenshot.new,
);

class ManualScreenshot extends Notifier<String> {
  /// Updates the current state with a new Base64 image string.
  ///
  /// This is typically called by the [CameraStatusServiceNotifier] after
  /// a successful '/detection/capture_frame' service response.
>>>>>>> ed34974 (Modifiche a modules_page)
  void setScreenshot(String newScreenshot) {
    state = newScreenshot;
  }

<<<<<<< HEAD
=======
  /// Resets the screenshot state to an empty string.
  ///
  /// Use this to clear the "Inspection View" and return the UI to a
  /// placeholder or live stream mode.
>>>>>>> ed34974 (Modifiche a modules_page)
  void clearScreenshot() {
    state = "";
  }

<<<<<<< HEAD
=======
  /// Initializes the provider with an empty string.
  ///
  /// Upon first load, the provider indicates that no manual capture
  /// has been requested yet.
>>>>>>> ed34974 (Modifiche a modules_page)
  @override
  String build() {
    return "";
  }
}
