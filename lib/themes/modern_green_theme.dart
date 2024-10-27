import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ModernGreenTheme {
  static const customSchemeColor = FlexSchemeColor(
    primary: Color(0xFF2E7D32),
    primaryContainer: Color(0xFFA5D6A7),
    secondary: Color(0xFF00796B),
    secondaryContainer: Color(0xFFB2DFDB),
    tertiary: Color(0xFFFFA000),
    tertiaryContainer: Color(0xFFFFECB3),
    appBarColor: Color(0xFF2E7D32),
  );

  static ThemeData lightTheme() {
    final poppinsTextTheme = GoogleFonts.poppinsTextTheme();
    return FlexThemeData.light(
      colors: customSchemeColor,
      surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
      blendLevel: 20,
      appBarOpacity: 0.95,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 20,
        blendOnColors: false,
        useTextTheme: true,
        useM2StyleDividerInM3: true,
        alignedDropdown: true,
        useInputDecoratorThemeInDialogs: true,
        fabUseShape: true,
        interactionEffects: true,
        bottomNavigationBarElevation: 0,
        bottomNavigationBarOpacity: 1,
        navigationBarOpacity: 1,
        navigationBarMutedUnselectedIcon: true,
        inputDecoratorIsFilled: false,
        inputDecoratorBorderType: FlexInputBorderType.outline,
        inputDecoratorUnfocusedHasBorder: true,
        blendTextTheme: true,
        popupMenuOpacity: 0.95,
        cardRadius: 20,
        defaultRadius: 16,
        textButtonRadius: 12,
        elevatedButtonRadius: 12,
        outlinedButtonRadius: 12,
        buttonMinSize: Size(64, 40),
        inputDecoratorRadius: 12,
        chipRadius: 20,
        timePickerElementRadius: 12,
        dialogRadius: 24,
      ),
      keyColors: const FlexKeyColors(
        useSecondary: true,
        useTertiary: true,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
      fontFamily: GoogleFonts.poppins().fontFamily,
      textTheme: poppinsTextTheme,
    );
  }

  static ThemeData darkTheme() {
    final poppinsTextTheme = GoogleFonts.poppinsTextTheme();
    return FlexThemeData.dark(
      colors: customSchemeColor,
      surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
      blendLevel: 15,
      appBarStyle: FlexAppBarStyle.background,
      appBarOpacity: 0.90,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 30,
        useTextTheme: true,
        useM2StyleDividerInM3: true,
        alignedDropdown: true,
        useInputDecoratorThemeInDialogs: true,
        fabUseShape: true,
        interactionEffects: true,
        bottomNavigationBarElevation: 0,
        bottomNavigationBarOpacity: 1,
        navigationBarOpacity: 1,
        navigationBarMutedUnselectedIcon: true,
        inputDecoratorIsFilled: false,
        inputDecoratorBorderType: FlexInputBorderType.outline,
        inputDecoratorUnfocusedHasBorder: true,
        blendTextTheme: true,
        popupMenuOpacity: 0.95,
        cardRadius: 20,
        defaultRadius: 16,
        textButtonRadius: 12,
        elevatedButtonRadius: 12,
        outlinedButtonRadius: 12,
        buttonMinSize: Size(64, 40),
        inputDecoratorRadius: 12,
        chipRadius: 20,
        timePickerElementRadius: 12,
        dialogRadius: 24,
      ),
      keyColors: const FlexKeyColors(
        useSecondary: true,
        useTertiary: true,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
      fontFamily: GoogleFonts.poppins().fontFamily,
      textTheme: poppinsTextTheme,
    );
  }
}
