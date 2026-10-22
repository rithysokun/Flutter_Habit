import 'package:flutter/material.dart';

import '../../auth/auth_api.dart';
import '../../habits/habit.dart';
import '../../habits/habit_scope.dart';
import '../../theme.dart';
import 'habit_completed_screen.dart';
import 'habit_details_screen.dart';
import 'habit_form_screen.dart';

const _months = [
  'JANUARY',
  'FEBRUARY',
  'MARCH',
  'APRIL',
  'MAY',
  'JUNE',
  'JULY',
  'AUGUST',
  'SEPTEMBER',
  'OCTOBER',
  'NOVEMBER',
  'DECEMBER',
];

const _weekdays = [
  'MONDAY',
  'TUESDAY',
  'WEDNESDAY',
  'THURSDAY',
  'FRIDAY',
  'SATURDAY',
  'SUNDAY',
];

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key, required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) {
    final store = HabitScope.of(context);
    final day = store.selectedDay;
    final habits = store.habitsFor(day);
    final done = store.completedCount(day);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        Text(
          '${_weekdays[day.weekday - 1]}, ${_months[day.month - 1]} ${day.day}',
          style: const TextStyle(
            fontSize: 12,
            letterSpacing: 0.6,
            fontWeight: FontWeight.w700,
            color: AppColors.muted,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                habits.isEmpty ? 'Your fresh start' : 'Good morning, $userName',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            _AddButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HabitFormScreen()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _WeekStrip(
          selected: day,
          onSelect: store.selectDay,
        ),
        const SizedBox(height: 16),
        if (habits.isEmpty)
          const _EmptyToday()
        else ...[
          _ProgressCard(done: done, total: habits.length),
          const SizedBox(height: 18),
          Row(
            children: [
              const Text(
                'Your habits',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const Spacer(),
              Text(
                done == 0 ? 'Start your streak' : '$done-day streak',
                style: const TextStyle(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final habit in habits) ...[
            _HabitTile(habit: habit),
            const SizedBox(height: 10),
          ],
        ],
      ],
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.mint,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: const SizedBox(
          width: 40,
          height: 40,
          child: Icon(Icons.add_rounded, color: AppColors.primary),
        ),
      ),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip({required this.selected, required this.onSelect});

  final DateTime selected;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final start = selected.subtract(Duration(days: selected.weekday - 1));
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var i = 0; i < 7; i++)
          _DayChip(
            day: start.add(Duration(days: i)),
            selected: start.add(Duration(days: i)).day == selected.day &&
                start.add(Duration(days: i)).month == selected.month,
            onTap: () => onSelect(start.add(Duration(days: i))),
          ),
      ],
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.day,
    required this.selected,
    required this.onTap,
  });

  final DateTime day;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              weekdayLetter(day.weekday - 1),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white70 : AppColors.muted,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${day.day}',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: selected ? Colors.white : AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.done, required this.total});

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final message = done == 0
        ? 'Your first check-in is waiting.'
        : done == total
            ? 'You kept every promise today.'
            : "You're halfway there.";
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.mint,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '$done of $total',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _HabitTile extends StatefulWidget {
  const _HabitTile({required this.habit});

  final Habit habit;

  @override
  State<_HabitTile> createState() => _HabitTileState();
}

class _HabitTileState extends State<_HabitTile> {
  double _offset = 0;

  @override
  Widget build(BuildContext context) {
    final habit = widget.habit;
    final store = HabitScope.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final reveal = constraints.maxWidth * 0.25;
        return ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: GestureDetector(
            onHorizontalDragUpdate: (details) {
              setState(() {
                _offset = (_offset + details.delta.dx).clamp(-reveal, 0);
              });
            },
            onHorizontalDragEnd: (_) {
              setState(() => _offset = _offset.abs() > reveal / 2 ? -reveal : 0);
            },
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  right: 0,
                  bottom: 0,
                  width: reveal,
                  child: Material(
                    color: AppColors.error,
                    child: InkWell(
                          onTap: () async {
                            try {
                              await store.remove(habit.id);
                            } on AuthApiException catch (error) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(error.message)),
                              );
                            }
                          },
                      child: const Center(
                        child: Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: Offset(_offset, 0),
                  child: Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          if (_offset != 0) {
            setState(() => _offset = 0);
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => HabitDetailsScreen(habitId: habit.id)),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.mint,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(habit.icon, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      habit.completeOn(store.selectedDay)
                          ? 'Completed today'
                          : '${habit.amountOn(store.selectedDay)} of ${habit.dailyGoal} ${habit.unit} · Daily',
                      style: const TextStyle(color: AppColors.muted, fontSize: 13),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () async {
                  final finishing = !habit.completeOn(store.selectedDay);
                  try {
                    await store.setAmount(
                      habit.id,
                      habit.completeOn(store.selectedDay) ? 0 : habit.dailyGoal,
                    );
                  } on AuthApiException catch (error) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(error.message)),
                    );
                    return;
                  }
                  if (!context.mounted) return;
                  if (finishing) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HabitCompletedScreen(habitId: habit.id),
                      ),
                    );
                  }
                },
                icon: Icon(
                  habit.completeOn(store.selectedDay)
                      ? Icons.check_circle_rounded
                      : Icons.circle_outlined,
                  color: habit.completeOn(store.selectedDay)
                      ? AppColors.primary
                      : AppColors.hint,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmptyToday extends StatelessWidget {
  const _EmptyToday();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.mint,
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Icon(Icons.eco_rounded, color: AppColors.primary, size: 34),
        ),
        const SizedBox(height: 18),
        Text(
          'Every routine starts small.',
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'No habits yet. Choose one simple thing you’d like to make time for.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.muted, height: 1.4),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HabitFormScreen()),
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Create your first habit'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(height: 22),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'A few ideas to get you going',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 10),
        const Row(
          children: [
            _IdeaChip(label: 'Drink water', icon: Icons.water_drop_outlined),
            SizedBox(width: 8),
            _IdeaChip(label: 'Read a little', icon: Icons.menu_book_outlined),
          ],
        ),
      ],
    );
  }
}

class _IdeaChip extends StatelessWidget {
  const _IdeaChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HabitFormScreen(initialName: label, initialIcon: icon),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
