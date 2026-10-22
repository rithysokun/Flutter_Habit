import 'package:flutter/material.dart';

import '../../habits/habit.dart';
import '../../habits/habit_scope.dart';
import '../../theme.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _month;
  DateTime? _openDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
  }

  @override
  Widget build(BuildContext context) {
    if (_openDay != null) {
      return _SelectedDay(
        day: _openDay!,
        onBack: () => setState(() => _openDay = null),
        onToday: () {
          final now = DateTime.now();
          setState(() {
            _openDay = DateTime(now.year, now.month, now.day);
            _month = DateTime(now.year, now.month);
          });
        },
      );
    }

    final store = HabitScope.of(context);
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final scheduled = store.habitsFor(todayDate);
    final done = store.completedCount(todayDate);
    final monthDays = _daysInMonth(_month);
    final monthDone = monthDays.fold<int>(
      0,
      (sum, day) => sum + store.completedCount(day),
    );
    final monthScheduled = monthDays.fold<int>(
      0,
      (sum, day) => day.isAfter(todayDate) ? sum : sum + store.habitsFor(day).length,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        const Text(
          'HABIT CALENDAR',
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w800,
            color: AppColors.muted,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your rhythm, at a glance.',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            IconButton(
              onPressed: () => setState(() {
                _month = DateTime(_month.year, _month.month - 1);
              }),
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            Expanded(
              child: Text(
                '${_monthName(_month.month)} ${_month.year}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
            ),
            IconButton(
              onPressed: () => setState(() {
                _month = DateTime(_month.year, _month.month + 1);
              }),
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
        Row(
          children: [
            for (final letter in ['M', 'T', 'W', 'T', 'F', 'S', 'S'])
              Expanded(
                child: Text(
                  letter,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        _MonthGrid(
          month: _month,
          today: todayDate,
          onOpen: (day) => setState(() => _openDay = day),
        ),
        const SizedBox(height: 12),
        const Row(
          children: [
            _LegendDot(color: AppColors.primary, label: 'All done'),
            SizedBox(width: 12),
            _LegendDot(color: AppColors.mintDeep, label: 'Partial'),
            SizedBox(width: 12),
            _LegendDot(color: Color(0xFFE5E7EB), label: 'Upcoming'),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Text(
              'Today · ${_monthName(today.month)} ${today.day}',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => setState(() => _openDay = todayDate),
              child: const Text('View day'),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.mint,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            scheduled.isEmpty
                ? 'No habits scheduled today.'
                : '$done of ${scheduled.length} habits complete',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          monthScheduled == 0
              ? 'Completed habits this month will show up here.'
              : '$monthDone of $monthScheduled habits completed this month so far.',
          style: const TextStyle(color: AppColors.muted, height: 1.4),
        ),
      ],
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.today,
    required this.onOpen,
  });

  final DateTime month;
  final DateTime today;
  final ValueChanged<DateTime> onOpen;

  @override
  Widget build(BuildContext context) {
    final store = HabitScope.of(context);
    final first = DateTime(month.year, month.month, 1);
    final leading = first.weekday - 1;
    final days = DateTime(month.year, month.month + 1, 0).day;
    final cells = leading + days;
    final rows = (cells / 7).ceil();

    return Column(
      children: [
        for (var row = 0; row < rows; row++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                for (var col = 0; col < 7; col++)
                  Expanded(
                    child: _cell(
                      store,
                      row * 7 + col - leading + 1,
                      days,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _cell(HabitScopeState store, int dayNumber, int days) {
    if (dayNumber < 1 || dayNumber > days) {
      return const SizedBox(height: 40);
    }
    final day = DateTime(month.year, month.month, dayNumber);
    final upcoming = day.isAfter(today);
    final scheduled = store.habitsFor(day).length;
    final done = store.completedCount(day);
    Color fill = Colors.white;
    Color text = AppColors.text;
    if (upcoming || scheduled == 0) {
      fill = const Color(0xFFF3F4F6);
      text = AppColors.muted;
    } else if (done == scheduled) {
      fill = AppColors.primary;
      text = Colors.white;
    } else if (done > 0) {
      fill = AppColors.mintDeep;
    }
    final isToday = day == today;
    return GestureDetector(
      onTap: () => onOpen(day),
      child: Container(
        height: 40,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(12),
          border: isToday ? Border.all(color: AppColors.primary, width: 1.6) : null,
        ),
        child: Text(
          '$dayNumber',
          style: TextStyle(fontWeight: FontWeight.w800, color: text),
        ),
      ),
    );
  }
}

class _SelectedDay extends StatelessWidget {
  const _SelectedDay({
    required this.day,
    required this.onBack,
    required this.onToday,
  });

  final DateTime day;
  final VoidCallback onBack;
  final VoidCallback onToday;

  @override
  Widget build(BuildContext context) {
    final store = HabitScope.of(context);
    final habits = store.habitsFor(day);
    final done = habits.where((habit) => habit.completeOn(day)).toList();
    final percent = habits.isEmpty ? 0 : ((done.length / habits.length) * 100).round();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Row(
          children: [
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const Spacer(),
            TextButton(onPressed: onToday, child: const Text('Today')),
          ],
        ),
        const Text(
          'YOUR DAY IN DETAIL',
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w800,
            color: AppColors.muted,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${_weekdayName(day.weekday)}, ${_monthName(day.month)} ${day.day}',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 72,
                height: 72,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 4),
                ),
                child: Text(
                  '${done.length} of ${habits.length}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'A full day of good.\nEvery scheduled habit, one step at a time.',
                  style: TextStyle(fontWeight: FontWeight.w700, height: 1.35),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            const Text(
              'Completed habits',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const Spacer(),
            Text(
              '$percent%',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (done.isEmpty)
          const Text(
            'Nothing completed on this day yet.',
            style: TextStyle(color: AppColors.muted),
          )
        else
          for (final habit in done) ...[
            _DoneTile(habit: habit, day: day),
            const SizedBox(height: 10),
          ],
        const SizedBox(height: 8),
        const Text(
          'A little moment worth looking back on.',
          style: TextStyle(color: AppColors.muted),
        ),
      ],
    );
  }
}

class _DoneTile extends StatelessWidget {
  const _DoneTile({required this.habit, required this.day});

  final Habit habit;
  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final time = habit.finishedAtOn(day);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.mint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(habit.icon, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(habit.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                Text(
                  '${habit.amountOn(day)} ${habit.unit.toLowerCase()}'
                  '${time == null ? '' : ' · ${formatReminder(time)}'}',
                  style: const TextStyle(color: AppColors.muted, fontSize: 13),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded, color: AppColors.primary),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
      ],
    );
  }
}

const _months = [
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

const _weekdays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

String _monthName(int month) => _months[month - 1];

String _weekdayName(int weekday) => _weekdays[weekday - 1];

List<DateTime> _daysInMonth(DateTime month) {
  final count = DateTime(month.year, month.month + 1, 0).day;
  return [
    for (var day = 1; day <= count; day++) DateTime(month.year, month.month, day),
  ];
}
