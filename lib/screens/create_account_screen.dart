import 'package:flutter/material.dart';

import '../auth/auth_api.dart';
import '../auth/auth_utils.dart';
import '../theme.dart';
import '../widgets/auth_controls.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _auth = AuthApi();
  bool _obscure = true;
  bool _agreed = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  bool get _emailInvalid =>
      _email.text.isNotEmpty && !isValidEmail(_email.text);

  PasswordCheck get _passwordCheck =>
      checkPassword(_password.text, name: _name.text);

  bool get _canSubmit =>
      !_busy &&
      _name.text.trim().isNotEmpty &&
      isValidEmail(_email.text) &&
      _passwordCheck.isStrong &&
      _agreed;

  Future<void> _createAccount() async {
    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      await _auth.createAccount(
        name: _name.text,
        email: _email.text,
        password: _password.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created. Sign in to continue.')),
      );
      Navigator.pushReplacementNamed(context, AppRoutes.signIn);
    } on AuthApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final password = _passwordCheck;

    return AuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AuthTopBar(onBack: () => Navigator.pop(context)),
          const SizedBox(height: 20),
          const Eyebrow('Create your account'),
          const SizedBox(height: 10),
          Text(
            'Make room for better.',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          LabeledField(
            label: 'Your name',
            child: AppTextField(
              controller: _name,
              hint: 'Alex Morgan',
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 18),
          LabeledField(
            label: 'Email address',
            helper: _emailInvalid
                ? 'Enter a full email, like alex.morgan@example.com.'
                : null,
            helperColor: AppColors.error,
            child: AppTextField(
              controller: _email,
              hint: 'alex.morgan@email.com',
              keyboardType: TextInputType.emailAddress,
              hasError: _emailInvalid,
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 18),
          LabeledField(
            label: 'Password',
            helper:
                'Use 8+ characters with a number and a symbol. Avoid names or reused passwords.',
            child: AppTextField(
              controller: _password,
              hint: '••••••••••••',
              obscureText: _obscure,
              onChanged: (_) => setState(() {}),
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
          if (_password.text.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  password.isStrong
                      ? Icons.check_circle_rounded
                      : Icons.info_outline_rounded,
                  size: 18,
                  color: password.isStrong
                      ? AppColors.primary
                      : AppColors.muted,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    password.isStrong
                        ? 'Strong password · all requirements met'
                        : 'Keep going — add length, a number, and a symbol.',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: password.isStrong
                          ? AppColors.primary
                          : AppColors.muted,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => setState(() => _agreed = !_agreed),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _agreed,
                  onChanged: (value) =>
                      setState(() => _agreed = value ?? false),
                  fillColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppColors.primary;
                    }
                    return Colors.white;
                  }),
                  checkColor: Colors.white,
                  side: const BorderSide(color: AppColors.border, width: 1.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text.rich(
                      TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: AppColors.text,
                        ),
                        children: [
                          TextSpan(text: 'I agree to the '),
                          TextSpan(
                            text: 'Terms of Service',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                          TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: _busy ? 'Creating account...' : 'Create account',
            onPressed: _canSubmit ? _createAccount : null,
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
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
          if (_emailInvalid) ...[
            const SizedBox(height: 10),
            const Text(
              'Fix your email to continue.',
              style: TextStyle(fontSize: 13, color: AppColors.muted),
            ),
          ],
          const SizedBox(height: 24),
          TextActionRow(
            prompt: 'Already have an account? ',
            action: 'Sign in',
            onTap: () => Navigator.pushNamed(context, AppRoutes.signIn),
          ),
        ],
      ),
    );
  }
}
