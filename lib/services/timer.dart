import "dart:async";

class PomodoroTimer {
  List<double> minutes = [25, 5, 15];
  int currentIndex = 0;
  bool isRunning = false;
  bool isStopped = false;
  int currentCountdown = 0;
  Timer? _timer;

  final _timerController = StreamController<int>.broadcast();
  Stream<int> get timerStream => _timerController.stream;

  PomodoroTimer({List<double>? initialMinutes}) {
    if (initialMinutes != null) {
      minutes = initialMinutes;
    }
  }
  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Stream<String> get timeStream =>
      timerStream.map((seconds) => _formatTime(seconds));

  void start() {
    if (isStopped) {
      isStopped = false;
    } else {
      currentCountdown = (minutes[currentIndex] * 60).toInt();
      _timerController.add(currentCountdown);
    }
    if (isRunning) return;
    isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (currentCountdown > 0) {
        currentCountdown--;
        _timerController.add(currentCountdown);
      } else {
        stop();
        currentIndex = (currentIndex + 1) % minutes.length;
      }
    });
  }

  void stop() {
    if (!isRunning) return;
    isRunning = false;
    _timer?.cancel();
    _timer = null;
    isStopped = true;
  }

  void reset() {
    stop();
    currentIndex = 0;
    isStopped = false;
    isRunning = false;
    currentCountdown = (minutes[currentIndex] * 60).toInt();
    _timerController.add(currentCountdown);
    _formatTime(currentCountdown);
  }
}
