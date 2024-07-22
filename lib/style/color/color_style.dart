import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ColorStyle {
  static void setSystemStylePref() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemStatusBarContrastEnforced: true,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  }

  static const Map<int, Color> customSwatchColor = {
    50: Color.fromRGBO(255, 255, 255, 0.1),
    100: Color.fromRGBO(255, 255, 255, 0.2),
    200: Color.fromRGBO(255, 255, 255, 0.3),
    300: Color.fromRGBO(255, 255, 255, 0.4),
    400: Color.fromRGBO(255, 255, 255, 0.5),
    500: Color.fromRGBO(255, 255, 255, 0.6),
    600: Color.fromRGBO(255, 255, 255, 0.7),
    700: Color.fromRGBO(255, 255, 255, 0.8),
    800: Color.fromRGBO(255, 255, 255, 0.9),
    900: Color.fromRGBO(255, 255, 255, 1),
  };

  static MaterialColor primaryMaterialColor =
      const MaterialColor(0xFFFFFFFF, customSwatchColor);

  static const ColorScheme appScheme = ColorScheme(
    brightness: Brightness.light,
    background: ColorStyle.backgroundColor,
    primary: ColorStyle.primaryColor,
    onPrimary: ColorStyle.whiteColor,
    secondary: ColorStyle.primaryColor,
    onSecondary: ColorStyle.whiteColor,
    error: ColorStyle.red100Color,
    onError: ColorStyle.whiteColor,
    onBackground: ColorStyle.primaryTextColor,
    surface: ColorStyle.backgroundColor,
    onSurface: ColorStyle.primaryTextColor,
  );

  static ThemeData appTheme = ThemeData(
    useMaterial3: true,
    primaryColor: ColorStyle.primaryColor,
    fontFamily: "HelveticaNowDisplay",
    canvasColor: ColorStyle.backgroundColor,
    colorScheme: ColorStyle.appScheme,
    primarySwatch: ColorStyle.primaryMaterialColor,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    dialogBackgroundColor: ColorStyle.blackColor,
    appBarTheme:
        const AppBarTheme(systemOverlayStyle: SystemUiOverlayStyle.light),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
      side: const BorderSide(width: 3, color: ColorStyle.borderColor),
    ),
    cupertinoOverrideTheme: const CupertinoThemeData(
      textTheme: CupertinoTextThemeData(),
    ),
  );

  static const primaryColor = Color(0xFFFFFFFF);
  static const backgroundColor = Color(0xFF111111);
  static const borderColor = Color(0xFF262626);

  static const primaryTextColor = Color(0xFFFFFFFF);
  static const secondaryTextColor = Color(0xFF868686);

  static const red100Color = Color(0xFFD41615);
  static const green100Color = Color(0xFF00B41D);

  static const whiteColor = Color(0xFFFFFFFF);
  static const blackColor = Color(0xFF000000);
}
