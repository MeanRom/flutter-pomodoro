import 'dart:math';

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
  List<String> _breakSentences = [
    "Time to stretch those legs — your chair will miss you 🪑",
    "Coffee break or code break? Why not both ☕️",
    "Your brain called — it needs a quick reboot 🧠",
    "Take five and let your thoughts compile 🧩",
    "Hydration check! Grab that water bottle 💧",
    "Step away from the keyboard… it’ll still be here when you get back ⌨️",
    "A little walk now prevents big bugs later 🚶‍♂️",
    "Snack detected: proceed to kitchen protocol 🍪",
    "Time to give your eyes a screen vacation 🕶️",
    "Stretch like no one’s watching 🤸‍♀️",
    "Let the ideas simmer while you chill 🍵",
    "Debug your mind with a deep breath 🌿",
    "You’ve earned a scroll through memes 📱",
    "Recharge mode: ON ⚡️",
    "Even superheroes need a snack break 🦸‍♂️",
    "Take a break before the code takes one for you 😴",
    "Look away from the monitor, admire the real world 🌈",
    "Snack now, fix bugs later 🍫",
    "Do you think you could finish a marathon during your break? 👀",
    "You’re not lazy — you’re just loading new ideas 💭",
  ];

  String sentence = "";

  String _resetSentence() {
    sentence = "";
    return sentence;
  }

  String _randomBreakSentence() {
    if (sentence.isEmpty) {
      sentence = _breakSentences[Random().nextInt(_breakSentences.length)];
    }
    return sentence;
  }

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
          Padding(
            padding: timer.isBreak
                ? const EdgeInsets.symmetric(vertical: 26.0)
                : EdgeInsets.zero,
            child: Text(
              timer.isBreak ? _randomBreakSentence() : _resetSentence(),
              style: TextStyle(color: ThemeColor().secondaryColor),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
