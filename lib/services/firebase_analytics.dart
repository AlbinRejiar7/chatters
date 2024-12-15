import 'package:firebase_analytics/firebase_analytics.dart';

class FirestoreLogger {
  static FirebaseAnalytics get _analytics => FirebaseAnalytics.instance;

  static Future<void> logFieldWrite({
    required String name,
    required String mainCollection,
    required String mainDocument,
    String? subCollection,
    String? subDocument,
    List<String>? fields, // Accept multiple fields
  }) async {
    await _analytics.logEvent(
      name: name,
      parameters: {
        'main_collection': mainCollection,
        'main_document': mainDocument,
        if (subCollection != null) 'sub_collection': subCollection,
        if (subDocument != null) 'sub_document': subDocument,
        if (fields != null)
          'fields':
              fields.join(','), // Convert list to a comma-separated string
      },
    );
  }
}
