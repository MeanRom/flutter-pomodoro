import 'dart:async'; // For Timer
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart'; // For ChangeNotifier
import 'package:localstorage/localstorage.dart';
import 'package:pomodoro/services/notification_service.dart';
import 'package:pomodoro/services/live_activity_service.dart';
import 'package:pomodoro/interface/i_settings.dart';

class PomodoroTimerNotifier extends ChangeNotifier {
  final List<double> _durations = [25, 5, 15];
  int _index = 0;
  bool _isRunning = false;
  bool _darkmodeDuringRunning = false;
  int _currentSeconds = 0;
  Timer? _timer;
  final player = AudioPlayer();
  final liveActivity = LiveActivityService();
  bool isBreak = false;

  int _currentCycleIndex = 0;
  final List<int> _cycle = [0, 1, 0, 1, 0, 2];

  // Notification IDs (keep stable across schedules)
  static const int _notifEndId = 1001;
  static const String _timerStateKey = 'timer_state_v1';

  // Wall-clock tracking
  DateTime? _sessionStart; // when current session started
  int _sessionDurationSeconds = 0; // planned duration of current session

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
      if (kDebugMode) {}
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
    _restoreState();
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

  String _sessionName(int idx) {
    switch (idx) {
      case 0:
        isBreak = false;
        return 'Focus';
      case 1:
        isBreak = true;
        return 'Short break';
      case 2:
        isBreak = true;
        return 'Long break';
      default:
        return 'Session';
    }
  }

  int _sessionDurationForIndex(int idx) => (_durations[idx] * 60).toInt();

  int _remainingSecondsByWallClock() {
    if (_sessionStart == null || _sessionDurationSeconds <= 0) {
      return _currentSeconds;
    }
    final elapsed = DateTime.now().difference(_sessionStart!).inSeconds;
    return (_sessionDurationSeconds - elapsed).clamp(
      0,
      _sessionDurationSeconds,
    );
  }

  void _updateDisplayedRemaining() {
    _currentSeconds = _remainingSecondsByWallClock();
  }

  int? _readInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  void _persistState() {
    final state = {
      'isRunning': _isRunning,
      'index': _index,
      'cycleIndex': _currentCycleIndex,
      'currentSeconds': _currentSeconds,
      'sessionDurationSeconds': _sessionDurationSeconds,
      'sessionStart': _sessionStart?.toIso8601String(),
    };
    localStorage.setItem(_timerStateKey, jsonEncode(state));
  }

  void _restoreState() {
    String raw = localStorage.getItem(_timerStateKey) ?? '';
    if (raw.isEmpty) return;
    Map<String, dynamic> state;
    try {
      state = jsonDecode(raw);
    } catch (_) {
      return;
    }

    final wasRunning = state['isRunning'] == true;
    final restoredIndex = _readInt(state['index']);
    if (restoredIndex != null &&
        restoredIndex >= 0 &&
        restoredIndex < _durations.length) {
      _index = restoredIndex;
    }

    final restoredCycleIndex = _readInt(state['cycleIndex']);
    if (restoredCycleIndex != null &&
        restoredCycleIndex >= 0 &&
        restoredCycleIndex < _cycle.length) {
      _currentCycleIndex = restoredCycleIndex;
    } else {
      final fallback = _cycle.indexOf(_index);
      _currentCycleIndex = fallback >= 0 ? fallback : 0;
    }

    final restoredCurrentSeconds = _readInt(state['currentSeconds']);
    if (restoredCurrentSeconds != null && restoredCurrentSeconds >= 0) {
      _currentSeconds = restoredCurrentSeconds;
    }

    final restoredDuration = _readInt(state['sessionDurationSeconds']);
    if (restoredDuration != null && restoredDuration > 0) {
      _sessionDurationSeconds = restoredDuration;
    } else {
      _sessionDurationSeconds = _sessionDurationForIndex(_index);
    }

    if (wasRunning) {
      final startRaw = state['sessionStart'];
      final parsedStart =
          startRaw is String ? DateTime.tryParse(startRaw) : null;
      _sessionStart = parsedStart ?? DateTime.now();
      _isRunning = true;
      _advanceByWallClock();
      NotificationService().cancel(_notifEndId);
      _scheduleEndNotification();
      _startLiveActivity();
      _ensureTicker();
      _persistState();
      notifyListeners();
    } else {
      _isRunning = false;
      _sessionStart = null;
    }
  }

  Future<void> _scheduleEndNotification() async {
    final remaining = _remainingSecondsByWallClock();
    await NotificationService().scheduleInSeconds(
      id: _notifEndId,
      secondsFromNow: remaining,
      title: 'Pomodoro: ${_sessionName(_index)} finished',
      body: 'Time for the next step!',
    );
  }

  void _nextSession() async {
    await player.play(AssetSource('sounds/pomodoro.mp3'));
    _currentCycleIndex = (_currentCycleIndex + 1) % _cycle.length;
    _index = _cycle[_currentCycleIndex];
    _sessionDurationSeconds = _sessionDurationForIndex(_index);
    _sessionStart = DateTime.now();
    _updateDisplayedRemaining();
    notifyListeners();

    // Immediate notification that the new session has started
    await NotificationService().showNow(
      id: _notifEndId + 1,
      title: 'Pomodoro: ${_sessionName(_index)} started',
      body: 'Duration: ${_durations[_index]} minutes',
    );
    NotificationService().showInAppBanner(
      title: 'Pomodoro: ${_sessionName(_index)} started',
      body: 'Duration: ${_durations[_index]} minutes',
    );

    // Schedule the end notification for this new session
    await _scheduleEndNotification();

    // Update Live Activity for the new session
    _updateLiveActivity();
    _persistState();
  }

  // Advance sessions based on how much wall-clock time has passed since _sessionStart
  void _advanceByWallClock() {
    if (_sessionStart == null) return;
    var now = DateTime.now();
    var elapsed = now.difference(_sessionStart!).inSeconds;
    var remaining = _sessionDurationSeconds - elapsed;

    while (remaining <= 0) {
      // Move to next session
      _currentCycleIndex = (_currentCycleIndex + 1) % _cycle.length;
      _index = _cycle[_currentCycleIndex];
      // Reduce elapsed by the overrun into next session
      elapsed = -remaining; // overrun seconds that spilled into next session
      _sessionDurationSeconds = _sessionDurationForIndex(_index);
      _sessionStart = now.subtract(Duration(seconds: elapsed));
      remaining = _sessionDurationSeconds - elapsed;
    }

    _updateDisplayedRemaining();
  }

  void _handleTick() {
    _advanceByWallClock();
    // Update Live Activity every 5 seconds to reduce overhead
    if (_remainingSecondsByWallClock() % 5 == 0) {
      _updateLiveActivity();
    }
    if (_remainingSecondsByWallClock() == 0) {
      // Finish current session in foreground and continue
      // Show finish notification (app is in foreground)
      NotificationService().showNow(
        id: _notifEndId + 2,
        title: 'Pomodoro: ${_sessionName(_index)} finished',
        body: 'Switching to the next session...',
      );
      NotificationService().showInAppBanner(
        title: 'Pomodoro: ${_sessionName(_index)} finished',
        body: 'Switching to the next session...',
      );
      _nextSession();
    }
    notifyListeners();
  }

  void _ensureTicker() {
    if (_timer?.isActive ?? false) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _handleTick();
    });
  }

  void start() {
    if (_isRunning) return;
    _isRunning = true;
    // Initialize wall-clock baseline
    // Check if we're resuming from a pause (sessionStart is null but we have remaining time)
    if (_sessionStart == null) {
      // Starting fresh or resuming from pause
      if (_currentSeconds > 0 && _currentSeconds < _sessionDurationForIndex(_index)) {
        // Resuming from pause - preserve the remaining time
        _sessionDurationSeconds = _currentSeconds;
      } else {
        // Starting fresh - use full duration
        _sessionDurationSeconds = _sessionDurationForIndex(_index);
      }
    } else {
      // Already had a session start time, recalculate remaining time
      _currentSeconds = _remainingSecondsByWallClock();
      _sessionDurationSeconds = _currentSeconds;
    }
    _sessionStart = DateTime.now();
    _updateDisplayedRemaining();
    // Schedule notification for when this session ends based on wall clock
    _scheduleEndNotification();
    // Start Live Activity for iOS
    _startLiveActivity();
    _ensureTicker();
    _persistState();
    notifyListeners();
  }

  void stop() {
    if (!_isRunning) return; // Prevent stopping if not running
    _isRunning = false;
    _timer?.cancel();
    // Preserve the current remaining time when pausing
    _currentSeconds = _remainingSecondsByWallClock();
    // Clear session start so we know we're paused (not running in background)
    _sessionStart = null;
    // Cancel any pending end notification
    NotificationService().cancel(_notifEndId);
    // End Live Activity when pausing
    _endLiveActivity();
    _persistState();
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
  }

  void reset() {
    _isRunning = false;
    _timer?.cancel();
    _sessionDurationSeconds = _sessionDurationForIndex(_index);
    _sessionStart = null;
    _currentSeconds = _sessionDurationSeconds;
    NotificationService().cancel(_notifEndId);
    _endLiveActivity();
    _persistState();
    notifyListeners();
  }

  void setIndex(int newIndex) {
    if (newIndex < 0 || newIndex >= _durations.length) return;
    _index = newIndex;
    reset();
    notifyListeners();
  }

  // Public method to reconcile after app resumes
  void reconcileWithWallClock() {
    if (!_isRunning) return;
    if (_sessionStart == null) {
      // Rebuild a baseline if the app lost the session start while running.
      if (_currentSeconds <= 0) {
        _currentCycleIndex = (_currentCycleIndex + 1) % _cycle.length;
        _index = _cycle[_currentCycleIndex];
        _sessionDurationSeconds = _sessionDurationForIndex(_index);
        _currentSeconds = _sessionDurationSeconds;
      } else {
        _sessionDurationSeconds = _currentSeconds;
      }
      _sessionStart = DateTime.now();
    }
    _advanceByWallClock();
    // Reschedule end notification for the updated remaining time
    NotificationService().cancel(_notifEndId);
    _scheduleEndNotification();
    _updateLiveActivity();
    _ensureTicker();
    _persistState();
    notifyListeners();
  }

  void toggleTimer() {
    if (_isRunning) {
      stop();
    } else {
      start();
    }
    notifyListeners();
  }

  // Live Activity helper methods
  void _startLiveActivity() {
    print('🔵 [Timer] Starting Live Activity from timer...');
    liveActivity.startActivity(
      sessionName: _sessionName(_index),
      totalSeconds: _sessionDurationSeconds,
      remainingSeconds: _currentSeconds,
    );
  }

  void _updateLiveActivity() {
    if (liveActivity.hasActiveActivity) {
      liveActivity.updateActivity(
        sessionName: _sessionName(_index),
        totalSeconds: _sessionDurationSeconds,
        remainingSeconds: _currentSeconds,
      );
    }
  }

  void _endLiveActivity() {
    liveActivity.endActivity();
  }
}
