import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

final TextStyle quickSandRegular = GoogleFonts.quicksand(fontWeight: FontWeight.w400);
final TextStyle quickSandMedium = GoogleFonts.quicksand(fontWeight: FontWeight.w500);
final TextStyle quickSandBold = GoogleFonts.quicksand(fontWeight: FontWeight.w700);

final TextTheme customQuickSandTextTheme = TextTheme(
  displayLarge: quickSandBold.copyWith(fontSize: 57), // Custom bold
  displayMedium: quickSandRegular.copyWith(fontSize: 45), // Regular is default
  displaySmall: quickSandRegular.copyWith(fontSize: 36), // Regular is default
  headlineLarge: quickSandBold.copyWith(fontSize: 32), // Regular is default
  headlineMedium: quickSandBold.copyWith(fontSize: 28), // Regular is default
  headlineSmall: quickSandBold.copyWith(fontSize: 24), // Regular is default
  titleLarge: quickSandBold.copyWith(fontSize: 20), // Custom bold (Regular is default)
  titleMedium: quickSandBold.copyWith(fontSize: 16), // Custom bold (Medium is default)
  titleSmall: quickSandBold.copyWith(fontSize: 14), // Custom bold (Medium is default)
  bodyLarge: quickSandRegular.copyWith(fontSize: 16), // Regular is default
  bodyMedium: quickSandRegular.copyWith(fontSize: 14), // Regular is default
  bodySmall: quickSandRegular.copyWith(fontSize: 12), // Regular is default
  labelLarge: quickSandBold.copyWith(fontSize: 14), // Custom bold (Medium is default)
  labelMedium: quickSandBold.copyWith(fontSize: 12), // Custom bold (Medium is default)
  labelSmall: quickSandMedium.copyWith(fontSize: 11), // Medium is default
);

const double themeBorderRadius = 8;
const _primaryColor = Color(0xFF8C001E);
const aiColors = [Colors.redAccent, Colors.pinkAccent, Colors.amberAccent, Colors.greenAccent, Colors.blueAccent];

ThemeData darkTheme = FlexThemeData.dark(
  // Input color modifiers.
  usedColors: 7,
  useMaterial3ErrorColors: true,
  // Surface color adjustments.
  darkIsTrueBlack: true,
  textTheme: customQuickSandTextTheme,
  // Component theme configurations for dark mode.
  subThemesData: const FlexSubThemesData(
    appBarBackgroundSchemeColor: SchemeColor.transparent,
    useMaterial3Typography: true,
    useM2StyleDividerInM3: true,
    defaultRadius: themeBorderRadius,
    inputDecoratorBorderType: FlexInputBorderType.outline,
    alignedDropdown: true,
    navigationRailUseIndicator: true,
    navigationRailLabelType: NavigationRailLabelType.all,
    inputDecoratorIsFilled: true,
    inputDecoratorFocusedHasBorder: true,
  ),
  // User defined custom colors made with FlexSchemeColor() API.
  colors: const FlexSchemeColor(
    primary: _primaryColor,
    primaryContainer: Color(0xFF474747),
    primaryLightRef: Color(0xFF202020), // The color of light mode primary
    secondary: Color(0xFF9C624C),
    secondaryContainer: Color(0xFF505050),
    secondaryLightRef: Color(0xFF777777), // The color of light mode secondary
    tertiary: Color(0xFFE2E2E2),
    tertiaryContainer: Color(0xFF616161),
    tertiaryLightRef: Color(0xFF454545), // The color of light mode tertiary
    appBarColor: Color(0xFFC6C6C6),
    error: Color(0xFFFFB4AB),
    errorContainer: Color(0xFF93000A),
  ),
  // Direct ThemeData properties.
  visualDensity: FlexColorScheme.comfortablePlatformDensity,
  cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
).copyWith(
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    shadowColor: Colors.transparent,
    systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(statusBarIconBrightness: Brightness.light),
  ),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: _primaryColor,
    selectionHandleColor: _primaryColor,
    selectionColor: _primaryColor.withAlpha(100),
  ),
  switchTheme: SwitchThemeData(
    trackOutlineWidth: WidgetStateProperty.all(0),
    thumbColor: WidgetStateProperty.all(Colors.white),
    trackColor: WidgetStateProperty.fromMap({
      WidgetState.selected: _primaryColor,
      WidgetState.disabled: _primaryColor.withAlpha(50),
    }),
  ),
);
