import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ModernGreenTheme {
  static const customSchemeColor = FlexSchemeColor(
    primary: Color(0xFF2E7D32), // Deep green
    primaryContainer: Color(0xFFB9F6CA), // Light mint
    secondary: Color(0xFF00796B), // Teal
    secondaryContainer: Color(0xFFB2DFDB), // Light teal
    tertiary: Color(0xFFFFA000), // Amber
    tertiaryContainer: Color(0xFFFFECB3), // Light amber
  );

  static ThemeData lightTheme() {
    final poppinsTextTheme = GoogleFonts.poppinsTextTheme();
    return FlexThemeData.light(
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
      fontFamily: GoogleFonts.poppins().fontFamily,
      textTheme: poppinsTextTheme,
    );
  }

  static ThemeData darkTheme() {
    final poppinsTextTheme = GoogleFonts.poppinsTextTheme();
    return FlexThemeData.dark(
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
      fontFamily: GoogleFonts.poppins().fontFamily,
      textTheme: poppinsTextTheme,
    );
  }
}
