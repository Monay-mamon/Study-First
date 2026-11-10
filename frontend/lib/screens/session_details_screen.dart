import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/app_state.dart';
import '../models/models.dart';
import 'profile_screen.dart';

class SessionDetailsScreen extends StatefulWidget {
  final String sessionId;

  const SessionDetailsScreen({super.key, required this.sessionId});

  @override
  State<SessionDetailsScreen> createState() => _SessionDetailsScreenState();
}

class _SessionDetailsScreenState extends State<SessionDetailsScreen> {
  final _myNoteController = TextEditingController();
  bool _isEditingNote = false;

  @override
  void dispose() {
    _myNoteController.dispose();
    super.dispose();
  }

  void _showReportDialog(BuildContext context) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Report Session / User'),
        content: TextField(
          controller: reasonController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Reason for report',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Report submitted')),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

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

  void _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Back'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              onConfirm();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final session = appState.sessionById(widget.sessionId);
    final currentUser = appState.currentUser;
    final theme = Theme.of(context);

    if (session == null || currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Session Details')),
        body: const Center(child: Text('Session not found.')),
      );
    }

    final isTutor = session.tutor.toLowerCase() == currentUser.username.toLowerCase();
    final otherUsername = isTutor ? session.tutee : session.tutor;
    final otherProfile = appState.userByUsername(otherUsername);
    final myProfile = appState.userByUsername(currentUser.username);

    final tutorProfile = isTutor ? myProfile : otherProfile;
    final tuteeProfile = isTutor ? otherProfile : myProfile;

    if (!_isEditingNote) {
      _myNoteController.text = isTutor ? session.tutorNote : session.tuteeNote;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${session.subject} (${session.course})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flag),
            tooltip: 'Report',
            onPressed: () => _showReportDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header status line
                Card(
                  color: session.status == SessionStatus.active
                      ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                      : session.status == SessionStatus.completed
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Chip(label: Text(session.subject)),
                            const SizedBox(width: 8),
                            Text(
                              session.course,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Created: ${session.createdAt.month}/${session.createdAt.day}/${session.createdAt.year}',
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Status: ${session.status.name.toUpperCase()}${session.rated ? ' (Rated)' : ''}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: session.status == SessionStatus.active
                                ? theme.colorScheme.primary
                                : session.status == SessionStatus.completed
                                    ? Colors.green
                                    : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Profile Cards (Tutor & Tutee)
                Row(
                  children: [
                    Expanded(
                      child: _buildProfileCard(
                        context,
                        title: 'Tutor',
                        profile: tutorProfile,
                        username: session.tutor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildProfileCard(
                        context,
                        title: 'Tutee',
                        profile: tuteeProfile,
                        username: session.tutee,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Notes Section
                Text(
                  "Tutor's Note",
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                _buildNoteBox(
                  context,
                  note: session.tutorNote,
                  isOwn: isTutor,
                  sessionId: session.id,
                ),
                const SizedBox(height: 16),
                Text(
                  "Tutee's Note",
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                _buildNoteBox(
                  context,
                  note: session.tuteeNote,
                  isOwn: !isTutor,
                  sessionId: session.id,
                ),
                const SizedBox(height: 8),
                Text(
                  'Agree on where and when here, then continue in your messaging app.',
                  style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 32),
                // Actions depending on state
                if (session.status != SessionStatus.active) ...[
                  Center(
                    child: Text(
                      'This session is ${session.status.name}. No further actions available.',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                  ),
                ] else ...[
                  if (session.cancelRequestedBy != null) ...[
                    if (session.cancelRequestedBy!.toLowerCase() == currentUser.username.toLowerCase()) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Waiting for @$otherUsername to confirm cancellation',
                              style: TextStyle(color: theme.colorScheme.onErrorContainer, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: () {
                                appState.withdrawCancelRequest(session.id);
                              },
                              child: const Text('Withdraw request'),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '@$otherUsername wants to cancel this session',
                              style: TextStyle(color: theme.colorScheme.onErrorContainer, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                OutlinedButton(
                                  onPressed: () {
                                    appState.declineCancel(session.id);
                                  },
                                  child: const Text('Keep session'),
                                ),
                                const SizedBox(width: 16),
                                FilledButton(
                                  onPressed: () {
                                    appState.confirmCancel(session.id);
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Session cancelled')),
                                    );
                                  },
                                  child: const Text('Confirm cancellation'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ] else if (session.completeRequestedBy != null) ...[
                    if (session.completeRequestedBy!.toLowerCase() == currentUser.username.toLowerCase()) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.tertiaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Waiting for @$otherUsername to confirm completion',
                              style: TextStyle(color: theme.colorScheme.onTertiaryContainer, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: () {
                                appState.withdrawCompleteRequest(session.id);
                              },
                              child: const Text('Withdraw request'),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.tertiaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '@$otherUsername marked this session as completed',
                              style: TextStyle(color: theme.colorScheme.onTertiaryContainer, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                OutlinedButton(
                                  onPressed: () {
                                    appState.withdrawCompleteRequest(session.id);
                                  },
                                  child: const Text('Not yet'),
                                ),
                                const SizedBox(width: 16),
                                FilledButton(
                                  onPressed: () {
                                    appState.confirmComplete(session.id);
                                    if (isTutor) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Session completed')),
                                      );
                                    } else {
                                      _showRatingDialog(context, session);
                                    }
                                  },
                                  child: const Text('Confirm completed'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _showConfirmDialog(
                                context,
                                title: 'Cancel Session',
                                content: 'Are you sure you want to request cancellation of this session?',
                                onConfirm: () {
                                  appState.requestCancel(session.id);
                                },
                              );
                            },
                            child: const Text('Cancel session'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              _showConfirmDialog(
                                context,
                                title: 'Complete Session',
                                content: 'Are you sure you want to mark this session as completed?',
                                onConfirm: () {
                                  appState.requestComplete(session.id);
                                },
                              );
                            },
                            child: const Text('Session completed'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(
    BuildContext context, {
    required String title,
    required UserProfile? profile,
    required String username,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary)),
            const SizedBox(height: 4),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(username: username),
                  ),
                );
              },
              child: Text(
                '@$username',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: theme.colorScheme.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              profile != null
                  ? (profile.averageRating != null
                      ? '${profile.averageRating!.toStringAsFixed(1)} ★'
                      : 'No ratings')
                  : '',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Text(
              profile?.contact.isNotEmpty == true ? 'Contact: ${profile!.contact}' : 'No contact info',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteBox(
    BuildContext context, {
    required String note,
    required bool isOwn,
    required String sessionId,
  }) {
    final theme = Theme.of(context);
    final appState = Provider.of<AppState>(context, listen: false);

    if (isOwn) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _myNoteController,
            maxLines: 2,
            maxLength: 200,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter your note here...',
            ),
            onChanged: (_) {
              setState(() {
                _isEditingNote = true;
              });
            },
          ),
          if (_isEditingNote) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonal(
                onPressed: () {
                  final error = appState.updateSessionNote(sessionId, _myNoteController.text);
                  setState(() {
                    _isEditingNote = false;
                  });
                  if (error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(error)),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Note updated')),
                    );
                  }
                },
                child: const Text('Save Note'),
              ),
            ),
          ],
        ],
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          note.isNotEmpty ? note : 'No note provided yet.',
          style: theme.textTheme.bodyMedium,
        ),
      );
    }
  }
}
