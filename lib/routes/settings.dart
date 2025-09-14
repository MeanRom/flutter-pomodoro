import 'package:flutter/cupertino.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
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
            SizedBox(width: 8),
            Text(
              'Settings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      child: Center(child: Text('Settings Page Content')),
    );
  }
}
