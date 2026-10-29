import 'package:flutter/material.dart';

import '../auth/auth_api.dart';
import 'habit.dart';
import 'habit_api.dart';

class HabitScope extends StatefulWidget {
  const HabitScope({
    super.key,
    required this.userName,
    required this.email,
    required this.child,
  });

  final String userName;
  final String email;
  final Widget child;

  static HabitScopeState of(BuildContext context) {
    final state = context.dependOnInheritedWidgetOfExactType<_HabitInherited>();
    assert(state != null, 'HabitScope not found');
    return state!.state;
  }

  @override
  State<HabitScope> createState() => HabitScopeState();
}

class HabitScopeState extends State<HabitScope> {
  final List<Habit> habits = [];
  final HabitApi _api = HabitApi();
  DateTime selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => reload());
  }

  Future<void> reload() async {
    try {
      final loaded = await _api.list(widget.email);
      if (!mounted) return;
      setState(() {
        habits
          ..clear()
          ..addAll(loaded);
      });
    } on AuthApiException catch (error) {
      _showError(error.message);
    }
  }

  List<Habit> habitsFor(DateTime day) {
    return habits.where((habit) => !habit.archived && habit.scheduledOn(day)).toList();
  }

  List<Habit> get archivedHabits {
    return habits.where((habit) => habit.archived).toList();
  }

  int completedCount(DateTime day) {
    return habitsFor(day).where((habit) => habit.completeOn(day)).length;
  }

  Future<void> add(Habit habit) async {
    final saved = await _api.save(widget.email, habit, creating: true);
    if (!mounted) return;
    setState(() => habits.add(saved));
  }

  Future<void> update(Habit habit) async {
    final saved = await _api.save(widget.email, habit);
    if (!mounted) return;
    setState(() {
      final index = habits.indexWhere((item) => item.id == habit.id);
      if (index >= 0) habits[index] = saved;
    });
  }

  Future<void> reorderVisible(List<Habit> visible, int oldIndex, int newIndex) async {
    if (oldIndex < 0 || oldIndex >= visible.length) return;
    if (newIndex < 0 || newIndex >= visible.length || newIndex == oldIndex) return;
    final visibleIds = visible.map((habit) => habit.id).toSet();
    final order = visible.map((habit) => habit.id).toList();
    final moved = order.removeAt(oldIndex);
    order.insert(newIndex, moved);
    final byId = {for (final habit in habits) habit.id: habit};
    final next = <Habit>[
      for (final habit in habits)
        if (visibleIds.contains(habit.id)) byId[order.removeAt(0)]! else habit,
    ];
    setState(() {
      habits
        ..clear()
        ..addAll(next);
    });
    try {
      await _api.reorder(widget.email, habits.map((habit) => habit.id).toList());
    } on AuthApiException {
      if (!mounted) return;
      await reload();
      rethrow;
    }
  }

  Future<void> setArchived(String id, bool archived) async {
    final habit = habits.firstWhere((item) => item.id == id);
    await _api.archive(widget.email, id, archived);
    if (!mounted) return;
    setState(() => habit.archived = archived);
  }

  Future<void> remove(String id) async {
    await _api.delete(widget.email, id);
    if (!mounted) return;
    setState(() => habits.removeWhere((item) => item.id == id));
  }

  Future<void> setAmount(String id, int amount) async {
    final habit = habits.firstWhere((item) => item.id == id);
    await _api.log(
      email: widget.email,
      habitId: id,
      day: selectedDay,
      amount: amount,
    );
    if (!mounted) return;
    setState(() => habit.setAmountOn(selectedDay, amount));
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void selectDay(DateTime day) => setState(() => selectedDay = day);

  @override
  Widget build(BuildContext context) {
    return _HabitInherited(state: this, child: widget.child);
  }
}

class _HabitInherited extends InheritedWidget {
  const _HabitInherited({required this.state, required super.child});

  final HabitScopeState state;

  @override
  bool updateShouldNotify(_HabitInherited oldWidget) => true;
}
