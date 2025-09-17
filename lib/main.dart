import 'package:flutter/cupertino.dart';
import 'package:localstorage/localstorage.dart';
import 'package:pomodoro/services/provider_timer.dart';
import 'package:pomodoro/services/provider_todo.dart';
import 'package:pomodoro/services/theme.dart';
import 'package:pomodoro/widgets/navigation.dart';
import 'package:pomodoro/widgets/todo.dart';
import 'package:provider/provider.dart';

import 'widgets/timer.dart';

// --------------------------------
// Add localstorage package
// Check if localstorage has data
// If yes, load data into ProviderTodo
// If no, initialize with empty list
// --------------------------------

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initLocalStorage();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PomodoroTimerNotifier()),
        ChangeNotifierProvider(create: (_) => ProviderTodo()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      theme:
          Provider.of<PomodoroTimerNotifier>(context).darkmodeDuringRunning ==
                  true &&
              Provider.of<PomodoroTimerNotifier>(context).isRunning
          ? ThemeColor.dark()
          : ThemeColor(),
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
                spacing: 20,
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
