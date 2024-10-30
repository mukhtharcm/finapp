part of 'theme_bloc.dart';

class ThemeState extends Equatable {
  final String currentTheme;
  final ThemeMode themeMode;

  const ThemeState({
    required this.currentTheme,
    required this.themeMode,
  });

  ThemeState copyWith({
    String? currentTheme,
    ThemeMode? themeMode,
  }) {
    return ThemeState(
      currentTheme: currentTheme ?? this.currentTheme,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  List<Object> get props => [currentTheme, themeMode];
}
