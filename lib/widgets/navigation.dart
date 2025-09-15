import 'package:flutter/cupertino.dart';
import 'package:pomodoro/interface/i_navigation.dart';
import 'package:pomodoro/services/provider_timer.dart';
import 'package:provider/provider.dart'; // Add this for provider access

class Navigation extends StatefulWidget {
  // Changed to StatelessWidget
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  final buttons = [
    INavigation(text: 'Pomodoro', isActive: true),
    INavigation(text: 'Short break', isActive: false),
    INavigation(text: 'Long break', isActive: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<PomodoroTimerNotifier>(
      builder: (context, timer, child) {
        for (var button in buttons) {
          button.isActive = buttons.indexOf(button) == timer.index;
        }
        return CupertinoPageScaffold(
          child: Padding(
            padding: MediaQuery.of(context).size.width > 600
                ? const EdgeInsets.only(top: 0)
                : const EdgeInsets.only(top: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var button in buttons)
                  CupertinoButton(
                    borderRadius: BorderRadius.circular(8),
                    mouseCursor: SystemMouseCursors.click,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    onPressed: () {
                      // Update button states
                      for (var b in buttons) {
                        b.isActive = false;
                      }
                      button.isActive = true;

                      // Update notifier index (0 = Pomodoro, 1 = Short, 2 = Long)
                      timer.setIndex(buttons.indexOf(button));
                    },
                    child: Column(
                      children: [
                        Text(
                          button.text,
                          style: TextStyle(
                            fontSize: 16,
                            letterSpacing: -1.8,
                            fontWeight: button.isActive
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        if (button.isActive)
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            height: 4,
                            width: 4,
                            decoration: BoxDecoration(
                              color:
                                  timer.isRunning && timer.darkmodeDuringRunning
                                  ? CupertinoColors.white
                                  : CupertinoColors.black,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
