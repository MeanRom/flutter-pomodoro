import 'package:flutter/cupertino.dart';

class ThemeColor extends CupertinoThemeData {
  @override
  Color primaryColor = Color(0xFF191919);
  Color secondaryColor = Color(0xFF03DAC6);
  Color backgroundColor = Color(0xFFFFFFFF);
  Color surfaceColor = Color(0xFFFFFFFF);
  Color errorColor = Color(0xFFB00020);
  Color onPrimaryColor = Color(0xFF46DE7F);
  Color onSecondaryColor = Color(0xFFF3F3F3);
  Color onBackgroundColor = Color(0xFF000000);
  Color onSurfaceColor = Color(0xFF000000);
  Color onErrorColor = Color(0xFFFFFFFF);

  ThemeColor()
    : super(primaryColor: Color(0xFF191919), brightness: Brightness.light);
}
