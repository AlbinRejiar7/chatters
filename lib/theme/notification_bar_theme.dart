import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void updateStatusBarColor(ThemeMode themeMode) {
  final isDark = themeMode == ThemeMode.dark;
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Transparent status bar
      statusBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark, // Icons
      systemNavigationBarColor:
          isDark ? Colors.black : Colors.white, // Navigation bar
      systemNavigationBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark, // Navigation icons
    ),
  );
}
