import 'package:live_activities/live_activities.dart';

class LiveActivityService {
  static final LiveActivityService _instance = LiveActivityService._internal();
  factory LiveActivityService() => _instance;
  LiveActivityService._internal();

  final _liveActivitiesPlugin = LiveActivities();
  String? _activityId;

  /// Initialize Live Activities plugin
  Future<void> init() async {
    // Initialize the plugin if needed
    // The plugin handles iOS version checks internally
  }

  /// Start a new Live Activity for the pomodoro timer
  Future<void> startActivity({
    required String sessionName,
    required int totalSeconds,
    required int remainingSeconds,
  }) async {
    try {
      print('🟢 [LiveActivity] Attempting to start activity...');
      print('🟢 [LiveActivity] Session: $sessionName, Total: $totalSeconds, Remaining: $remainingSeconds');

      // End any existing activity first
      await endActivity();

      // Calculate end timestamp
      final endTime = DateTime.now().add(Duration(seconds: remainingSeconds));

      // Create activity data
      final activityData = {
        'sessionName': sessionName,
        'totalSeconds': totalSeconds,
        'remainingSeconds': remainingSeconds,
        'endTimestamp': endTime.millisecondsSinceEpoch ~/ 1000,
      };

      print('🟢 [LiveActivity] Activity data: $activityData');

      // Start the Live Activity
      _activityId = await _liveActivitiesPlugin.createActivity(activityData);

      print('🟢 [LiveActivity] Activity created with ID: $_activityId');
    } catch (e, stackTrace) {
      // Live Activities might not be supported on this device/iOS version
      // Fail silently as this is an optional feature
      print('🔴 [LiveActivity] Failed to start Live Activity: $e');
      print('🔴 [LiveActivity] Stack trace: $stackTrace');
    }
  }

  /// Update an existing Live Activity
  Future<void> updateActivity({
    required String sessionName,
    required int totalSeconds,
    required int remainingSeconds,
  }) async {
    if (_activityId == null) return;

    try {
      final endTime = DateTime.now().add(Duration(seconds: remainingSeconds));

      final activityData = {
        'sessionName': sessionName,
        'totalSeconds': totalSeconds,
        'remainingSeconds': remainingSeconds,
        'endTimestamp': endTime.millisecondsSinceEpoch ~/ 1000,
      };

      await _liveActivitiesPlugin.updateActivity(_activityId!, activityData);
    } catch (e) {
      print('Failed to update Live Activity: $e');
    }
  }

  /// End the current Live Activity
  Future<void> endActivity() async {
    if (_activityId == null) return;

    try {
      await _liveActivitiesPlugin.endActivity(_activityId!);
      _activityId = null;
    } catch (e) {
      print('Failed to end Live Activity: $e');
    }
  }

  /// Check if Live Activities are enabled on the device
  Future<bool> areActivitiesEnabled() async {
    try {
      return await _liveActivitiesPlugin.areActivitiesEnabled();
    } catch (e) {
      return false;
    }
  }

  /// Get the current activity ID
  String? get currentActivityId => _activityId;

  /// Check if there's an active activity
  bool get hasActiveActivity => _activityId != null;
}
