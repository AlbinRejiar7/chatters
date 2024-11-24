import 'package:chatter/auth/send_otp.dart';
import 'package:chatter/theme/notification_bar_theme.dart';
import 'package:chatter/theme/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    var themeMode = ThemeMode.light;
    updateStatusBarColor(themeMode);
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chatter',
      themeMode: themeMode,
      theme: ThemeStyles.lightTheme,
      darkTheme: ThemeStyles.darkTheme,
      home: SendOtpPage(),
    );
  }
}
