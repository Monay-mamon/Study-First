import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_first/main.dart';

void main() {
  testWidgets('Study First app starts with AuthScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const StudyFirstApp());

    expect(find.text('Study First'), findsWidgets);
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('Login with demo user alice shows HomeScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const StudyFirstApp());

    // Enter username alice
    await tester.enterText(find.byType(TextField).at(0), 'alice');
    // Enter password demo123
    await tester.enterText(find.byType(TextField).at(1), 'demo123');

    // Tap Login button
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    // Verify HomeScreen is shown
    expect(find.text('My Sessions'), findsOneWidget);
    expect(find.text('Become a tutor'), findsOneWidget);
    expect(find.text('Need a tutor'), findsOneWidget);
  });
}
