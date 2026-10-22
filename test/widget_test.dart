import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_app/main.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('Welcome screen shows HabitFlow auth front page', (tester) async {
    await tester.pumpWidget(const HabitFlowApp());

    expect(find.text('HabitFlow'), findsOneWidget);
    expect(find.textContaining('Better days start'), findsOneWidget);
    expect(find.text('Start your journey'), findsOneWidget);
    expect(find.text('I already have an account'), findsOneWidget);
  });

  testWidgets('Existing account opens sign in', (tester) async {
    await tester.pumpWidget(const HabitFlowApp());

    await tester.ensureVisible(find.text('I already have an account'));
    await tester.tap(find.text('I already have an account'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back.'), findsOneWidget);
    expect(find.text('Sign in'), findsWidgets);
  });

  testWidgets('Start your journey opens create account', (tester) async {
    await tester.pumpWidget(const HabitFlowApp());

    await tester.ensureVisible(find.text('Start your journey'));
    await tester.tap(find.text('Start your journey'));
    await tester.pumpAndSettle();

    expect(find.text('Make room for better.'), findsOneWidget);
  });
}
