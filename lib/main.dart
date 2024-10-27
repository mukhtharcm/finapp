import 'dart:io';

import 'package:finapp/themes/modern_purple_theme.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:finapp/screens/auth_wrapper.dart';
import 'package:finapp/services/auth_service.dart';
import 'package:finapp/services/finance_service.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
      theme: kDebugMode
          ? ModernPurpleTheme.lightTheme()
          : ClassicBlueTheme.lightTheme(),
      darkTheme: kDebugMode
          ? ModernPurpleTheme.darkTheme()
          : ClassicBlueTheme.darkTheme(),
      themeMode: ThemeMode.system,
      home: const AuthWrapper(),
    );
  }
}
