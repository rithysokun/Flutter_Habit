import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../widgets/user_avatar.dart';

import '../../habits/habit_scope.dart';
import '../../theme.dart';
import 'calendar_screen.dart';
import 'profile_screen.dart';
import 'progress_screen.dart';
import 'today_screen.dart';

class HabitHome extends StatefulWidget {
  const HabitHome({super.key, required this.userName, required this.email});

  final String userName;
  final String email;

  @override
  State<HabitHome> createState() => _HabitHomeState();
}

class _HabitHomeState extends State<HabitHome> {
  final _avatars = AvatarModel();

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  @override
  void dispose() {
    _avatars.dispose();
    super.dispose();
  }

  Future<void> _loadAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('avatar:${widget.email}');
    if (!mounted || avatarById(id) == null) return;
    _avatars.select(id!);
  }

  Future<void> _chooseAvatar(String id) async {
    _avatars.select(id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('avatar:${widget.email}', id);
  }

  @override
  Widget build(BuildContext context) {
    return AvatarScope(
      model: _avatars,
      child: HabitScope(
        userName: widget.userName,
        email: widget.email,
        child: Navigator(
          onGenerateRoute: (settings) {
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => _HomeShell(
                userName: widget.userName,
                email: widget.email,
                onChooseAvatar: _chooseAvatar,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HomeShell extends StatefulWidget {
  const _HomeShell({
    required this.userName,
    required this.email,
    required this.onChooseAvatar,
  });

  final String userName;
  final String email;
  final Future<void> Function(String id) onChooseAvatar;

  @override
  State<_HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<_HomeShell> {
  int _tab = 0;
  late String _name = widget.userName;

  @override
  Widget build(BuildContext context) {
    final avatarId = AvatarScope.of(context).id;
    final pages = [
      TodayScreen(
        userName: _name,
        avatarId: avatarId,
        onOpenProfile: () => setState(() => _tab = 3),
      ),
      const ProgressScreen(),
      const CalendarScreen(),
      ProfileScreen(
        userName: _name,
        email: widget.email,
        avatarId: avatarId,
        onNameChanged: (name) => setState(() => _name = name),
        onChooseAvatar: widget.onChooseAvatar,
      ),
    ];

    return Scaffold(
      body: SafeArea(child: pages[_tab]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        height: 68,
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.mint,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.eco_outlined),
            selectedIcon: Icon(Icons.eco_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart_rounded),
            label: 'Progress',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today_rounded),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
