import 'package:flutter/material.dart';

import '../../auth/auth_api.dart';
import '../../habits/habit.dart';
import '../../habits/habit_scope.dart';
import '../../theme.dart';
import 'habit_completed_screen.dart';
import 'habit_form_screen.dart';

class HabitDetailsScreen extends StatelessWidget {
  const HabitDetailsScreen({super.key, required this.habitId});

  final String habitId;

  @override
  Widget build(BuildContext context) {
    final store = HabitScope.of(context);
    final matches = store.habits.where((item) => item.id == habitId);
    if (matches.isEmpty) {
      return const Scaffold(body: SizedBox.shrink());
    }
    final habit = matches.first;
    final day = store.selectedDay;
    final amount = habit.amountOn(day);
    final monthTotal = amount;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HabitFormScreen(habitId: habit.id),
                      ),
                    ),
                    child: const Text('Edit'),
                  ),
                ],
              ),
              Text(habit.name, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 6),
              Text(
                habit.description,
                style: const TextStyle(color: AppColors.muted, height: 1.4),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.mint,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Every day',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text(
                    "Today's goal",
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const Spacer(),
                  Text(
                    '$amount / ${habit.dailyGoal} ${habit.unit.toLowerCase()}',
                    style: const TextStyle(color: AppColors.muted),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: habit.dailyGoal == 0
                      ? 0
                      : (amount / habit.dailyGoal).clamp(0, 1),
                  backgroundColor: AppColors.mint,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _StatCard(
                    value: habit.completeOn(day) ? '1' : '0',
                    label: 'Day streak',
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    value: '$monthTotal',
                    label: '${habit.unit} so far',
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text('Your routine', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Row(
                children: [
                  for (var i = 0; i < 7; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        weekdayLetter(i),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: habit.weekdays[i] ? AppColors.primary : AppColors.hint,
                        ),
                      ),
                    ),
                ],
              ),
              if (habit.reminderEnabled && habit.reminderTime != null) ...[
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.notifications_none_rounded, color: AppColors.primary),
                  title: const Text('Reminder'),
                  trailing: Text(formatReminder(habit.reminderTime!)),
                ),
              ],
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  onPressed: habit.completeOn(day)
                      ? null
                      : () async {
                          try {
                            await store.setAmount(habit.id, habit.dailyGoal);
                          } on AuthApiException catch (error) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(error.message)),
                            );
                            return;
                          }
                          if (!context.mounted) return;
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HabitCompletedScreen(habitId: habit.id),
                            ),
                          );
                        },
                  icon: const Icon(Icons.check_rounded),
                  label: Text(
                    habit.completeOn(day) ? 'Completed' : 'Mark as complete',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.disabled,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: AppColors.muted)),
          ],
        ),
      ),
    );
  }
}
