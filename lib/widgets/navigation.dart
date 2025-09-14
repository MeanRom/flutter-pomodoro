import 'package:flutter/cupertino.dart';
import 'package:pomodoro/interface/i_navigation.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  List<INavigation> buttons = [
    INavigation(text: 'Pomodoro', isActive: true),
    INavigation(text: 'Short break', isActive: false),
    INavigation(text: 'Long break', isActive: false),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          for (var button in buttons)
            CupertinoButton(
              borderRadius: BorderRadius.circular(8),
              mouseCursor: SystemMouseCursors.click,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              onPressed: () {
                setState(() {
                  for (var b in buttons) {
                    b.isActive = false;
                  }
                  button.isActive = true;
                });
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
                        color: CupertinoColors.black,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
