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
        "scrot",
        [
          '-z', // Modalità silenziosa (evita beep o flash grafici)
          '-',  // Dice a scrot di sparare i byte PNG direttamente nel stdout (RAM)
        ],
        stdoutEncoding: null,
      );

      if (process?.exitCode == 0) {
        state = Uint8List.fromList(process?.stdout as List<int>);
        exception = null;
      } else {
        final errorString = process?.stderr is String 
            ? process?.stderr as String 
            : process?.stderr.toString() ?? "Errore sconosciuto";

        exception = errorString;
        print("🚨 L'ERRORE DI SCROT È: $errorString");
        state = null;
      }
    } catch (e) {
      exception = e.toString();
      print("Exception gazebo screenshot $exception");
      state = null;
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
