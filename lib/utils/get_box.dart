import 'package:hive_flutter/hive_flutter.dart';

class HiveBoxManager {
  static Box<List<dynamic>>? _chatBox;

  static Future<Box<List<dynamic>>> getChatBox() async {
    if (_chatBox == null || !_chatBox!.isOpen) {
      _chatBox = await Hive.openBox<List<dynamic>>("chatBox");
    }
    return _chatBox!;
  }
}
