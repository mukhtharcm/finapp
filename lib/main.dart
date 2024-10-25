import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:finapp/screens/auth_wrapper.dart';
import 'package:finapp/services/auth_service.dart';
import 'package:finapp/services/finance_service.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set up AuthStore
  const storage = FlutterSecureStorage();
  final authData = await storage.read(key: 'pb_auth');

  final authStore = AsyncAuthStore(
    save: (String data) async =>
        await storage.write(key: 'pb_auth', value: data),
    initial: authData,
  );

  // Initialize PocketBase with the AuthStore
  final pb = PocketBase(
    'http://localhost:8090',
    authStore: authStore,
  );

  // Initialize services
  final authService = AuthService(pb);
  final financeService = FinanceService(pb);

  await financeService.initialize();

  runApp(MainApp(authService: authService, financeService: financeService));
}

class MainApp extends StatelessWidget {
  final AuthService authService;
  final FinanceService financeService;

  const MainApp({
    super.key,
    required this.authService,
    required this.financeService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: FlexThemeData.light(
        scheme: FlexScheme.purpleBrown,
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 9,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 10,
          blendOnColors: false,
          useTextTheme: true,
          useM2StyleDividerInM3: true,
          alignedDropdown: true,
          useInputDecoratorThemeInDialogs: true,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        swapLegacyOnMaterial3: true,
        fontFamily: GoogleFonts.nunito().fontFamily,
      ),
      darkTheme: FlexThemeData.dark(
        scheme: FlexScheme.purpleBrown,
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 15,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 20,
          useTextTheme: true,
          useM2StyleDividerInM3: true,
          alignedDropdown: true,
          useInputDecoratorThemeInDialogs: true,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        swapLegacyOnMaterial3: true,
        fontFamily: GoogleFonts.nunito().fontFamily,
      ),
      themeMode: ThemeMode.system,
      home: AuthWrapper(
        authService: authService,
        financeService: financeService,
      ),
    );
  }
}
