import 'package:chatter/utils/is_same_day.dart';

String formatDate(DateTime? timestamp) {
  if (timestamp == null) return "Unknown date";

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  if (isSameDay(timestamp, today)) {
    return "Today";
  } else if (isSameDay(timestamp, today.subtract(const Duration(days: 1)))) {
    return "Yesterday";
  } else {
    return "${timestamp.day}/${timestamp.month}/${timestamp.year}";
  }
}
