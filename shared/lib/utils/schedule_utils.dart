import 'package:flutter/material.dart';

/// Next 3 calendar days (today + 2) at midnight local.
List<DateTime> nextThreeDays() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return [
    today,
    today.add(const Duration(days: 1)),
    today.add(const Duration(days: 2)),
  ];
}

/// 30-minute blocks from 09:00 to 20:00.
List<TimeOfDay> halfHourSlots() {
  final slots = <TimeOfDay>[];
  for (var h = 9; h <= 20; h++) {
    slots.add(TimeOfDay(hour: h, minute: 0));
    if (h < 20) slots.add(TimeOfDay(hour: h, minute: 30));
  }
  return slots;
}

DateTime combineDayAndTime(DateTime day, TimeOfDay time) {
  return DateTime(day.year, day.month, day.day, time.hour, time.minute);
}

String dayChipLabel(DateTime day) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  if (day == today) return 'Today';
  if (day == today.add(const Duration(days: 1))) return 'Tomorrow';
  return '${_weekday(day.weekday)} ${day.day}/${day.month}';
}

String _weekday(int w) {
  const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return names[w - 1];
}

String formatTimeSlot(TimeOfDay t) {
  final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
  final m = t.minute.toString().padLeft(2, '0');
  final period = t.period == DayPeriod.am ? 'AM' : 'PM';
  return '$h:$m $period';
}

bool isSlotInPast(DateTime slot) => slot.isBefore(DateTime.now());
