part of 'theme_bloc.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object> get props => [];
}

class ChangeTheme extends ThemeEvent {
  final String theme;

  const ChangeTheme(this.theme);

  @override
  List<Object> get props => [theme];
}

class ChangeThemeMode extends ThemeEvent {
  final ThemeMode themeMode;

  const ChangeThemeMode(this.themeMode);

  @override
  List<Object> get props => [themeMode];
}
