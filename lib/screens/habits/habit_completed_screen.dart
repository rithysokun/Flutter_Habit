import 'package:flutter/material.dart';

import '../../habits/habit_scope.dart';
import '../../theme.dart';

class HabitCompletedScreen extends StatelessWidget {
  const HabitCompletedScreen({super.key, required this.habitId});

  final String habitId;

  @override
  Widget build(BuildContext context) {
    final store = HabitScope.of(context);
    final matches = store.habits.where((item) => item.id == habitId);
    final habit = matches.isEmpty ? null : matches.first;
    final today = store.habitsFor(store.selectedDay);
    final done = store.completedCount(store.selectedDay);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
              const Spacer(),
              Container(
                width: 140,
                height: 140,
                decoration: const BoxDecoration(
                  color: AppColors.mint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  color: AppColors.primary,
                  size: 64,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'One more promise\nkept to yourself.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                habit == null
                    ? 'Nice work.'
                    : '${habit.name} · complete\nThat’s ${habit.dailyGoal} ${habit.unit.toLowerCase()} of showing up.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted, height: 1.45, fontSize: 16),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  '$done of ${today.length} complete today.',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Back to today'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
