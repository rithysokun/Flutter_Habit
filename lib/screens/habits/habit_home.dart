import 'package:flutter/material.dart';

import '../../habits/habit_scope.dart';
import '../../theme.dart';
import 'calendar_screen.dart';
import 'profile_screen.dart';
import 'progress_screen.dart';
import 'today_screen.dart';

class HabitHome extends StatelessWidget {
  const HabitHome({super.key, required this.userName, required this.email});

  final String userName;
  final String email;

  @override
  Widget build(BuildContext context) {
    return HabitScope(
      userName: userName,
      email: email,
      child: Navigator(
        onGenerateRoute: (settings) {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => _HomeShell(userName: userName, email: email),
          );
        },
      ),
    );
  }
}

class _HomeShell extends StatefulWidget {
  const _HomeShell({required this.userName, required this.email});

  final String userName;
  final String email;

  @override
  State<_HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<_HomeShell> {
  int _tab = 0;
  late String _name = widget.userName;

  @override
  Widget build(BuildContext context) {
    final pages = [
      TodayScreen(userName: _name),
      const ProgressScreen(),
      const CalendarScreen(),
      ProfileScreen(
        userName: _name,
        email: widget.email,
        onNameChanged: (name) => setState(() => _name = name),
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
            label: 'Today',
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
