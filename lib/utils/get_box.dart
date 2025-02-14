import 'package:hive_flutter/hive_flutter.dart';

class HiveBoxManager {
  static Box<List<dynamic>>? chatBox; // Public static variable

  static Future<void> getChatBox() async {
    if (chatBox == null || !chatBox!.isOpen) {
      chatBox = await Hive.openBox<List<dynamic>>("chatBox");
    }
  }
}
