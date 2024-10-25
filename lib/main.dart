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
    // Custom color scheme
    const customSchemeColor = FlexSchemeColor(
      primary: Color(0xFF0D47A1),
      primaryContainer: Color(0xFFBBDEFB),
      secondary: Color(0xFF00796B),
      secondaryContainer: Color(0xFFB2DFDB),
      tertiary: Color(0xFFFFA000),
      tertiaryContainer: Color(0xFFFFECB3),
    );

    return MaterialApp(
      theme: FlexThemeData.light(
        colors: customSchemeColor,
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 7,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 10,
          blendOnColors: false,
          useTextTheme: true,
          useM2StyleDividerInM3: true,
          alignedDropdown: true,
          useInputDecoratorThemeInDialogs: true,
          fabUseShape: true,
          interactionEffects: true,
          bottomNavigationBarElevation: 0,
          bottomNavigationBarOpacity: 0.95,
          navigationBarOpacity: 0.95,
          navigationBarMutedUnselectedIcon: true,
          inputDecoratorIsFilled: false,
          inputDecoratorBorderType: FlexInputBorderType.outline,
          inputDecoratorUnfocusedHasBorder: true,
          blendTextTheme: true,
          popupMenuOpacity: 0.95,
          cardRadius: 12,
          defaultRadius: 8,
          textButtonRadius: 8,
          elevatedButtonRadius: 8,
          outlinedButtonRadius: 8,
          buttonMinSize: Size(64, 40),
          inputDecoratorRadius: 8,
          inputDecoratorUnfocusedBorderIsColored: false,
          inputDecoratorFocusedBorderWidth: 2.0,
          inputDecoratorBorderWidth: 1.0,
          inputDecoratorFillColor: Colors.transparent,
          fabRadius: 16,
          chipRadius: 8,
          timePickerElementRadius: 8,
          dialogRadius: 12,
        ),
        keyColors: const FlexKeyColors(
          useSecondary: true,
          useTertiary: true,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        swapLegacyOnMaterial3: true,
        fontFamily: GoogleFonts.roboto().fontFamily,
      ),
      darkTheme: FlexThemeData.dark(
        colors: customSchemeColor,
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 13,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 20,
          useTextTheme: true,
          useM2StyleDividerInM3: true,
          alignedDropdown: true,
          useInputDecoratorThemeInDialogs: true,
          fabUseShape: true,
          interactionEffects: true,
          bottomNavigationBarElevation: 0,
          bottomNavigationBarOpacity: 0.95,
          navigationBarOpacity: 0.95,
          navigationBarMutedUnselectedIcon: true,
          inputDecoratorIsFilled: false,
          inputDecoratorBorderType: FlexInputBorderType.outline,
          inputDecoratorUnfocusedHasBorder: true,
          blendTextTheme: true,
          popupMenuOpacity: 0.95,
          cardRadius: 12,
          defaultRadius: 8,
          textButtonRadius: 8,
          elevatedButtonRadius: 8,
          outlinedButtonRadius: 8,
          buttonMinSize: Size(64, 40),
          inputDecoratorRadius: 8,
          inputDecoratorUnfocusedBorderIsColored: false,
          inputDecoratorFocusedBorderWidth: 2.0,
          inputDecoratorBorderWidth: 1.0,
          inputDecoratorFillColor: Colors.transparent,
          fabRadius: 16,
          chipRadius: 8,
          timePickerElementRadius: 8,
          dialogRadius: 12,
        ),
        keyColors: const FlexKeyColors(
          useSecondary: true,
          useTertiary: true,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        swapLegacyOnMaterial3: true,
        fontFamily: GoogleFonts.roboto().fontFamily,
      ),
      themeMode: ThemeMode.system,
      home: AuthWrapper(
        authService: authService,
        financeService: financeService,
      ),
    );
  }
}
