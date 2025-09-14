import 'package:flutter/cupertino.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:pomodoro/routes/settings.dart';
import 'package:pomodoro/services/theme.dart';
import 'package:pomodoro/services/timer.dart';

class Timer extends StatefulWidget {
  const Timer({super.key});

  @override
  State<Timer> createState() => _TimerState();
}

class _TimerState extends State<Timer> {
  final PomodoroTimer _pomodoroTimer = PomodoroTimer();
  bool isRunning = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 20,
      children: [
        StreamBuilder<String>(
          stream: _pomodoroTimer.timeStream,
          builder: (context, snapshot) {
            return Text(
              snapshot.data ??
                  _pomodoroTimer.minutes[_pomodoroTimer.currentIndex]
                      .toStringAsFixed(2)
                      .replaceAll('.', ':'),
              style: TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.bold,
                letterSpacing: -5.0,
              ),
            );
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoButton(
              borderRadius: BorderRadius.circular(8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              color: ThemeColor().onPrimaryColor,
              mouseCursor: SystemMouseCursors.click,
              onPressed: () {
                setState(() {
                  isRunning = !isRunning;
                });
                if (isRunning) {
                  _pomodoroTimer.start();
                } else {
                  _pomodoroTimer.stop();
                }
              },
              child: isRunning
                  ? Row(
                      spacing: 4,
                      children: [
                        Icon(LucideIcons.pause, size: 14),
                        Text("stop", style: TextStyle(letterSpacing: -1.8)),
                      ],
                    )
                  : Row(
                      spacing: 4,
                      children: [
                        Icon(LucideIcons.play, size: 14),
                        Text(
                          _pomodoroTimer.isStopped ? "resume" : "play",
                          style: TextStyle(letterSpacing: -1.8),
                        ),
                      ],
                    ),
            ),
            SizedBox(width: 20),
            CupertinoButton(
              borderRadius: BorderRadius.circular(8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                  Icon(LucideIcons.settings, size: 14),
                  Text("settings", style: TextStyle(letterSpacing: -1.8)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
