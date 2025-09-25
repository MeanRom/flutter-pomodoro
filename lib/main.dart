import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:localstorage/localstorage.dart';
import 'package:pomodoro/services/provider_timer.dart';
import 'package:pomodoro/services/provider_todo.dart';
import 'package:pomodoro/services/theme.dart';
import 'package:pomodoro/widgets/navigation.dart';
import 'package:pomodoro/widgets/todo.dart';
import 'package:provider/provider.dart';

import 'widgets/timer.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initLocalStorage();
  await NotificationService().init();

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

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<StatefulWidget> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with WidgetsBindingObserver {
  bool _onKeyEvent(KeyEvent event) {
    // If a text field is focused, let it handle the key (e.g., typing a space)
    final focusedNode = FocusManager.instance.primaryFocus;
    final isEditing =
        focusedNode?.context?.widget is CupertinoTextField ||
        focusedNode?.context
                ?.findAncestorWidgetOfExactType<CupertinoTextField>() !=
            null;

    if (isEditing) {
      return false; // do not intercept; allow input to handle the key
    }

    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.space) {
      context.read<PomodoroTimerNotifier>().toggleTimer();
      return true; // handled
    }
    return false; // not handled
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    HardwareKeyboard.instance.addHandler(_onKeyEvent);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    HardwareKeyboard.instance.removeHandler(_onKeyEvent);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Reconcile timer with wall clock when coming back to foreground
      try {
        context.read<PomodoroTimerNotifier>().reconcileWithWallClock();
      } catch (_) {}
    }
    super.didChangeAppLifecycleState(state);
  }

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
