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
    final selected = DateTime(
      store.selectedDay.year,
      store.selectedDay.month,
      store.selectedDay.day,
    );
    final weekStart = selected.subtract(Duration(days: selected.weekday - 1));
    final focus = _range == 0 ? weekStart.add(const Duration(days: 6)) : today;
    final start = _rangeStart(focus, _range);
    final days = _daysFrom(start, focus);
    final scheduled = _scheduledCount(store, days);
    final done = _doneCount(store, days);
    final percent = scheduled == 0 ? 0 : ((done / scheduled) * 100).round();
    final streak = _currentStreak(store, today);
    final best = _bestStreak(store, today);
    final slots = _chartSlots(store, _range, focus);
    final period = _range == 0 ? 'week' : _range == 1 ? 'month' : 'year';

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
            Text(
              'Your $period in view',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const Spacer(),
            Text(
              _periodLabel(focus, _range),
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          scheduled == 0
              ? 'Add a habit to see this $period fill in.'
              : '$done of $scheduled scheduled habits completed',
          style: const TextStyle(color: AppColors.muted, fontSize: 13),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: _range == 1 ? 168 : 140,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final slot in slots) Expanded(child: _Bar(slot: slot)),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _WeekRecapCard(store: store, today: focus, range: _range),
        const SizedBox(height: 12),
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

class _ChartSlot {
  const _ChartSlot({
    required this.label,
    required this.scheduled,
    required this.done,
    required this.showPercent,
  });

  final String label;
  final int scheduled;
  final int done;
  final bool showPercent;
}

class _Bar extends StatelessWidget {
  const _Bar({required this.slot});

  final _ChartSlot slot;

  @override
  Widget build(BuildContext context) {
    final ratio = slot.scheduled == 0 ? 0.08 : slot.done / slot.scheduled;
    final compact = slot.label.length > 1 && !slot.label.contains('\n');
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: compact ? 2 : slot.showPercent ? 4 : 1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            !slot.showPercent || slot.scheduled == 0 ? '' : '${(ratio * 100).round()}%',
            style: TextStyle(fontSize: compact ? 9 : 10, color: AppColors.muted),
          ),
          const SizedBox(height: 4),
          Container(
            height: 96 * ratio.clamp(0.08, 1),
            decoration: BoxDecoration(
              color: slot.done == 0 ? AppColors.mint : AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            slot.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: slot.label.contains('\n')
                  ? 10
                  : compact
                      ? 10
                      : slot.showPercent
                          ? 12
                          : 9,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekRecapCard extends StatelessWidget {
  const _WeekRecapCard({
    required this.store,
    required this.today,
    required this.range,
  });

  final HabitScopeState store;
  final DateTime today;
  final int range;

  @override
  Widget build(BuildContext context) {
    final end = DateTime(today.year, today.month, today.day);
    final recap = _rangeRecap(store, _rangeStart(end, range), end);
    final title = range == 0
        ? 'Weekly recap'
        : range == 1
            ? 'Monthly recap'
            : 'Yearly recap';
    final emptyPeriod = range == 0 ? 'week' : range == 1 ? 'month' : 'year';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
              ),
              Text(
                _periodLabel(today, range),
                style: const TextStyle(color: AppColors.muted, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (recap.activeDays == 0)
            Text(
              'No habits were scheduled this $emptyPeriod yet.',
              style: TextStyle(color: AppColors.muted, height: 1.4),
            )
          else ...[
            _RecapRow(
              icon: Icons.event_available_rounded,
              color: AppColors.primary,
              label: 'Days finished',
              value: '${recap.perfectDays} of ${recap.activeDays}',
            ),
            _RecapRow(
              icon: Icons.local_fire_department_rounded,
              color: const Color(0xFFE07A2F),
              label: 'Longest run',
              value: recap.longestRun == 1 ? '1 day' : '${recap.longestRun} days',
            ),
            _RecapRow(
              icon: Icons.warning_amber_rounded,
              color: const Color(0xFFC48A1A),
              label: 'Missed most',
              value: recap.missedName == null
                  ? 'Nothing missed'
                  : '${recap.missedName} · ${recap.missedCount}',
            ),
          ],
        ],
      ),
    );
  }
}

class _RecapRow extends StatelessWidget {
  const _RecapRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
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
  if (range == 0) return day.subtract(const Duration(days: 6));
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

class _WeekRecap {
  const _WeekRecap({
    required this.start,
    required this.end,
    required this.perfectDays,
    required this.activeDays,
    required this.longestRun,
    required this.missedName,
    required this.missedCount,
  });

  final DateTime start;
  final DateTime end;
  final int perfectDays;
  final int activeDays;
  final int longestRun;
  final String? missedName;
  final int missedCount;
}

List<_ChartSlot> _chartSlots(HabitScopeState store, int range, DateTime today) {
  final end = DateTime(today.year, today.month, today.day);
  if (range == 0) {
    final start = end.subtract(const Duration(days: 6));
    return [
      for (final day in _daysFrom(start, end))
        _ChartSlot(
          label: weekdayLetter(day.weekday - 1),
          scheduled: store.habitsFor(day).length,
          done: store.completedCount(day),
          showPercent: true,
        ),
    ];
  }
  if (range == 1) {
    final monthEnd = DateTime(end.year, end.month + 1, 0);
    final slots = <_ChartSlot>[];
    var weekNumber = 1;
    for (var day = 1; day <= monthEnd.day && day <= end.day; day += 7) {
      final blockEnd = day + 6 > monthEnd.day ? monthEnd.day : day + 6;
      final last = blockEnd > end.day ? end.day : blockEnd;
      final days = _daysFrom(DateTime(end.year, end.month, day), DateTime(end.year, end.month, last));
      slots.add(
        _ChartSlot(
          label: 'Week $weekNumber\n($day–$blockEnd)',
          scheduled: _scheduledCount(store, days),
          done: _doneCount(store, days),
          showPercent: true,
        ),
      );
      weekNumber++;
    }
    return slots;
  }
  const letters = [
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
  return [
    for (var month = 1; month <= end.month; month++)
      () {
        final days = _daysFrom(
          DateTime(end.year, month, 1),
          month == end.month ? end : DateTime(end.year, month + 1, 0),
        );
        return _ChartSlot(
          label: letters[month - 1],
          scheduled: _scheduledCount(store, days),
          done: _doneCount(store, days),
          showPercent: true,
        );
      }(),
  ];
}

_WeekRecap _rangeRecap(HabitScopeState store, DateTime start, DateTime end) {
  final days = _daysFrom(start, end);
  var perfectDays = 0;
  var activeDays = 0;
  var run = 0;
  var longestRun = 0;
  final misses = <String, int>{};
  for (final day in days) {
    final scheduled = store.habitsFor(day);
    if (scheduled.isEmpty) {
      run = 0;
      continue;
    }
    activeDays++;
    if (_perfect(store, day)) {
      perfectDays++;
      run++;
      if (run > longestRun) longestRun = run;
    } else {
      run = 0;
    }
    for (final habit in scheduled) {
      if (!habit.completeOn(day)) {
        misses[habit.name] = (misses[habit.name] ?? 0) + 1;
      }
    }
  }
  String? missedName;
  var missedCount = 0;
  for (final entry in misses.entries) {
    if (entry.value > missedCount) {
      missedName = entry.key;
      missedCount = entry.value;
    }
  }
  return _WeekRecap(
    start: start,
    end: end,
    perfectDays: perfectDays,
    activeDays: activeDays,
    longestRun: longestRun,
    missedName: missedName,
    missedCount: missedCount,
  );
}

String _periodLabel(DateTime today, int range) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  final day = DateTime(today.year, today.month, today.day);
  if (range == 1) return '${months[day.month - 1]} ${day.year}';
  if (range == 2) return '${day.year}';
  return _weekLabel(day.subtract(const Duration(days: 6)), day);
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
  if (start.month == end.month) {
    return '${months[start.month - 1]} ${start.day}–${end.day}';
  }
  return '${months[start.month - 1]} ${start.day}–${months[end.month - 1]} ${end.day}';
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
