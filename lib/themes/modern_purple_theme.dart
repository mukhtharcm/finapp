import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ModernPurpleTheme {
  static const customSchemeColor = FlexSchemeColor(
    primary: Color(0xFF6200EE),
    primaryContainer: Color(0xFFBB86FC),
    secondary: Color(0xFF03DAC6),
    secondaryContainer: Color(0xFF018786),
    tertiary: Color(0xFFFF9800),
    tertiaryContainer: Color(0xFFFFE0B2),
    appBarColor: Color(0xFF6200EE),
  );

  static ThemeData lightTheme() {
    final nunitoTextTheme = GoogleFonts.nunitoTextTheme();
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
      fontFamily: GoogleFonts.nunito().fontFamily,
      textTheme: nunitoTextTheme,
    );
  }

  static ThemeData darkTheme() {
    final nunitoTextTheme = GoogleFonts.nunitoTextTheme();
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
      fontFamily: GoogleFonts.nunito().fontFamily,
      textTheme: nunitoTextTheme,
    );
  }
}
