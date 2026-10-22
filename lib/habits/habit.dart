import 'package:flutter/material.dart';

class Habit {
  Habit({
    required this.id,
    required this.name,
    this.description = '',
    required this.dailyGoal,
    required this.unit,
    required this.weekdays,
    required this.reminderEnabled,
    this.reminderTime,
    this.icon = Icons.menu_book_rounded,
  });

  final String id;
  String name;
  String description;
  int dailyGoal;
  String unit;
  List<bool> weekdays;
  bool reminderEnabled;
  TimeOfDay? reminderTime;
  IconData icon;
  final Map<String, int> amounts = {};
  final Map<String, TimeOfDay> finishedAt = {};

  static String dayKey(DateTime day) => '${day.year}-${day.month}-${day.day}';

  int amountOn(DateTime day) => amounts[dayKey(day)] ?? 0;

  bool completeOn(DateTime day) => amountOn(day) >= dailyGoal;

  TimeOfDay? finishedAtOn(DateTime day) => finishedAt[dayKey(day)];

  void setAmountOn(DateTime day, int amount) {
    final key = dayKey(day);
    if (amount <= 0) {
      amounts.remove(key);
      finishedAt.remove(key);
      return;
    }
    amounts[key] = amount;
    if (amount >= dailyGoal) {
      finishedAt[key] = TimeOfDay.now();
    } else {
      finishedAt.remove(key);
    }
  }

  bool scheduledOn(DateTime day) => weekdays[day.weekday - 1];

  Habit copy() {
    return Habit(
      id: id,
      name: name,
      description: description,
      dailyGoal: dailyGoal,
      unit: unit,
      weekdays: List<bool>.from(weekdays),
      reminderEnabled: reminderEnabled,
      reminderTime: reminderTime,
      icon: icon,
    );
  }
}

const habitIcons = <IconData>[
  Icons.water_drop_outlined,
  Icons.self_improvement_outlined,
  Icons.menu_book_outlined,
  Icons.directions_walk_outlined,
];

String weekdayLetter(int index) => const ['M', 'T', 'W', 'T', 'F', 'S', 'S'][index];

String formatReminder(TimeOfDay time) {
  final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  final minute = time.minute.toString().padLeft(2, '0');
  final suffix = time.period == DayPeriod.am ? 'AM' : 'PM';
  return '$hour:$minute $suffix';
}
