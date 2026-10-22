import 'package:flutter/material.dart';

import '../auth/auth_api.dart';
import '../theme.dart';
import '../widgets/auth_controls.dart';
import 'habits/habit_home.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _auth = AuthApi();
  bool _obscure = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Enter your email and password.');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final user = await _auth.signIn(email: email, password: password);
      if (!mounted) return;
      final name = user.name.trim().isEmpty ? 'there' : user.name.trim();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => HabitHome(userName: name, email: user.email),
        ),
        (route) => false,
      );
    } on AuthApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AuthTopBar(
            centerBrand: true,
            onBack: () => Navigator.pop(context),
          ),
          const SizedBox(height: 28),
          const Eyebrow('Your next small step'),
          const SizedBox(height: 10),
          Text(
            'Welcome back.',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          const Text(
            "Your habits are waiting. Let's pick up where you left off.",
            style: TextStyle(
              fontSize: 16,
              height: 1.45,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 28),
          LabeledField(
            label: 'Email address',
            child: AppTextField(
              controller: _email,
              hint: 'alex.morgan@email.com',
              prefixIcon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
            ),
          ),
          const SizedBox(height: 18),
          LabeledField(
            label: 'Password',
            helper: 'Your password is hidden for privacy.',
            child: AppTextField(
              controller: _password,
              hint: '••••••••••••',
              obscureText: _obscure,
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.muted,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.forgotPassword),
              child: const Text(
                'Forgot password?',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          PrimaryButton(
            label: _busy ? 'Signing in...' : 'Sign in',
            onPressed: _busy ? null : _signIn,
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
                color: AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 24),
          TextActionRow(
            prompt: 'New here? ',
            action: 'Create an account',
            onTap: () => Navigator.pushNamed(context, AppRoutes.createAccount),
          ),
        ],
      ),
    );
  }
}
