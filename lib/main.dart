import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'tray_controller.dart';

const int timerDurationInSeconds = 10; // TODO: Change to 25 minutes in seconds

void main() {
  WidgetsFlutterBinding.ensureInitialized;
  runApp(const FocusTimerApp());
}

class FocusTimerApp extends StatefulWidget {
  const FocusTimerApp({super.key});

  @override
  State<StatefulWidget> createState() => _FocusTimerAppState();
}

class _FocusTimerAppState extends State<FocusTimerApp> {
  late final TrayController tray;
  int _remainingSeconds = timerDurationInSeconds;
  Timer? _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    tray = TrayController(
      onStart: _startTimer,
      onPause: _pauseTimer,
      onReset: _resetTimer,
    );
    tray.init(initialTitle: _format(_remainingSeconds));
  }

  String _format(int remainingSeconds) {
    final s = remainingSeconds % 60;
    final m = (remainingSeconds ~/ 60) % 60;
    final h = remainingSeconds ~/ 3600;
    return h > 0
        ? "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}"
        : "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  void _startTimer() {
    if (_timer != null && _timer!.isActive) return; // Prevent multiple timers
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
        tray.updateTitle(_format(_remainingSeconds));
      } else {
        timer.cancel();
        _playAlarm();
      }
    });
  }

  Future<void> _playAlarm() async {
    await _audioPlayer.play(AssetSource('sounds/final_beep.mp3'));
  }

  void _pauseTimer() {
    _timer?.cancel();
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = timerDurationInSeconds;
    });
    tray.updateTitle(_format(_remainingSeconds));
  }

  @override
  void dispose() {
    _timer?.cancel();
    tray.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Focus Timer")),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _format(_remainingSeconds),
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _startTimer,
                    child: const Text("Start"),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _pauseTimer,
                    child: const Text("Pause"),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _resetTimer,
                    child: const Text("Reset"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
