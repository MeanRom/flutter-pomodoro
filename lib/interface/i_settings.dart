interface class ISettings {
  List<double> durations = [25, 5, 15];
  bool darkmodeDuringRunning = false;

  ISettings({required this.durations, required this.darkmodeDuringRunning});

  static ISettings fromJson(jsonDecode) {
    return ISettings(
      durations: List<double>.from(jsonDecode['durations'] ?? [25, 5, 15]),
      darkmodeDuringRunning: jsonDecode['darkmodeDuringRunning'] ?? false,
    );
  }
}
