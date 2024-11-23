import 'package:chatter/theme/styles.dart';
import 'package:chatter/view/bottom_bar_page/bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Chatter',
      themeMode: ThemeMode.system,
      theme: ThemeStyles.lightTheme,
      darkTheme: ThemeStyles.darkTheme,
      home: BottomBarPage(),
    );
  }
}
