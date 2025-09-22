import 'package:flutter/cupertino.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:pomodoro/routes/settings.dart';
import 'package:pomodoro/services/provider_timer.dart';
import 'package:pomodoro/services/theme.dart';
import 'package:provider/provider.dart'; // Add this import for provider

class Timer extends StatefulWidget {
  // Changed to StatefulWidget
  const Timer({super.key});

  @override
  State<Timer> createState() => _TimerState();
}

class _TimerState extends State<Timer> {
  @override
  Widget build(BuildContext context) {
    return Consumer<PomodoroTimerNotifier>(
      // Use Consumer to listen to notifier
      builder: (context, timer, child) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 20,
        children: [
          Text(
            timer.timeString, // Use notifier's timeString
            style: const TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.bold,
              letterSpacing: -5.0,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CupertinoButton(
                borderRadius: BorderRadius.circular(8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                color: ThemeColor().onPrimaryColor,
                mouseCursor: SystemMouseCursors.click,
                onPressed: () {
                  if (timer.isRunning) {
                    timer.stop(); // Use notifier's stop
                  } else {
                    timer.start(); // Use notifier's start
                  }
                },
                child: timer.isRunning
                    ? Row(
                        spacing: 4,
                        children: [
                          Icon(
                            LucideIcons.pause,
                            size: 14,
                            color: ThemeColor().secondaryColor,
                          ),
                          Text(
                            "stop",
                            style: TextStyle(
                              letterSpacing: -1.8,
                              color: ThemeColor().secondaryColor,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        spacing: 4,
                        children: [
                          Icon(LucideIcons.play, size: 14),
                          Text(
                            "play",
                            style: TextStyle(
                              letterSpacing: -1.8,
                              color: ThemeColor().secondaryColor,
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(width: 20),
              CupertinoButton(
                borderRadius: BorderRadius.circular(8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                color: ThemeColor().onSecondaryColor,
                mouseCursor: SystemMouseCursors.click,
                onPressed: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (context) => SettingsPage()),
                  );
                },
                child: Row(
                  spacing: 4,
                  children: [
                    Icon(
                      LucideIcons.settings,
                      size: 14,
                      color: ThemeColor().secondaryColor,
                    ),
                    Text(
                      "settings",
                      style: TextStyle(
                        letterSpacing: -1.8,
                        color: ThemeColor().secondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
