import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/auth_controls.dart';
import '../widgets/sprout_card.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BrandLockup(),
          const SizedBox(height: 28),
          const SproutCard(),
          const SizedBox(height: 32),
          Text(
            'Better days start\nwith small habits.',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 12),
          const Text(
            'Build a routine that feels like you. Find your rhythm, one day at a time.',
            style: TextStyle(
              fontSize: 16,
              height: 1.45,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 36),
          PrimaryButton(
            label: 'Start your journey',
            icon: Icons.arrow_forward_rounded,
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.createAccount),
          ),
          const SizedBox(height: 12),
          OutlineActionButton(
            label: 'I already have an account',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.signIn),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'A little consistency goes a long way.\nDemo experience · no account is created.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.4,
                color: AppColors.hint,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
