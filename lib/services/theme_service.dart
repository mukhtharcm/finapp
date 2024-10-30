import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _themeKey = 'selected_theme';
  static const String _themeModeKey = 'theme_mode';
  final SharedPreferences _prefs;

  String _currentTheme = 'Ocean';
  ThemeMode _themeMode = ThemeMode.system;

  ThemeService(this._prefs) {
    // Initialize currentTheme
    final savedTheme = _prefs.getString(_themeKey);
    if (savedTheme != null && availableThemes.contains(savedTheme)) {
      _currentTheme = savedTheme;
    }

    // Initialize themeMode
    final savedThemeMode = _prefs.getString(_themeModeKey);
    if (savedThemeMode != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (mode) => mode.toString() == savedThemeMode,
        orElse: () => ThemeMode.system,
      );
    }
  }

  String get currentTheme => _currentTheme;
  ThemeMode get themeMode => _themeMode;

  final availableThemes = [
    'Ocean', // Classic Blue
    'Lavender', // Modern Purple
    'Sunset', // Modern Gold
    'Forest' // Modern Green
  ];

  Future<void> setTheme(String theme) async {
    if (availableThemes.contains(theme)) {
      _currentTheme = theme;
      await _prefs.setString(_themeKey, theme);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
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
