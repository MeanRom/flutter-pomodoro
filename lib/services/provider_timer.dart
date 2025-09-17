import 'dart:async'; // For Timer
import 'dart:convert';
import 'package:flutter/foundation.dart'; // For ChangeNotifier
import 'package:localstorage/localstorage.dart';
import 'package:pomodoro/interface/i_settings.dart';

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
    String raw = localStorage.getItem('settings') ?? '{}';
    ISettings settings = ISettings(
      durations: this.durations,
      darkmodeDuringRunning: this.darkmodeDuringRunning,
    );
    try {
      settings = jsonDecode(raw);
    } catch (e) {
      if (kDebugMode) {
        print("Error decoding settings from local storage: $e");
      }
    }
    if (settings.durations != null) this.durations = settings.durations;
    if (settings.darkmodeDuringRunning != null)
      this.darkmodeDuringRunning = settings.darkmodeDuringRunning;
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

  void updateDurations() {
    notifyListeners();
    if (durations.isNotEmpty) {
      _currentSeconds = (durations[index] * 60).toInt();
      notifyListeners();
      localStorage.setItem(
        'settings',
        jsonEncode({
          'durations': durations,
          'darkmodeDuringRunning': darkmodeDuringRunning,
        }),
      );
      print("Updated durations: $durations");
    }
  }

  void updateDarkmodeDuringRunning(bool value) {
    darkmodeDuringRunning = value;
    notifyListeners();
    localStorage.setItem(
      'settings',
      jsonEncode({
        'durations': durations,
        'darkmodeDuringRunning': darkmodeDuringRunning,
      }),
    );
    print("Updated darkmodeDuringRunning: $darkmodeDuringRunning");
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
