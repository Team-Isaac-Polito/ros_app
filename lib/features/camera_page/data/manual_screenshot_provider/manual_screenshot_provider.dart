import 'package:flutter_riverpod/flutter_riverpod.dart';

final manualScreenShotProvider = NotifierProvider(ManualScreenshot.new);

class ManualScreenshot extends Notifier<String> {

  void setScreenshot(String newScreenshot) {
    state = newScreenshot;
  }

  void clearScreenshot() {
    state = "";
  }

  @override
  String build() {
    return "";
  }
}
