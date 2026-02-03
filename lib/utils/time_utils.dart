import 'package:flutter/material.dart';

int timeOfDayToMinutes(TimeOfDay time) => time.hour * 60 + time.minute;

TimeOfDay minutesToTimeOfDay(int minutes) {
  final normalized = minutes % (24 * 60);
  final hour = normalized ~/ 60;
  final minute = normalized % 60;
  return TimeOfDay(hour: hour, minute: minute);
}

bool isWithinSchedule(DateTime timestamp, TimeOfDay start, TimeOfDay end) {
  final minutes = timestamp.hour * 60 + timestamp.minute;
  final startMinutes = timeOfDayToMinutes(start);
  final endMinutes = timeOfDayToMinutes(end);

  if (startMinutes == endMinutes) {
    return true;
  }

  if (startMinutes < endMinutes) {
    return minutes >= startMinutes && minutes <= endMinutes;
  }
  return minutes >= startMinutes || minutes <= endMinutes;
}
