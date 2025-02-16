import 'package:chatter/controller/connectivity.dart';
import 'package:chatter/model/chat.dart';
import 'package:chatter/services/chat_service.dart';
import 'package:chatter/services/local_notification.dart';
import 'package:chatter/services/local_service.dart';
import 'package:chatter/services/push_notification.dart';
import 'package:chatter/theme/notification_bar_theme.dart';
import 'package:chatter/theme/styles.dart';
import 'package:chatter/utils/get_box.dart';
import 'package:chatter/view/auth/send_otp.dart';
import 'package:chatter/view/bottom_bar_page/bottom_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'controller/new_audio_controller/audio_manager.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await ScreenUtil.ensureScreenSize();
  await GetStorage.init();
  await Hive.initFlutter();
  Hive.registerAdapter(ChatModelAdapter());
  Hive.registerAdapter(MessageTypeAdapter());
  LocalService.onInit();
  await HiveBoxManager.getChatBox();
  await LocalNotificationService.reSubscribe();
  await LocalNotificationService.initLocalNotificationService();
  await PushNotificationService.handleForegroundNotification();
  await PushNotificationService.handleBackgroundNotification();

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
  const InitializationScreen({super.key});

  @override
  _InitializationScreenState createState() => _InitializationScreenState();
}

class _InitializationScreenState extends State<InitializationScreen>
    with WidgetsBindingObserver {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.detached ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.inactive) {
      await ChatRoomService.updateLastSeen(
          timestamp: FieldValue.serverTimestamp());
    } else if (state == AppLifecycleState.resumed) {
      await ChatRoomService.updateLastSeen();
    }
  }

  Future<void> _initializeApp() async {
    Get.put(AudioManager());
    var ctr = Get.put(ConnectivityController());
    await ctr.initConnectivity();
    await ChatRoomService.updateLastSeen();
    // Once initialization is done, navigate to the main screen
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
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
