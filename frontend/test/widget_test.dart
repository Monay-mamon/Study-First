import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_first/data/app_state.dart';
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

  testWidgets('Alice can open Need a tutor screen and see post form', (WidgetTester tester) async {
    await tester.pumpWidget(const StudyFirstApp());

    await tester.enterText(find.byType(TextField).at(0), 'alice');
    await tester.enterText(find.byType(TextField).at(1), 'demo123');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    // Tap "Need a tutor"
    await tester.tap(find.text('Need a tutor'));
    await tester.pumpAndSettle();

    expect(find.text('Post a Help Request'), findsOneWidget);
    expect(find.text('Post request'), findsOneWidget);
  });

  test('AppState enforces maximum of 3 open posts per user', () {
    final appState = AppState();
    appState.register('student1', 'pass123');

    for (int i = 1; i <= 3; i++) {
      final error = appState.createPost(
        subject: 'Math',
        course: 'MATH 10$i',
        description: 'Need help with topic $i',
      );
      expect(error, null);
    }

    expect(appState.openPostsBy('student1').length, 3);

    final error4 = appState.createPost(
      subject: 'Math',
      course: 'MATH 104',
      description: 'Need help with topic 4',
    );
    expect(error4, 'You can only have 3 open requests.');
  });
}
