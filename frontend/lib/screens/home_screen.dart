import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/app_state.dart';
import '../models/models.dart';
import 'browse_posts_screen.dart';
import 'need_tutor_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'session_details_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showRatingDialog(BuildContext context, TutoringSession session) {
    int selectedStars = 0;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Rate Tutor @${session.tutor}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (index) => IconButton(
                      icon: Icon(
                        index < selectedStars ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 32,
                      ),
                      onPressed: () {
                        setDialogState(() {
                          selectedStars = index + 1;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: commentController,
                  maxLines: 3,
                  maxLength: 200,
                  decoration: const InputDecoration(
                    labelText: 'Optional comment',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            FilledButton(
              onPressed: selectedStars == 0
                  ? null
                  : () {
                      final appState = Provider.of<AppState>(context, listen: false);
                      final error = appState.rateTutor(
                        session.id,
                        selectedStars,
                        commentController.text,
                      );
                      Navigator.pop(dialogContext);
                      if (error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error)),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Thanks for rating')),
                        );
                      }
                    },
              child: const Text('Submit rating'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final currentUser = appState.currentUser;
    final theme = Theme.of(context);

    final unreadCount = currentUser != null ? appState.unreadCountFor(currentUser.username) : 0;
    final List<TutoringSession> userSessions = currentUser != null ? appState.sessionsFor(currentUser.username) : [];
    final List<TutoringSession> sessionsToRateList = currentUser != null ? appState.sessionsToRate(currentUser.username) : [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study First'),
        actions: [
          if (currentUser != null) ...[
            Badge(
              isLabelVisible: unreadCount > 0,
              label: Text('$unreadCount'),
              child: IconButton(
                icon: const Icon(Icons.notifications),
                tooltip: 'Notifications',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationsScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.person),
              tooltip: 'My Profile',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(username: currentUser.username),
                  ),
                );
              },
            ),
          ],
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => appState.logout(),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Middle: My Sessions Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Sessions',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: (userSessions.isEmpty && sessionsToRateList.isEmpty)
                        ? Center(
                            child: Card(
                              elevation: 0,
                              color: theme.colorScheme.surfaceContainerHighest
                                  .withOpacity(0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(32.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.event_note,
                                        size: 48, color: Colors.grey),
                                    SizedBox(height: 16),
                                    Text(
                                      'No sessions yet. Become a tutor or request one below.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : ListView(
                            children: [
                              if (userSessions.isNotEmpty) ...[
                                const Text(
                                  'Active Sessions',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                                ),
                                const SizedBox(height: 8),
                                ...userSessions.map((session) {
                                  final isTutor = session.tutor.toLowerCase() ==
                                      currentUser!.username.toLowerCase();
                                  final otherUser =
                                      isTutor ? session.tutee : session.tutor;
                                  final roleText = isTutor
                                      ? 'You are tutoring @$otherUser'
                                      : '@$otherUser is tutoring you';

                                  String? pendingTag;
                                  if (session.cancelRequestedBy != null) {
                                    pendingTag = 'Cancel requested';
                                  } else if (session.completeRequestedBy != null) {
                                    pendingTag = 'Completion requested';
                                  }

                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    elevation: 2,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => SessionDetailsScreen(sessionId: session.id),
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Chip(
                                                  label: Text(session.subject),
                                                  backgroundColor: theme
                                                      .colorScheme
                                                      .primaryContainer,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  session.course,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const Spacer(),
                                                if (pendingTag != null)
                                                  Chip(
                                                    label: Text(pendingTag),
                                                    backgroundColor: theme.colorScheme.errorContainer,
                                                    labelStyle: TextStyle(
                                                      color: theme.colorScheme.onErrorContainer,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              roleText,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: theme.colorScheme.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                              if (sessionsToRateList.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                const Text(
                                  'Rate your tutor',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                                ),
                                const SizedBox(height: 8),
                                ...sessionsToRateList.map((session) {
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    color: theme.colorScheme.secondaryContainer.withOpacity(0.3),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${session.subject} (${session.course})',
                                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                                ),
                                                const SizedBox(height: 4),
                                                Text('Tutor: @${session.tutor}'),
                                              ],
                                            ),
                                          ),
                                          FilledButton.icon(
                                            onPressed: () => _showRatingDialog(context, session),
                                            icon: const Icon(Icons.star, size: 16),
                                            label: const Text('Rate'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom: Pinned Action Buttons
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BrowsePostsScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.school),
                      label: const Text('Become a tutor'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NeedTutorScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.help_outline),
                      label: const Text('Need a tutor'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
