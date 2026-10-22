import 'package:flutter/material.dart';

import 'screens/create_account_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/reset_success_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/welcome_screen.dart';
import 'theme.dart';

void main() {
  runApp(const HabitFlowApp());
}

class HabitFlowApp extends StatelessWidget {
  const HabitFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HabitFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialRoute: AppRoutes.welcome,
      routes: {
        AppRoutes.welcome: (_) => const WelcomeScreen(),
        AppRoutes.signIn: (_) => const SignInScreen(),
        AppRoutes.createAccount: (_) => const CreateAccountScreen(),
        AppRoutes.forgotPassword: (_) => const ForgotPasswordScreen(),
        AppRoutes.resetSuccess: (_) => const ResetSuccessScreen(),
      },
    );
  }
}
