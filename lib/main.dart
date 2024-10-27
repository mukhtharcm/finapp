import 'package:finapp/themes/modern_purple_theme.dart';
import 'package:finapp/themes/modern_gold_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:finapp/screens/auth_wrapper.dart';
import 'package:finapp/service_locator.dart';
import 'package:finapp/themes/classic_blue_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinApp',
      debugShowCheckedModeBanner: false,
      theme: ModernGoldTheme.lightTheme(),
      darkTheme: ModernGoldTheme.darkTheme(),
      themeMode: ThemeMode.system,
      home: const AuthWrapper(),
    );
  }
}
