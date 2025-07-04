import 'package:flutter/material.dart';
import 'package:my_expense/pages/add_card_page.dart';
import 'package:my_expense/pages/home_page.dart';
import 'package:my_expense/pages/init.dart';
import 'package:my_expense/services/db_service.dart';
import 'package:my_expense/theme.dart';
import 'package:my_expense/theme_controller.dart';

void main() {
  runApp(App());
}

final ThemeController themeController = ThemeController();
final DBService dbService = DBService();

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeController,
      builder: (_, mode, __) {
        return MaterialApp(
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: mode,
          routes: {
            '/addCard': (context) => AddCardPage(),
            '/home': (context) => HomePage(),
            "/": (context) => InitPage(),
          },
          initialRoute: "/",
        );
      },
    );
  }
}
