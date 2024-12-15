import 'package:chatter/controller/contacts.dart';
import 'package:chatter/controller/home.dart';
import 'package:chatter/model/chat.dart';
import 'package:chatter/services/local_service.dart';
import 'package:chatter/theme/notification_bar_theme.dart';
import 'package:chatter/theme/styles.dart';
import 'package:chatter/view/auth/send_otp.dart';
import 'package:chatter/view/bottom_bar_page/bottom_bar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ScreenUtil.ensureScreenSize();
  await GetStorage.init();
  await Hive.initFlutter();
  Hive.registerAdapter(ChatModelAdapter());
  Hive.registerAdapter(MessageTypeAdapter());
  LocalService.onInit();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // var ctr = Get.put(ContactsController());
  // await ctr.fetchContacts();
  // await ctr.fetchMatchingContacts();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
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
          home: InitializationScreen()),
    );
  }
}

class InitializationScreen extends StatefulWidget {
  @override
  _InitializationScreenState createState() => _InitializationScreenState();
}

class _InitializationScreenState extends State<InitializationScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Fetch and process contacts
    var contactsController = Get.put(ContactsController());

    // Initialize HomeController
    Get.put(HomeController());

    // Once initialization is done, navigate to the main screen
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return (LocalService.isLoggedIn ?? false)
          ? BottomBarPage()
          : SendOtpPage(); // Replace with your main screen
    }
  }
}
