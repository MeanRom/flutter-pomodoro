import 'dart:async'; // For Timer
import 'package:flutter/foundation.dart'; // For ChangeNotifier

class PomodoroTimerNotifier extends ChangeNotifier {
  List<double> durations = [25, 5, 15];
  int index = 0;
  bool isRunning = false;
  bool darkmodeDuringRunning = false;
  int _currentSeconds = 0;
  Timer? _timer;

  int currentCycleIndex = 0;
  List<int> cycle = [0, 1, 0, 1, 0, 2];

  PomodoroTimerNotifier({
    List<double>? durations,
    int? index,
    bool? isRunning,
    bool? darkmodeDuringRunning,
  }) {
    if (durations != null) this.durations = durations;
    if (index != null) this.index = index;
    if (isRunning != null) this.isRunning = isRunning;
    if (this.index < 0 || this.index >= this.durations.length) this.index = 0;
    darkmodeDuringRunning ??= false;
    _currentSeconds = (this.durations[this.index] * 60).toInt();
    print(
      "PomodoroTimerNotifier initialized with durations: $durations, index: $index, isRunning: $isRunning",
    );
  }

  String get timeString {
    final minutes = (_currentSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_currentSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _nextSession() {
    currentCycleIndex = (currentCycleIndex + 1) % cycle.length;
    index = cycle[currentCycleIndex];
    _currentSeconds = (durations[index] * 60).toInt();
    notifyListeners();
    print("Switched to session $index: ${durations[index]} minutes");
  }

  void start() {
    if (isRunning) return;
    print("Starting timer for ${durations[index]} minutes.");
    isRunning = true;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_currentSeconds > 0) {
        _currentSeconds--;
        notifyListeners();
      } else {
        timer.cancel();
        isRunning = false;
        _nextSession(); // Switch to next session
        start(); // Auto-start next session (optional)
      }
    });
    notifyListeners();
  }

  void stop() {
    if (!isRunning) return; // Prevent stopping if not running
    print("Stopping timer.");
    isRunning = false;
    _timer?.cancel();
    notifyListeners();
  }

  void updateDurations(List<double> newDurations) {
    if (newDurations.isNotEmpty) {
      durations = newDurations;
      if (index >= durations.length) index = 0; // Prevent out-of-bounds
      reset();
      notifyListeners();
      print("Updated durations: $durations");
    }
  }

  void reset() {
    print("Resetting timer.");
    isRunning = false;
    _timer?.cancel();
    _currentSeconds = (durations[index] * 60).toInt();
    notifyListeners();
  }

  void setIndex(int newIndex) {
    if (newIndex < 0 || newIndex >= durations.length) return;
    index = newIndex;
    reset();
    notifyListeners();
  }
}
