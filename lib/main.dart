import 'package:finapp/themes/classic_blue_theme.dart';
import 'package:finapp/themes/modern_gold_theme.dart';
import 'package:finapp/themes/modern_green_theme.dart';
import 'package:finapp/themes/modern_purple_theme.dart';
import 'package:flutter/material.dart';
import 'package:finapp/screens/auth_wrapper.dart';
import 'package:finapp/service_locator.dart';
import 'package:finapp/services/theme_service.dart';
import 'package:finapp/blocs/theme/theme_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = GetIt.instance<ThemeService>();

    return BlocProvider(
      create: (context) => ThemeBloc(themeService: themeService),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'FinApp',
            debugShowCheckedModeBanner: false,
            theme: _getThemeData(state.currentTheme, false),
            darkTheme: _getThemeData(state.currentTheme, true),
            themeMode: state.themeMode,
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }

  ThemeData _getThemeData(String themeName, bool isDark) {
    switch (themeName) {
      case 'Ocean':
        return isDark
            ? ClassicBlueTheme.darkTheme()
            : ClassicBlueTheme.lightTheme();
      case 'Lavender':
        return isDark
            ? ModernPurpleTheme.darkTheme()
            : ModernPurpleTheme.lightTheme();
      case 'Sunset':
        return isDark
            ? ModernGoldTheme.darkTheme()
            : ModernGoldTheme.lightTheme();
      case 'Forest':
        return isDark
            ? ModernGreenTheme.darkTheme()
            : ModernGreenTheme.lightTheme();
      default:
        return isDark
            ? ClassicBlueTheme.darkTheme()
            : ClassicBlueTheme.lightTheme();
    }
  }
}
