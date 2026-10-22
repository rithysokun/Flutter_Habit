import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/auth_controls.dart';

class ResetSuccessScreen extends StatelessWidget {
  const ResetSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BrandLockup(),
          const SizedBox(height: 56),
          Center(
            child: Container(
              width: 92,
              height: 92,
              decoration: const BoxDecoration(
                color: AppColors.mint,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified_user_outlined,
                size: 40,
                color: AppColors.sprout,
              ),
            ),
          ),
          const SizedBox(height: 28),
          Center(
            child: Text(
              'A fresh start,\nsecured.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Password reset successful — preview. You're ready to return to your routine with a fresh start.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              height: 1.45,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: const Column(
              children: [
                Text(
                  'Successful reset demonstration',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: AppColors.text,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'No email was sent and no password was changed in this demo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.4,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),
          PrimaryButton(
            label: 'Back to sign in',
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.signIn,
              (route) => route.settings.name == AppRoutes.welcome,
            ),
          ),
          const SizedBox(height: 12),
          OutlineActionButton(
            label: 'Try another email',
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.forgotPassword,
              (route) => route.settings.name == AppRoutes.welcome,
            ),
          ),
        ],
      ),
    );
  }
}
