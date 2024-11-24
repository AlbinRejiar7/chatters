import 'package:chatter/auth/send_otp.dart';
import 'package:chatter/controller/contacts.dart';
import 'package:chatter/theme/notification_bar_theme.dart';
import 'package:chatter/theme/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ScreenUtil.ensureScreenSize();
  await GetStorage.init();
await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    Get.put(ContactsController());
    var themeMode = ThemeMode.light;
    updateStatusBarColor(themeMode);
    return ScreenUtilInit(
      minTextAdapt: true,
      designSize: const Size(360, 752),
      builder: (context, child) => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Chatter',
        themeMode: themeMode,
        theme: ThemeStyles.lightTheme,
        darkTheme: ThemeStyles.darkTheme,
        home: SendOtpPage(),
      ),
    );
  }
}
