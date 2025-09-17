interface class ISettings {
  List<double> durations = [25, 5, 15];
  bool darkmodeDuringRunning = false;

  ISettings({
    required this.durations,
    required this.darkmodeDuringRunning,
  });
}
