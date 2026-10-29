import 'package:flutter/material.dart';

import '../theme.dart';

class AvatarChoice {
  const AvatarChoice({
    required this.id,
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final String id;
  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
}

const avatarChoices = <AvatarChoice>[
  AvatarChoice(
    id: 'sprout',
    label: 'Sprout',
    icon: Icons.eco_rounded,
    background: AppColors.mint,
    foreground: AppColors.primary,
  ),
  AvatarChoice(
    id: 'reader',
    label: 'Reader',
    icon: Icons.menu_book_rounded,
    background: Color(0xFFE7F0E4),
    foreground: Color(0xFF166534),
  ),
  AvatarChoice(
    id: 'drop',
    label: 'Drop',
    icon: Icons.water_drop_rounded,
    background: Color(0xFFE6F4F1),
    foreground: Color(0xFF0F766E),
  ),
  AvatarChoice(
    id: 'walker',
    label: 'Walker',
    icon: Icons.directions_walk_rounded,
    background: Color(0xFFFFF4E5),
    foreground: Color(0xFFC2410C),
  ),
];

AvatarChoice? avatarById(String? id) {
  for (final choice in avatarChoices) {
    if (choice.id == id) return choice;
  }
  return null;
}

class AvatarModel extends ChangeNotifier {
  String? id;

  void select(String next) {
    id = next;
    notifyListeners();
  }
}

class AvatarScope extends InheritedNotifier<AvatarModel> {
  const AvatarScope({super.key, required AvatarModel model, required super.child})
      : super(notifier: model);

  static AvatarModel of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AvatarScope>();
    assert(scope != null, 'AvatarScope not found');
    return scope!.notifier!;
  }
}

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.name,
    this.avatarId,
    this.radius = 22,
  });

  final String name;
  final String? avatarId;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final choice = avatarById(avatarId);
    return CircleAvatar(
      radius: radius,
      backgroundColor: choice?.background ?? AppColors.mint,
      child: choice == null
          ? Text(
              _initials(name),
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                fontSize: radius * 0.7,
              ),
            )
          : Icon(choice.icon, color: choice.foreground, size: radius),
    );
  }
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty);
  final letters = parts.map((part) => part[0]).take(2).join();
  return letters.isEmpty ? 'H' : letters.toUpperCase();
}
