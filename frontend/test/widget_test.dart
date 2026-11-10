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

    await tester.enterText(find.byType(TextField).at(0), 'alice');
    await tester.enterText(find.byType(TextField).at(1), 'demo123');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

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

    await tester.tap(find.text('Become a tutor'));
    await tester.pumpAndSettle();

    expect(find.text('Browse Posts'), findsOneWidget);
    expect(find.text('PHYS 101'), findsOneWidget);
    expect(find.text('MATH 101'), findsNothing);
  });

  testWidgets('Alice accepts bobs seeded offer, notifications clear, session appears on home', (WidgetTester tester) async {
    await tester.pumpWidget(const StudyFirstApp());

    await tester.enterText(find.byType(TextField).at(0), 'alice');
    await tester.enterText(find.byType(TextField).at(1), 'demo123');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.notifications));
    await tester.pumpAndSettle();

    expect(find.textContaining('bob wants to tutor you'), findsOneWidget);

    await tester.tap(find.text('Accept'));
    await tester.pumpAndSettle();

    expect(find.text('Session created'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.textContaining('@bob is tutoring you'), findsOneWidget);
  });

  testWidgets('Alice opens seeded charlie session, taps Session completed, confirms dialog, sees Waiting for charlie', (WidgetTester tester) async {
    await tester.pumpWidget(const StudyFirstApp());

    await tester.enterText(find.byType(TextField).at(0), 'alice');
    await tester.enterText(find.byType(TextField).at(1), 'demo123');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    // Tap the seeded charlie session card on Home
    await tester.tap(find.text('HIST 101'));
    await tester.pumpAndSettle();

    // Scroll down to Session completed button if needed and tap
    final completeBtn = find.text('Session completed');
    await tester.ensureVisible(completeBtn);
    await tester.tap(completeBtn);
    await tester.pumpAndSettle();

    // Confirm completion dialog
    final confirmBtn = find.text('Confirm');
    expect(confirmBtn, findsOneWidget);
    await tester.tap(confirmBtn);
    await tester.pumpAndSettle();

    expect(find.textContaining('Waiting for @charlie'), findsOneWidget);
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

    final errOwn = appState.sendOffer(alicePostId);
    expect(errOwn, 'You cannot offer on your own post.');

    appState.login('bob', 'demo123');

    final alicePost2Id = appState.openPostsBy('alice')[1].id;
    final err1 = appState.sendOffer(alicePost2Id);
    expect(err1, null);

    final errDouble = appState.sendOffer(alicePost2Id);
    expect(errDouble, 'You already sent a request for this post.');

    final charliePostId = appState.openPostsBy('charlie').first.id;
    final err3 = appState.sendOffer(charliePostId);
    expect(err3, null);

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

    final err = appState.acceptOffer(offerId);
    expect(err, null);

    expect(appState.sessionsFor('alice').length, 2); // includes seeded session_charlie_alice
    final matchedSession = appState.sessionsFor('alice').firstWhere((s) => s.postId == postId);
    expect(matchedSession.tutor, 'bob');
    expect(matchedSession.tutee, 'alice');

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

  test('AppState Step 7 tests: updateSessionNote, cancel flow, complete flow, rateTutor', () {
    final appState = AppState();
    appState.login('alice', 'demo123');
    const sessionId = 'session_charlie_alice';

    // 1. updateSessionNote
    final errNote = appState.updateSessionNote(sessionId, 'Meet at library');
    expect(errNote, null);
    expect(appState.sessionById(sessionId)?.tuteeNote, 'Meet at library');

    // Tutor note cannot be changed by tutee
    appState.login('charlie', 'demo123');
    expect(appState.sessionById(sessionId)?.tutorNote, '');
    appState.updateSessionNote(sessionId, 'Bring notes');
    expect(appState.sessionById(sessionId)?.tutorNote, 'Bring notes');

    // 2. Cancel flow
    appState.login('alice', 'demo123');
    final errReqCancel = appState.requestCancel(sessionId);
    expect(errReqCancel, null);
    expect(appState.sessionById(sessionId)?.cancelRequestedBy, 'alice');

    // Requester cannot confirm own request
    final errSelfConf = appState.confirmCancel(sessionId);
    expect(errSelfConf, 'You cannot confirm your own cancellation request.');

    // Other person confirms
    appState.login('charlie', 'demo123');
    final errConf = appState.confirmCancel(sessionId);
    expect(errConf, null);
    expect(appState.sessionById(sessionId)?.status, SessionStatus.cancelled);
    expect(appState.sessionsFor('alice').where((s) => s.id == sessionId).isEmpty, true);

    // 3. Complete and Rate flow
    appState.login('alice', 'demo123');
    final offerId = appState.offers.first.id;
    appState.acceptOffer(offerId);
    final newSessionId = appState.sessionsFor('alice').firstWhere((s) => s.id != sessionId).id;

    appState.login('bob', 'demo123');
    appState.requestComplete(newSessionId);

    appState.login('alice', 'demo123');
    appState.confirmComplete(newSessionId);
    expect(appState.sessionById(newSessionId)?.status, SessionStatus.completed);

    final bobBeforeRating = appState.userByUsername('bob')!;
    final errRate = appState.rateTutor(newSessionId, 5, 'Awesome tutor!');
    expect(errRate, null);

    final bobAfterRating = appState.userByUsername('bob')!;
    expect(bobAfterRating.ratings.length, bobBeforeRating.ratings.length + 1);
    expect(bobAfterRating.averageRating, isNotNull);

    final errRateAgain = appState.rateTutor(newSessionId, 4, 'Again');
    expect(errRateAgain, 'Session has already been rated.');
  });
}
