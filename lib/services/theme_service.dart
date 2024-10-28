import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals.dart';

class ThemeService {
  static const String _themeKey = 'selected_theme';
  static const String _themeModeKey = 'theme_mode';
  final SharedPreferences _prefs;

  ThemeService(this._prefs) {
    // Initialize currentTheme
    final savedTheme = _prefs.getString(_themeKey);
    if (savedTheme != null && availableThemes.contains(savedTheme)) {
      currentTheme.value = savedTheme;
    } else {
      currentTheme.value = 'Ocean'; // Default theme
    }

    // Initialize themeMode
    final savedThemeMode = _prefs.getString(_themeModeKey);
    if (savedThemeMode != null) {
      themeMode.value = ThemeMode.values.firstWhere(
        (mode) => mode.toString() == savedThemeMode,
        orElse: () => ThemeMode.system,
      );
    }
  }

  final currentTheme = signal<String>('Ocean');
  final themeMode = signal<ThemeMode>(ThemeMode.system);

  final availableThemes = [
    'Ocean', // Classic Blue
    'Lavender', // Modern Purple
    'Sunset', // Modern Gold
    'Forest' // Modern Green
  ];

  Future<void> setTheme(String theme) async {
    if (availableThemes.contains(theme)) {
      currentTheme.value = theme;
      await _prefs.setString(_themeKey, theme);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    await _prefs.setString(_themeModeKey, mode.toString());
  }

  String getThemeModeString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }
}
