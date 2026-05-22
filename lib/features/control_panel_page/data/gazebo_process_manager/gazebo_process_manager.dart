import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'dart:async';

final gazeboProcessManagerProvider =
    NotifierProvider<GazeboProcessManager, bool>(GazeboProcessManager.new);

// It manages gazebo process
class GazeboProcessManager extends Notifier<bool> {
  Process? _process;
  Timer? _timer;
  String? _exception;

  Future<void> _checkInitialStatus() async {
    state = await isProcessRunning();
  }

  Future<bool> isProcessRunning() async {
    try {
      final result = await Process.run('pgrep', ['-f', 'gz sim']);
      return result.exitCode == 0;
    } catch (e) {
      _exception = e.toString();
      print(e);
      return false;
    }
  }

  void startMonitoring() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      final isRunning = await isProcessRunning();
      if (state != isRunning) {
        state = isRunning;
      }
    });
  }

  void startGazebo() async {
    if (state) return;

    try {
      _process = await Process.start('gz', [
        'sim',
        '-v',
        '4',
      ], runInShell: true);

      state = true;

      _process?.exitCode.then((exitCode) {
        _process = null;
        state = false;
      });
    } catch (e) {
      state = false;
      print("Error starting gazebo: $e");
    }
  }

  String? getException() {
    return _exception;
  }

  void stopGazebo() async {
    if (!state) return;

    try {
      if (_process != null) {
        _process?.kill(ProcessSignal.sigint);
        _process = null;
      } else {
        await Process.run('pkill', ['-f', 'gz sim']);
      }
      state = false;
    } catch (e) {
      print('Error while stopping gazebo $e');
    }
  }

  @override
  bool build() {
    _checkInitialStatus();

    startMonitoring();

    ref.onDispose(() {
      _timer?.cancel();
    });

    return false;
  }
}
