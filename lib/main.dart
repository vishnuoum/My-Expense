import 'package:flutter/material.dart';
import 'package:my_expense/pages/home_page.dart';
import 'package:my_expense/theme.dart';
import 'package:my_expense/theme_controller.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  final ThemeController themeController = ThemeController();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeController,
      builder: (_, mode, __) {
        return MaterialApp(
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: mode,
          routes: {'/': (context) => HomePage()},
          initialRoute: "/",
        );
      },
    );
  }
}
