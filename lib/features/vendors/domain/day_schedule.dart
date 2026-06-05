import 'package:flutter/material.dart';

class DaySchedule {
  final String name;
  bool isOpen;
  TimeOfDay openTime;
  TimeOfDay closeTime;

  DaySchedule({
    required this.name,
    this.isOpen = true,
    this.openTime = const TimeOfDay(hour: 6, minute: 0),
    this.closeTime = const TimeOfDay(hour: 18, minute: 0),
  });
}
