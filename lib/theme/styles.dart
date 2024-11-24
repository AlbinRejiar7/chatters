import 'package:chatter/constants/colors.dart';
import 'package:chatter/constants/dark_font_style.dart';
import 'package:chatter/constants/light_font_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ThemeStyles {
  //dark theme
  static ThemeData darkTheme = ThemeData.dark().copyWith(
      primaryColor: AppColors.whiteColor,
      appBarTheme: const AppBarTheme().copyWith(
          backgroundColor: AppColors.darkColor,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent, // Transparent status bar
            statusBarIconBrightness:
                Brightness.light, // Light icons for dark backgrounds
            systemNavigationBarColor:
                Colors.black, // Navigation bar color for dark theme
            systemNavigationBarIconBrightness:
                Brightness.light, // Light nav bar icons
          )),
      navigationBarTheme: const NavigationBarThemeData().copyWith(
          backgroundColor: AppColors.darkColor,
          iconTheme: const WidgetStatePropertyAll(
              IconThemeData(color: AppColors.whiteColor, size: 17)),
          indicatorColor: AppColors.primaryColor,
          labelTextStyle: WidgetStatePropertyAll(
            DarkFontStyle.textMedium,
          )),
      scaffoldBackgroundColor: AppColors.darkColor,
      //Text Theme
      primaryTextTheme:
          const TextTheme().copyWith(labelSmall: DarkFontStyle.smallSubtitle),
      textTheme: const TextTheme().copyWith(
          bodyMedium: DarkFontStyle.textMedium,
          bodySmall: DarkFontStyle.bodySmall,
          titleMedium: DarkFontStyle.titleMedium,
          bodyLarge: DarkFontStyle.textMedium.copyWith(
              fontWeight: FontWeight.bold, color: AppColors.greyColor)));

//light theme

  static ThemeData lightTheme = ThemeData.light().copyWith(
      appBarTheme: const AppBarTheme().copyWith(
        backgroundColor: AppColors.whiteColor,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent, // Transparent status bar
          statusBarIconBrightness:
              Brightness.dark, // Dark icons for light backgrounds
          systemNavigationBarColor:
              Colors.white, // Optional: Change navigation bar color
          systemNavigationBarIconBrightness:
              Brightness.dark, // Dark nav bar icons
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData().copyWith(
          elevation: 5,
          indicatorColor: AppColors.primaryColor,
          iconTheme: const WidgetStatePropertyAll(
              IconThemeData(color: AppColors.darkColor, size: 17)),
          backgroundColor: AppColors.primaryLight,
          labelTextStyle: WidgetStatePropertyAll(
            LightFontStyle.textMedium,
          )),
      colorScheme: const ColorScheme.dark().copyWith(
        primary: Colors.white54,
        onPrimary: AppColors.whiteColor,
        secondary: AppColors.greyColor,
        onSecondary: AppColors.primaryColor,
      ),
      primaryTextTheme:
          const TextTheme().copyWith(labelSmall: LightFontStyle.smallSubtitle),
      primaryColor: AppColors.darkColor,
      scaffoldBackgroundColor: AppColors.whiteColor,

      //text Theme
      textTheme: const TextTheme().copyWith(
          bodySmall: LightFontStyle.bodySmall,
          bodyMedium: LightFontStyle.textMedium,
          titleMedium: LightFontStyle.titleMedium,
          bodyLarge: LightFontStyle.textMedium.copyWith(
              fontWeight: FontWeight.bold, color: AppColors.greyColor)));
}
