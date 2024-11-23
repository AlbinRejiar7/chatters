import 'package:flutter/material.dart';

String formatTime(DateTime? timestamp) {
  if (timestamp == null) return '';
  final time = TimeOfDay.fromDateTime(timestamp);
  return '${time.hourOfPeriod}:${time.minute.toString().padLeft(2, '0')} ${time.period == DayPeriod.am ? 'AM' : 'PM'}';
}
