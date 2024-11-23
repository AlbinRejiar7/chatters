import 'package:chatter/constants/colors.dart';
import 'package:chatter/constants/dark_font_style.dart';
import 'package:chatter/constants/light_font_style.dart';
import 'package:flutter/material.dart';

class ThemeStyles {
  static ThemeData darkTheme = ThemeData.dark().copyWith(
      navigationBarTheme: const NavigationBarThemeData().copyWith(
          backgroundColor: AppColors.darkColor,
          indicatorColor: AppColors.whiteColor.withOpacity(0.1),
          labelTextStyle: WidgetStatePropertyAll(
            DarkFontStyle.textMedium,
          )),
      scaffoldBackgroundColor: AppColors.darkColor,
      textTheme: const TextTheme().copyWith(
          bodyMedium: DarkFontStyle.textMedium,
          bodyLarge: DarkFontStyle.textMedium.copyWith(
              fontWeight: FontWeight.bold, color: AppColors.greyColor)));

  static ThemeData lightTheme = ThemeData.light().copyWith(
      navigationBarTheme: const NavigationBarThemeData().copyWith(
          elevation: 20,
          indicatorColor: AppColors.primaryColor,
          iconTheme: const WidgetStatePropertyAll(
              IconThemeData(color: AppColors.greyColor)),
          backgroundColor: AppColors.whiteColor,
          labelTextStyle: WidgetStatePropertyAll(
            LightFontStyle.textMedium,
          )),
      colorScheme: const ColorScheme.dark().copyWith(
        primary: Colors.white54,
        onPrimary: AppColors.whiteColor,
      ),
      scaffoldBackgroundColor: AppColors.whiteColor,
      textTheme: const TextTheme().copyWith(
          bodyMedium: LightFontStyle.textMedium,
          bodyLarge: LightFontStyle.textMedium.copyWith(
              fontWeight: FontWeight.bold, color: AppColors.greyColor)));
}
