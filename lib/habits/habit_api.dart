import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../auth/auth_api.dart';
import 'habit.dart';

class HabitApi {
  HabitApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<Habit>> list(String email) async {
    final body = await _post('/habits/list', {'email': email});
    final habits = body['habits'];
    if (habits is! List) return [];
    return habits.map((item) => _habit(item as Map<String, dynamic>)).toList();
  }

  Future<Habit> save(String email, Habit habit, {bool creating = false}) async {
    final body = await _post('/habits/save', {
      'email': email,
      if (!creating) 'id': habit.id,
      'name': habit.name,
      'description': habit.description,
      'dailyGoal': habit.dailyGoal,
      'unit': habit.unit,
      'weekdays': habit.weekdays,
      'reminderEnabled': habit.reminderEnabled,
      'reminderTime': habit.reminderTime == null
          ? null
          : '${habit.reminderTime!.hour.toString().padLeft(2, '0')}:${habit.reminderTime!.minute.toString().padLeft(2, '0')}',
    });
    final saved = _habit(body);
    saved.icon = habit.icon;
    saved.amounts.addAll(habit.amounts);
    saved.finishedAt.addAll(habit.finishedAt);
    return saved;
  }

  Future<void> delete(String email, String id) {
    return _post('/habits/delete', {'email': email, 'id': id});
  }

  Future<void> log({
    required String email,
    required String habitId,
    required DateTime day,
    required int amount,
  }) {
    final month = day.month.toString().padLeft(2, '0');
    final date = day.day.toString().padLeft(2, '0');
    return _post('/habits/log', {
      'email': email,
      'habitId': habitId,
      'date': '${day.year}-$month-$date',
      'amount': amount,
    });
  }

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) async {
    final http.Response response;
    try {
      response = await _client.post(
        Uri.parse('${AuthApi.base}$path'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
    } catch (_) {
      throw const AuthApiException(
        'Cannot reach the account service. Start it with: server/.venv/bin/python server/sign_in_api.py',
      );
    }
    final decoded = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body);
    final map = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    if (response.statusCode >= 200 && response.statusCode < 300) return map;
    throw AuthApiException(map['message']?.toString() ?? 'Could not save habits.');
  }

  Habit _habit(Map<String, dynamic> json) {
    final weekdays = (json['weekdays'] as List?)
            ?.map((day) => day == true)
            .toList() ??
        List<bool>.filled(7, true);
    final reminder = json['reminderTime']?.toString();
    TimeOfDay? time;
    if (reminder != null && reminder.contains(':')) {
      final parts = reminder.split(':');
      time = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
    final habit = Habit(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      dailyGoal: json['dailyGoal'] is int
          ? json['dailyGoal'] as int
          : int.parse(json['dailyGoal'].toString()),
      unit: json['unit']?.toString() ?? 'Pages',
      weekdays: weekdays,
      reminderEnabled: json['reminderEnabled'] == true,
      reminderTime: time,
      icon: iconForUnit(json['unit']?.toString() ?? ''),
    );
    final logs = json['logs'];
    if (logs is List) {
      for (final log in logs) {
        if (log is! Map) continue;
        final date = log['date']?.toString() ?? '';
        final parts = date.split('-');
        if (parts.length != 3) continue;
        final day = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
        final amount = log['amount'] is int
            ? log['amount'] as int
            : int.parse(log['amount'].toString());
        final key = Habit.dayKey(day);
        habit.amounts[key] = amount;
        final clock = log['completedAt']?.toString();
        if (clock != null && clock.contains(':')) {
          final clockParts = clock.split(':');
          habit.finishedAt[key] = TimeOfDay(
            hour: int.parse(clockParts[0]),
            minute: int.parse(clockParts[1]),
          );
        }
      }
    }
    return habit;
  }
}

IconData iconForUnit(String unit) {
  switch (unit.toLowerCase()) {
    case 'glasses':
      return Icons.water_drop_outlined;
    case 'minutes':
      return Icons.self_improvement_outlined;
    default:
      return Icons.menu_book_outlined;
  }
}
