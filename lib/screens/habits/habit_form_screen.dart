import 'package:flutter/material.dart';

import '../../auth/auth_api.dart';
import '../../habits/habit.dart';
import '../../habits/habit_scope.dart';
import '../../theme.dart';

class HabitFormScreen extends StatefulWidget {
  const HabitFormScreen({super.key, this.habitId, this.initialName, this.initialIcon});

  final String? habitId;
  final String? initialName;
  final IconData? initialIcon;

  @override
  State<HabitFormScreen> createState() => _HabitFormScreenState();
}

class _HabitFormScreenState extends State<HabitFormScreen> {
  late final TextEditingController _name;
  late final TextEditingController _goal;
  late List<bool> _days;
  late bool _reminder;
  late TimeOfDay _time;
  late String _unit;
  late IconData _icon;
  String? _description;

  bool get _editing => widget.habitId != null;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initialName ?? '');
    _goal = TextEditingController(text: '20');
    _days = List<bool>.filled(7, true);
    _reminder = false;
    _time = const TimeOfDay(hour: 21, minute: 0);
    _unit = 'Pages';
    _icon = widget.initialIcon ?? Icons.menu_book_outlined;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_editing || _description != null) return;
    final habit = HabitScope.of(context).habits.firstWhere(
      (item) => item.id == widget.habitId,
    );
    _name.text = habit.name;
    _goal.text = '${habit.dailyGoal}';
    _days = List<bool>.from(habit.weekdays);
    _reminder = habit.reminderEnabled;
    _time = habit.reminderTime ?? _time;
    _unit = habit.unit;
    _icon = habit.icon;
    _description = habit.description;
  }

  @override
  void dispose() {
    _name.dispose();
    _goal.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _name.text.trim().isNotEmpty && (int.tryParse(_goal.text) ?? 0) > 0;

  Future<void> _save() async {
    final store = HabitScope.of(context);
    final goal = int.parse(_goal.text);
    try {
      if (_editing) {
        final existing = store.habits.firstWhere((item) => item.id == widget.habitId);
        existing.name = _name.text.trim();
        existing.dailyGoal = goal;
        existing.unit = _unit;
        existing.weekdays = List<bool>.from(_days);
        existing.reminderEnabled = _reminder;
        existing.reminderTime = _reminder ? _time : null;
        existing.icon = _icon;
        await store.update(existing);
      } else {
        await store.add(
          Habit(
            id: '',
            name: _name.text.trim(),
            description: 'A small promise you can keep today.',
            dailyGoal: goal,
            unit: _unit,
            weekdays: List<bool>.from(_days),
            reminderEnabled: _reminder,
            reminderTime: _reminder ? _time : null,
            icon: _icon,
          ),
        );
      }
      if (mounted) Navigator.pop(context);
    } on AuthApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
            Text(
              _editing ? 'Edit your habit' : 'Create a habit',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.mint,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(_icon, color: AppColors.primary),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Icon stays on this phone',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      final index = habitIcons.indexOf(_icon);
                      setState(() {
                        _icon = habitIcons[(index + 1) % habitIcons.length];
                      });
                    },
                    child: const Text('Change'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Habit name', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            TextField(
              controller: _name,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(hintText: 'Read 20 pages'),
            ),
            const SizedBox(height: 16),
            const Text('Daily goal', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _goal,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(hintText: '20'),
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _unit,
                  items: const [
                    DropdownMenuItem(value: 'Pages', child: Text('Pages')),
                    DropdownMenuItem(value: 'glasses', child: Text('Glasses')),
                    DropdownMenuItem(value: 'minutes', child: Text('Minutes')),
                  ],
                  onChanged: (value) => setState(() => _unit = value ?? _unit),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text('Repeat · Every day', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var i = 0; i < 7; i++)
                  GestureDetector(
                    onTap: () => setState(() => _days[i] = !_days[i]),
                    child: Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _days[i] ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _days[i] ? AppColors.primary : AppColors.border,
                        ),
                      ),
                      child: Text(
                        weekdayLetter(i),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: _days[i] ? Colors.white : AppColors.text,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Daily reminder',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(
                _reminder
                    ? formatReminder(_time)
                    : 'Off · no notification is sent',
                style: const TextStyle(color: AppColors.muted),
              ),
              value: _reminder,
              activeThumbColor: AppColors.primary,
              onChanged: (value) async {
                if (value) {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _time,
                  );
                  if (picked != null) _time = picked;
                }
                setState(() => _reminder = value);
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton.icon(
                onPressed: _canSave ? _save : null,
                icon: Icon(_editing ? Icons.check_rounded : Icons.add_rounded),
                label: Text(_editing ? 'Save changes' : 'Create habit'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.disabled,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            if (_editing) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () async {
                  try {
                    await HabitScope.of(context).remove(widget.habitId!);
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    Navigator.pop(context);
                  } on AuthApiException catch (error) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(error.message)),
                    );
                  }
                },
                child: const Text(
                  'Delete habit',
                  style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
