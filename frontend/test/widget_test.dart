import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_first/data/app_state.dart';
import 'package:study_first/main.dart';
import 'package:study_first/models/models.dart';

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

  testWidgets('Alice opens Become a tutor and sees other users posts, not her own', (WidgetTester tester) async {
    await tester.pumpWidget(const StudyFirstApp());

    await tester.enterText(find.byType(TextField).at(0), 'alice');
    await tester.enterText(find.byType(TextField).at(1), 'demo123');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    // Tap "Become a tutor"
    await tester.tap(find.text('Become a tutor'));
    await tester.pumpAndSettle();

    expect(find.text('Browse Posts'), findsOneWidget);
    // Bob's post (PHYS 101) should appear
    expect(find.text('PHYS 101'), findsOneWidget);
    // Alice's own posts (MATH 101) should NOT appear in browse posts
    expect(find.text('MATH 101'), findsNothing);
  });

  testWidgets('Alice accepts bobs seeded offer, notifications clear, session appears on home', (WidgetTester tester) async {
    await tester.pumpWidget(const StudyFirstApp());

    // Login as alice (who has a seeded notification from bob)
    await tester.enterText(find.byType(TextField).at(0), 'alice');
    await tester.enterText(find.byType(TextField).at(1), 'demo123');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    // Tap notification bell
    await tester.tap(find.byIcon(Icons.notifications));
    await tester.pumpAndSettle();

    // Verify notification message is shown
    expect(find.textContaining('bob wants to tutor you'), findsOneWidget);

    // Tap Accept button
    await tester.tap(find.text('Accept'));
    await tester.pumpAndSettle();

    // Verify SnackBar "Session created"
    expect(find.text('Session created'), findsOneWidget);

    // Go back to Home
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Verify session card appears on Home
    expect(find.textContaining('is tutoring you'), findsOneWidget);
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

  test('AppState tutor offer rules: own post, duplicate offer, max 3 pending offers', () {
    final appState = AppState();
    appState.login('alice', 'demo123');
    final alicePostId = appState.openPostsBy('alice').first.id;

    // 1. Cannot offer on own post
    final errOwn = appState.sendOffer(alicePostId);
    expect(errOwn, 'You cannot offer on your own post.');

    // Bob logs in
    appState.login('bob', 'demo123');

    final alicePost2Id = appState.openPostsBy('alice')[1].id;
    final err1 = appState.sendOffer(alicePost2Id);
    expect(err1, null);

    // 2. Cannot offer twice on the same post
    final errDouble = appState.sendOffer(alicePost2Id);
    expect(errDouble, 'You already sent a request for this post.');

    // Bob already has offer_1 (on post_1) and err1 (on post_2). Add 3rd pending offer on charlie's post.
    final charliePostId = appState.openPostsBy('charlie').first.id;
    final err3 = appState.sendOffer(charliePostId);
    expect(err3, null);

    // Now bob has 3 pending offers (offer_1, post_2, charliePostId).
    // Let's create a 4th post by charlie to test max 3 pending offers limit
    appState.login('charlie', 'demo123');
    appState.createPost(subject: 'Art', course: 'ART 102', description: 'Help with sculpture');
    final charliePost2Id = appState.openPostsBy('charlie').last.id;

    appState.login('bob', 'demo123');
    final err4 = appState.sendOffer(charliePost2Id);
    expect(err4, 'You can only have 3 pending requests.');
  });

  test('AppState: accepting offer creates active session, matches post, declines other offers', () {
    final appState = AppState();
    appState.login('alice', 'demo123');

    final offerId = appState.offers.first.id;
    final postId = appState.offers.first.postId;

    expect(appState.sessions.isEmpty, true);

    final err = appState.acceptOffer(offerId);
    expect(err, null);

    expect(appState.sessionsFor('alice').length, 1);
    expect(appState.sessionsFor('alice').first.tutor, 'bob');
    expect(appState.sessionsFor('alice').first.tutee, 'alice');

    final post = appState.posts.firstWhere((p) => p.id == postId);
    expect(post.status, PostStatus.matched);
  });

  test('AppState: cancelPost declines pending offers', () {
    final appState = AppState();
    appState.login('alice', 'demo123');
    const postId = 'post_1';

    expect(appState.pendingOffersBy('bob').isNotEmpty, true);

    appState.cancelPost(postId);

    expect(appState.pendingOffersBy('bob').where((o) => o.postId == postId).isEmpty, true);
  });

  test('AppState: contact visible only with active session or own profile', () {
    final appState = AppState();
    appState.login('alice', 'demo123');

    expect(appState.hasActiveSessionBetween('alice', 'bob'), false);

    final offerId = appState.offers.first.id;
    appState.acceptOffer(offerId);

    expect(appState.hasActiveSessionBetween('alice', 'bob'), true);
  });
}
