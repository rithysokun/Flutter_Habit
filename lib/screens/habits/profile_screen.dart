import 'package:flutter/material.dart';

import '../../auth/auth_api.dart';
import '../../habits/habit_scope.dart';
import '../../theme.dart';
import '../welcome_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.userName,
    required this.email,
    required this.onNameChanged,
  });

  final String userName;
  final String email;
  final ValueChanged<String> onNameChanged;

  @override
  Widget build(BuildContext context) {
    final store = HabitScope.of(context);
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month);
    var habitsThisMonth = 0;
    for (final habit in store.habits) {
      for (final key in habit.amounts.keys) {
        final parts = key.split('-');
        if (parts.length != 3) continue;
        final day = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
        if (!day.isBefore(monthStart) && habit.completeOn(day)) {
          habitsThisMonth++;
        }
      }
    }
    final initials = _initials(userName);
    final since = _monthYear(now);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        const Text(
          'MY PROFILE',
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w800,
            color: AppColors.muted,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your little corner.',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 20),
        Center(
          child: CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.mint,
            child: Text(
              initials,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          userName,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.muted),
        ),
        const SizedBox(height: 10),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.mint,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Growing since $since',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _Stat(value: '$habitsThisMonth', label: 'Habits this month'),
            const SizedBox(width: 12),
            _Stat(value: '${store.habits.length}', label: 'Habits saved'),
          ],
        ),
        const SizedBox(height: 18),
        _MenuTile(
          icon: Icons.person_outline_rounded,
          label: 'Edit name',
          detail: userName,
          onTap: () => _open(
            context,
            EditNameScreen(
              userName: userName,
              email: email,
              onNameChanged: onNameChanged,
            ),
          ),
        ),
        _MenuTile(
          icon: Icons.settings_outlined,
          label: 'Settings',
          onTap: () => _open(context, const SettingsScreen()),
        ),
        _MenuTile(
          icon: Icons.help_outline_rounded,
          label: 'Help & support',
          onTap: () => _open(
            context,
            const _InfoPage(
              title: 'Help & support',
              body:
                  'HabitFlow is a demo on this phone. Habits you check off stay for this sign-in session.',
            ),
          ),
        ),
      ],
    );
  }

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }
}

class EditNameScreen extends StatefulWidget {
  const EditNameScreen({
    super.key,
    required this.userName,
    required this.email,
    required this.onNameChanged,
  });

  final String userName;
  final String email;
  final ValueChanged<String> onNameChanged;

  @override
  State<EditNameScreen> createState() => _EditNameScreenState();
}

class _EditNameScreenState extends State<EditNameScreen> {
  late final TextEditingController _name = TextEditingController(text: widget.userName);
  final _auth = AuthApi();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Enter your name.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final user = await _auth.updateName(email: widget.email, name: name);
      if (!mounted) return;
      widget.onNameChanged(user.name);
      Navigator.pop(context);
    } on AuthApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              Text('Edit name', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                widget.email,
                style: const TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 16),
              const Text('Your name', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              TextField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(hintText: 'Alex Morgan'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(
                  _error!,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _busy ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(_busy ? 'Saving...' : 'Save name'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            const Text(
              'SETTINGS',
              style: TextStyle(
                fontSize: 12,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w800,
                color: AppColors.muted,
              ),
            ),
            const SizedBox(height: 8),
            Text('Make it yours.', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 18),
            const Text('Your preferences', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            _MenuTile(
              icon: Icons.notifications_none_rounded,
              label: 'Reminders',
              detail: 'A gentle nudge, on your terms',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => const ReminderScreen()),
              ),
            ),
            const _MenuTile(
              icon: Icons.wb_sunny_outlined,
              label: 'Appearance',
              detail: 'Light',
            ),
            const _MenuTile(
              icon: Icons.calendar_today_outlined,
              label: 'Week starts on',
              detail: 'Monday',
            ),
            const SizedBox(height: 16),
            const Text('Account & privacy', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            _MenuTile(
              icon: Icons.lock_outline_rounded,
              label: 'Password & security',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const _InfoPage(
                    title: 'Password & security',
                    body:
                        'Your password is stored as a hash. This demo does not change it from the phone.',
                  ),
                ),
              ),
            ),
            _MenuTile(
              icon: Icons.shield_outlined,
              label: 'Privacy policy',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const _InfoPage(
                    title: 'Privacy policy',
                    body:
                        'HabitFlow keeps your name, email, and password hash in habitdb. Habit check-ins on this phone are not uploaded.',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                  MaterialPageRoute<void>(builder: (_) => const WelcomeScreen()),
                  (route) => false,
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.mintDeep),
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Sign out',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  bool _habitReminders = true;
  bool _dailyCheckIn = true;
  bool _quietHours = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            const Text(
              'REMINDER PREFERENCES',
              style: TextStyle(
                fontSize: 12,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w800,
                color: AppColors.muted,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'A gentle reminder.',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose when HabitFlow may nudge you. No notification is sent in this demo.',
              style: TextStyle(color: AppColors.muted, height: 1.4),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Habit reminders', style: TextStyle(fontWeight: FontWeight.w800)),
              subtitle: const Text('Show your scheduled nudges'),
              value: _habitReminders,
              activeThumbColor: AppColors.primary,
              onChanged: (value) => setState(() => _habitReminders = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Daily check-in', style: TextStyle(fontWeight: FontWeight.w800)),
              subtitle: const Text('A moment to reflect · 9:00 PM'),
              value: _dailyCheckIn,
              activeThumbColor: AppColors.primary,
              onChanged: (value) => setState(() => _dailyCheckIn = value),
            ),
            const SizedBox(height: 8),
            const Text('Room to switch off', style: TextStyle(fontWeight: FontWeight.w800)),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Quiet hours', style: TextStyle(fontWeight: FontWeight.w800)),
              subtitle: const Text('Pause reminders overnight · 10 PM – 7 AM'),
              value: _quietHours,
              activeThumbColor: AppColors.primary,
              onChanged: (value) => setState(() => _quietHours = value),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Save preferences'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoPage extends StatelessWidget {
  const _InfoPage({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              Text(body, style: const TextStyle(height: 1.45, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    this.detail,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? detail;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
                      if (detail != null)
                        Text(
                          detail!,
                          style: const TextStyle(color: AppColors.muted, fontSize: 13),
                        ),
                    ],
                  ),
                ),
                if (onTap != null)
                  const Icon(Icons.chevron_right_rounded, color: AppColors.hint),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

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
            Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty);
  final letters = parts.map((part) => part[0]).take(2).join();
  return letters.isEmpty ? 'H' : letters.toUpperCase();
}

String _monthYear(DateTime day) {
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
  return '${months[day.month - 1]} ${day.year}';
}
