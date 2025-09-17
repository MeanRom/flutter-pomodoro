import 'dart:async'; // For Timer
import 'dart:convert';
import 'package:flutter/foundation.dart'; // For ChangeNotifier
import 'package:localstorage/localstorage.dart';
import 'package:pomodoro/interface/i_settings.dart';

class PomodoroTimerNotifier extends ChangeNotifier {
  final List<double> _durations = [25, 5, 15];
  int _index = 0;
  bool _isRunning = false;
  bool _darkmodeDuringRunning = false;
  int _currentSeconds = 0;
  Timer? _timer;

  int _currentCycleIndex = 0;
  final List<int> _cycle = [0, 1, 0, 1, 0, 2];

  PomodoroTimerNotifier({
    List<double>? durations,
    int? index,
    bool? isRunning,
    bool? darkmodeDuringRunning,
  }) {
    String raw = localStorage.getItem('settings') ?? '';
    ISettings settings = ISettings(
      durations: durations ?? [25, 5, 15],
      darkmodeDuringRunning: darkmodeDuringRunning ?? false,
    );
    try {
      settings = ISettings.fromJson(jsonDecode(raw));
    } catch (e) {
      if (kDebugMode) {
        print("Error decoding settings from local storage: $e");
      }
    }

    if (settings != null) {
      if (settings.durations != null && settings.durations.length >= 3) {
        for (int i = 0; i < 3; i++) {
          _durations[i] = settings.durations[i];
        }
      }
      if (settings.darkmodeDuringRunning != null) {
        _darkmodeDuringRunning = settings.darkmodeDuringRunning;
      }
    }

    _index = index ?? 0;
    _isRunning = isRunning ?? false;
    _currentSeconds = (_durations[_index] * 60).toInt();
    _currentCycleIndex = _cycle.indexOf(_index);
  }

  String get timeString {
    final minutes = (_currentSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_currentSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  get darkmodeDuringRunning => _darkmodeDuringRunning;

  bool get isRunning => _isRunning;

  get durations => _durations;

  Object get index => _index;

  void _nextSession() {
    _currentCycleIndex = (_currentCycleIndex + 1) % _cycle.length;
    _index = _cycle[_currentCycleIndex];
    _currentSeconds = (_durations![_index] * 60).toInt();
    notifyListeners();
    print("Switched to session $_index: ${_durations![_index]} minutes");
  }

  void start() {
    if (_isRunning) return;
    print("Starting timer for ${_durations![_index]} minutes.");
    _isRunning = true;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_currentSeconds > 0) {
        _currentSeconds--;
        notifyListeners();
      } else {
        timer.cancel();
        _isRunning = false;
        _nextSession(); // Switch to next session
        start(); // Auto-start next session (optional)
      }
    });
    notifyListeners();
  }

  void stop() {
    if (!_isRunning) return; // Prevent stopping if not running
    print("Stopping timer.");
    _isRunning = false;
    _timer?.cancel();
    notifyListeners();
  }

  void updateDurations() {
    notifyListeners();
    if (_durations.isNotEmpty) {
      _currentSeconds = (_durations[_index] * 60).toInt();
      localStorage.setItem(
        'settings',
        jsonEncode({
          'durations': _durations,
          'darkmodeDuringRunning': _darkmodeDuringRunning,
        }),
      );
      print("Updated durations: $_durations");
    }
  }

  void updateDarkmodeDuringRunning(bool value) {
    _darkmodeDuringRunning = value;
    notifyListeners();
    localStorage.setItem(
      'settings',
      jsonEncode({
        'durations': _durations,
        'darkmodeDuringRunning': _darkmodeDuringRunning,
      }),
    );
    print("Updated darkmodeDuringRunning: $_darkmodeDuringRunning");
  }

  void reset() {
    print("Resetting timer.");
    _isRunning = false;
    _timer?.cancel();
    _currentSeconds = (_durations[_index] * 60).toInt();
    notifyListeners();
  }

  void setIndex(int newIndex) {
    if (newIndex < 0 || newIndex >= _durations.length) return;
    _index = newIndex;
    reset();
    notifyListeners();
  }
}
