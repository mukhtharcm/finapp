import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:finapp/services/theme_service.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final ThemeService themeService;

  ThemeBloc({required this.themeService})
      : super(ThemeState(
          currentTheme: themeService.currentTheme,
          themeMode: themeService.themeMode,
        )) {
    on<ChangeTheme>(_onChangeTheme);
    on<ChangeThemeMode>(_onChangeThemeMode);
  }

  Future<void> _onChangeTheme(
    ChangeTheme event,
    Emitter<ThemeState> emit,
  ) async {
    if (themeService.availableThemes.contains(event.theme)) {
      await themeService.setTheme(event.theme);
      emit(state.copyWith(currentTheme: event.theme));
    }
  }

  Future<void> _onChangeThemeMode(
    ChangeThemeMode event,
    Emitter<ThemeState> emit,
  ) async {
    await themeService.setThemeMode(event.themeMode);
    emit(state.copyWith(themeMode: event.themeMode));
  }
}
