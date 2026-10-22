import 'package:flutter/material.dart';

import '../../habits/habit.dart';
import '../../habits/habit_scope.dart';
import '../../theme.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  int _range = 0;

  @override
  Widget build(BuildContext context) {
    final store = HabitScope.of(context);
    final today = DateTime.now();
    final start = _rangeStart(today, _range);
    final days = _daysFrom(start, today);
    final scheduled = _scheduledCount(store, days);
    final done = _doneCount(store, days);
    final percent = scheduled == 0 ? 0 : ((done / scheduled) * 100).round();
    final streak = _currentStreak(store, today);
    final best = _bestStreak(store, today);
    final week = _daysFrom(today.subtract(const Duration(days: 6)), today);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        const Text(
          'YOUR PROGRESS',
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w800,
            color: AppColors.muted,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Small steps add up.',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        _RangeToggle(
          index: _range,
          onChanged: (value) => setState(() => _range = value),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _StatTile(
              value: '$percent%',
              label: _range == 0
                  ? 'Weekly completion'
                  : _range == 1
                      ? 'Monthly completion'
                      : 'Yearly completion',
              detail: scheduled == 0
                  ? 'No habits scheduled'
                  : '$done of $scheduled scheduled',
            ),
            const SizedBox(width: 12),
            _StatTile(
              value: '$streak days',
              label: 'Current streak',
              detail: 'Best streak: $best days',
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            const Text(
              'Your week in view',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const Spacer(),
            Text(
              _weekLabel(week.first, week.last),
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          scheduled == 0
              ? 'Add a habit to see this week fill in.'
              : '$done of $scheduled scheduled habits completed',
          style: const TextStyle(color: AppColors.muted, fontSize: 13),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final day in week)
                Expanded(child: _Bar(day: day, store: store)),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _InsightCard(store: store, days: days),
      ],
    );
  }
}

class _RangeToggle extends StatelessWidget {
  const _RangeToggle({required this.index, required this.onChanged});

  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    const labels = ['Week', 'Month', 'Year'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: Container(
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: index == i ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    labels[i],
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.value,
    required this.label,
    required this.detail,
  });

  final String value;
  final String label;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(
              detail,
              style: const TextStyle(color: AppColors.primary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.day, required this.store});

  final DateTime day;
  final HabitScopeState store;

  @override
  Widget build(BuildContext context) {
    final scheduled = store.habitsFor(day).length;
    final done = store.completedCount(day);
    final ratio = scheduled == 0 ? 0.08 : done / scheduled;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            scheduled == 0 ? '' : '${(ratio * 100).round()}%',
            style: const TextStyle(fontSize: 10, color: AppColors.muted),
          ),
          const SizedBox(height: 4),
          Container(
            height: 96 * ratio.clamp(0.08, 1),
            decoration: BoxDecoration(
              color: done == 0 ? AppColors.mint : AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            weekdayLetter(day.weekday - 1),
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.store, required this.days});

  final HabitScopeState store;
  final List<DateTime> days;

  @override
  Widget build(BuildContext context) {
    final message = _insight(store, days);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.mint,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'A mindful kind of week',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(message, style: const TextStyle(height: 1.4)),
        ],
      ),
    );
  }
}

DateTime _rangeStart(DateTime today, int range) {
  final day = DateTime(today.year, today.month, today.day);
  if (range == 0) return day.subtract(Duration(days: day.weekday - 1));
  if (range == 1) return DateTime(day.year, day.month, 1);
  return DateTime(day.year, 1, 1);
}

List<DateTime> _daysFrom(DateTime start, DateTime end) {
  final first = DateTime(start.year, start.month, start.day);
  final last = DateTime(end.year, end.month, end.day);
  return [
    for (var day = first;
        !day.isAfter(last);
        day = day.add(const Duration(days: 1)))
      day,
  ];
}

int _scheduledCount(HabitScopeState store, List<DateTime> days) {
  return days.fold(0, (sum, day) => sum + store.habitsFor(day).length);
}

int _doneCount(HabitScopeState store, List<DateTime> days) {
  return days.fold(0, (sum, day) => sum + store.completedCount(day));
}

bool _perfect(HabitScopeState store, DateTime day) {
  final scheduled = store.habitsFor(day);
  if (scheduled.isEmpty) return false;
  return store.completedCount(day) == scheduled.length;
}

int _currentStreak(HabitScopeState store, DateTime today) {
  var streak = 0;
  var day = DateTime(today.year, today.month, today.day);
  final oldest = day.subtract(const Duration(days: 400));
  while (!day.isBefore(oldest)) {
    if (store.habitsFor(day).isEmpty) {
      day = day.subtract(const Duration(days: 1));
      continue;
    }
    if (!_perfect(store, day)) break;
    streak++;
    day = day.subtract(const Duration(days: 1));
  }
  return streak;
}

int _bestStreak(HabitScopeState store, DateTime today) {
  var best = 0;
  var run = 0;
  final start = DateTime(today.year, today.month, today.day)
      .subtract(const Duration(days: 370));
  for (final day in _daysFrom(start, today)) {
    if (store.habitsFor(day).isEmpty) continue;
    if (_perfect(store, day)) {
      run++;
      if (run > best) best = run;
    } else {
      run = 0;
    }
  }
  return best;
}

String _weekLabel(DateTime start, DateTime end) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[start.month - 1]} ${start.day}–${end.day}';
}

String _insight(HabitScopeState store, List<DateTime> days) {
  if (store.habits.isEmpty) {
    return 'Create a habit on Today. This summary fills in as you check days off.';
  }
  Habit? best;
  var bestDays = 0;
  var bestAmount = 0;
  for (final habit in store.habits) {
    var count = 0;
    var amount = 0;
    for (final day in days) {
      if (!habit.scheduledOn(day)) continue;
      if (habit.completeOn(day)) count++;
      amount += habit.amountOn(day);
    }
    if (count > bestDays) {
      best = habit;
      bestDays = count;
      bestAmount = amount;
    }
  }
  if (best == null || bestDays == 0) {
    return 'Nothing completed in this range yet. One check-in starts the streak.';
  }
  return 'You kept ${best.name} on $bestDays days. That’s $bestAmount ${best.unit.toLowerCase()}.';
}
