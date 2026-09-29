import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _themeModePrefKey = 'theme_mode';

final Provider<SharedPreferences?> sharedPreferencesProvider = Provider<SharedPreferences?>((Ref ref) {
  return null;
});

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final SharedPreferences? prefs = ref.watch(sharedPreferencesProvider);
    if (prefs == null) {
      return ThemeMode.system;
    }
    final String? saved = prefs.getString(_themeModePrefKey);
    return _parseThemeMode(saved);
  }

  static ThemeMode parseThemeMode(String? value) => _parseThemeMode(value);

  static String themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  static ThemeMode _parseThemeMode(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final SharedPreferences prefs = ref.read(sharedPreferencesProvider) ?? await SharedPreferences.getInstance();
    await prefs.setString(_themeModePrefKey, themeModeToString(mode));
  }
}

final NotifierProvider<ThemeModeNotifier, ThemeMode> themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
