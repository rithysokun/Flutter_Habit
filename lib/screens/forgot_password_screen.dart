import 'package:flutter/material.dart';

import '../auth/auth_utils.dart';
import '../theme.dart';
import '../widgets/auth_controls.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canPreview = isValidEmail(_email.text);

    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AuthTopBar(onBack: () => Navigator.pop(context)),
          const SizedBox(height: 20),
          const Eyebrow('Reset your password'),
          const SizedBox(height: 10),
          Text(
            'A fresh start.',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.mint,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.vpn_key_outlined,
              color: AppColors.sprout,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            "It happens. Enter your email and we'll show you the next step to getting back into your routine.",
            style: TextStyle(
              fontSize: 16,
              height: 1.45,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 24),
          LabeledField(
            label: 'Email address',
            helper: 'Use the email associated with your account.',
            child: AppTextField(
              controller: _email,
              hint: 'alex.morgan@email.com',
              prefixIcon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Preview reset confirmation',
            onPressed: canPreview
                ? () => Navigator.pushNamed(
                    context,
                    AppRoutes.resetSuccess,
                    arguments: _email.text.trim(),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          const InfoBanner(
            title: 'No email will be sent',
            body:
                'Password recovery is a visual demonstration, not a connected service.',
          ),
          const SizedBox(height: 16),
          OutlineActionButton(
            label: 'Back to sign in',
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.signIn,
              (route) => route.settings.name == AppRoutes.welcome,
            ),
          ),
        ],
      ),
    );
  }
}
