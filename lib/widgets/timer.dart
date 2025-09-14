import 'package:flutter/cupertino.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:pomodoro/routes/settings.dart';
import 'package:pomodoro/services/theme.dart';

class Timer extends StatefulWidget {
  const Timer({super.key});

  @override
  State<Timer> createState() => _TimerState();
}

class _TimerState extends State<Timer> {
  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 20,
      children: [
        Text(
          "00:00",
          style: TextStyle(
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              color: ThemeColor().onPrimaryColor,
              mouseCursor: SystemMouseCursors.click,
              onPressed: () {},
              child: Row(
                spacing: 4,
                children: [
                  Icon(LucideIcons.play, size: 14),
                  Text("play", style: TextStyle(letterSpacing: -1.8)),
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
