import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ValueNotifier<ThemeMode> {
  static const _themeKey = 'theme_mode';

  ThemeController() : super(ThemeMode.dark) {
    _loadTheme(); // load from SharedPreferences
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getString(_themeKey) ?? 'dark';

    if (mode == 'light') {
      value = ThemeMode.light;
    } else {
      value = ThemeMode.dark;
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    value = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.name);
  }

  void toggleTheme() {
    value = value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    setTheme(value);
  }
}
