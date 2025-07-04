import 'package:flutter/material.dart';
import 'package:my_expense/main.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.fromLTRB(10, 30, 10, 0),
          children: [
            Text(
              "Settings",
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ListTile(
              isThreeLine: false,
              title: Text("Enable Dark Mode", style: TextStyle(fontSize: 17)),
              trailing: Transform.scale(
                scale: 0.8,
                child: ValueListenableBuilder<ThemeMode>(
                  valueListenable: themeController,
                  builder: (_, mode, __) {
                    bool themeToggle = mode == ThemeMode.dark;
                    return Switch(
                      value: themeToggle,
                      onChanged: (flag) {
                        setState(() {
                          themeToggle = !themeToggle;
                        });
                        themeController.toggleTheme();
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
