import 'package:flutter/cupertino.dart';
import 'package:pomodoro/services/provider_timer.dart';
import 'package:pomodoro/services/theme.dart';
import 'package:pomodoro/widgets/navigation.dart';
import 'package:pomodoro/widgets/todo.dart';
import 'package:provider/provider.dart';

import 'widgets/timer.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => PomodoroTimerNotifier(),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      theme: ThemeColor(),
      debugShowCheckedModeBanner: false,
      home: CupertinoPageScaffold(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32.0),
          child: Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width > 600
                  ? 500
                  : MediaQuery.of(context).size.width * 0.9,
              child: Column(
                spacing: 48,
                children: [
                  Navigation(),
                  Center(child: Timer()),
                  Todo(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
