import 'package:flutter/cupertino.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:pomodoro/services/provider_timer.dart';
import 'package:pomodoro/services/theme.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<PomodoroTimerNotifier>(
      builder: (context, timer, child) {
        final TextEditingController pomodoroController = TextEditingController(
          text: timer.durations[0].toInt().toString(),
        );
        final TextEditingController shortBreakController =
            TextEditingController(text: timer.durations[1].toInt().toString());
        final TextEditingController longBreakController = TextEditingController(
          text: timer.durations[2].toInt().toString(),
        );
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            automaticallyImplyLeading: false,
            middle: Row(
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  mouseCursor: SystemMouseCursors.click,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Icon(LucideIcons.arrowLeft, size: 20),
                ),
                Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -2,
                  ),
                ),
              ],
            ),
          ),
          child: Padding(
            padding: MediaQuery.of(context).size.width > 600
                ? const EdgeInsets.only(top: 60)
                : const EdgeInsets.only(top: 142.0),
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width > 600
                    ? 500
                    : MediaQuery.of(context).size.width * 0.9,
                child: Column(
                  spacing: 32,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            'Timer',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -2,
                            ),
                          ),
                        ),
                        CupertinoFormRow(
                          prefix: Text('Pomodoro'),
                          child: SizedBox(
                            width: 80,
                            child: CupertinoTextField.borderless(
                              controller: pomodoroController,
                              keyboardType: TextInputType.number,
                              placeholder: 25.toStringAsFixed(0),
                              onChanged: (value) {
                                final newValue = double.tryParse(value);
                                if (newValue != null && newValue > 0) {
                                  timer.durations[0] = newValue;
                                }
                              },
                              textAlign: TextAlign.right,
                              suffix: Text('min'),
                            ),
                          ),
                        ),
                        CupertinoFormRow(
                          prefix: Text('Short Break'),
                          child: SizedBox(
                            width: 80,
                            child: CupertinoTextField.borderless(
                              controller: shortBreakController,
                              keyboardType: TextInputType.number,
                              placeholder: 5.toStringAsFixed(0),
                              onChanged: (value) {
                                final newValue = double.tryParse(value);
                                if (newValue != null && newValue > 0) {
                                  timer.durations[1] = newValue;
                                }
                              },
                              onSubmitted: (value) => timer.notifyListeners(),
                              textAlign: TextAlign.right,
                              suffix: Text('min'),
                            ),
                          ),
                        ),
                        CupertinoFormRow(
                          prefix: Text('Long Break'),
                          child: SizedBox(
                            width: 80,
                            child: CupertinoTextField.borderless(
                              controller: longBreakController,
                              keyboardType: TextInputType.number,
                              placeholder: 15.toStringAsFixed(0),
                              onChanged: (value) {
                                final newValue = double.tryParse(value);
                                if (newValue != null && newValue > 0) {
                                  timer.durations[2] = newValue;
                                }
                              },
                              onSubmitted: (value) => timer.notifyListeners(),
                              textAlign: TextAlign.right,
                              suffix: Text('min'),
                            ),
                          ),
                        ),
                        CupertinoButton(
                          borderRadius: BorderRadius.circular(8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          color: ThemeColor().onPrimaryColor,
                          mouseCursor: SystemMouseCursors.click,
                          child: SizedBox(
                            width: 55,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              spacing: 4,
                              children: const [
                                Icon(LucideIcons.save, size: 14),
                                Text(
                                  "save",
                                  style: TextStyle(letterSpacing: -1.8),
                                ),
                              ],
                            ),
                          ),
                          onPressed: () {
                            timer.notifyListeners();
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Personalization',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -2,
                                ),
                              ),
                              Text(
                                'Experimental',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: ThemeColor().accentColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        CupertinoFormRow(
                          prefix: Text('Dark Mode'),
                          helper: Text(
                            'Enable dark mode during Pomodoro sessions',
                            style: TextStyle(fontSize: 12),
                          ),
                          child: CupertinoSwitch(
                            value: timer.darkmodeDuringRunning,
                            onChanged: (value) {
                              timer.updateDarkmodeDuringRunning(value);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
