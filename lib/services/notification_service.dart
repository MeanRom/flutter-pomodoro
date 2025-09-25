
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _fln =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    // Timezone initialization for zoned scheduling
    tz.initializeTimeZones();
    final String timeZoneName = tz.local.name; // Default local
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings darwinInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
      macOS: darwinInit,
    );

    await _fln.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {},
    );

    // Request permissions where applicable
    await _fln
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    await _fln
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    _initialized = true;
  }

  NotificationDetails _defaultDetails() {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'pomodoro_channel',
      'Pomodoro Notifications',
      channelDescription: 'Alerts when a session starts/ends',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const DarwinNotificationDetails darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return const NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );
  }

  Future<void> showNow({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await _fln.show(id, title, body, _defaultDetails(), payload: payload);
  }

  Future<void> scheduleInSeconds({
    required int id,
    required int secondsFromNow,
    required String title,
    required String body,
    String? payload,
  }) async {
    // Ensure we always schedule in the future (iOS requires strictly future time)
    final now = tz.TZDateTime.now(tz.local);
    int safeSeconds = secondsFromNow;
    if (safeSeconds <= 0) safeSeconds = 1;
    var scheduled = now.add(Duration(seconds: safeSeconds));
    if (!scheduled.isAfter(now)) {
      scheduled = now.add(const Duration(seconds: 1));
    }

    try {
      await _fln.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        _defaultDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );
    } catch (e) {
      // As a safe fallback, show immediately rather than throwing
      await showNow(id: id, title: title, body: body, payload: payload);
    }
  }

  Future<void> cancelAll() async {
    await _fln.cancelAll();
  }

  Future<void> cancel(int id) async {
    await _fln.cancel(id);
  }
}
