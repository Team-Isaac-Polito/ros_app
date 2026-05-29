import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/*
  This notifier is dedicated to hold last gazebo screenshot
*/

final gazeboScreenshotManagerProvider =
    NotifierProvider<GazeboScreenshotManagerNotifier, Uint8List?>(
      GazeboScreenshotManagerNotifier.new,
    );

class GazeboScreenshotManagerNotifier extends Notifier<Uint8List?> {
  ProcessResult? process;
  String? exception;
  void takeScreenshot() async {
    print("Fired");
    try {
      process = await Process.run(
        "/bin/bash",
        [
          '-c',
          'import -window "\$(xdotool search --name "Gazebo" | head -n 1)" png:-',
        ],
        // We use stdoutEncoding: nullto tell dart to capture raw bytes and not a text string
        stdoutEncoding: null,
      );

      if (process?.exitCode == 0) {
        state = Uint8List.fromList(process?.stdout as List<int>);
        exception = null;
      } else {
        exception = process?.stderr.toString();
        state = null;
      }
    } catch (e) {
      exception = e.toString();
      print("Exception gazebo screenshot $exception");
    }
  }

  void clearScreenshot() {
    state = null;
  }

  @override
  Uint8List? build() {
    return null;
  }
}
