import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/app_state.dart';
import '../models/models.dart';
import 'profile_screen.dart';
import 'session_details_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppState>(context, listen: false);
      final user = appState.currentUser;
      if (user != null) {
        appState.markAllRead(user.username);
      }
    });
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

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final currentUser = appState.currentUser;
    final theme = Theme.of(context);

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Not logged in.')),
      );
    }

    final notifications = appState.notificationsFor(currentUser.username);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Text(
                'No notifications yet.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];

                TutorOffer? offer;
                if (notif.offerId != null) {
                  offer = appState.offers.cast<TutorOffer?>().firstWhere(
                        (o) => o?.id == notif.offerId,
                        orElse: () => null,
                      );
                }

                TutoringSession? session;
                if (notif.sessionId != null) {
                  session = appState.sessionById(notif.sessionId!);
                }

                final isPendingOffer = notif.type == NotificationType.newOffer &&
                    offer?.status == OfferStatus.pending;

                String? tutorUsername;
                if (isPendingOffer && offer != null) {
                  tutorUsername = offer.tutor;
                }

                IconData iconData;
                Color iconColor;
                switch (notif.type) {
                  case NotificationType.offerAccepted:
                  case NotificationType.cancelConfirmed:
                    iconData = Icons.check_circle;
                    iconColor = Colors.green;
                    break;
                  case NotificationType.offerDeclined:
                  case NotificationType.cancelDeclined:
                    iconData = Icons.cancel;
                    iconColor = Colors.red;
                    break;
                  case NotificationType.cancelRequested:
                    iconData = Icons.warning;
                    iconColor = Colors.orange;
                    break;
                  case NotificationType.completeRequested:
                  case NotificationType.sessionCompleted:
                    iconData = Icons.task_alt;
                    iconColor = theme.colorScheme.primary;
                    break;
                  default:
                    iconData = Icons.notifications;
                    iconColor = theme.colorScheme.primary;
                }

                final canOpenSession = notif.sessionId != null &&
                    session != null &&
                    session.status == SessionStatus.active;

                final showRateButton = notif.type == NotificationType.sessionCompleted &&
                    session?.rated == false &&
                    session?.tutee.toLowerCase() == currentUser.username.toLowerCase();

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: notif.read
                      ? theme.colorScheme.surface
                      : theme.colorScheme.primaryContainer.withOpacity(0.2),
                  elevation: notif.read ? 1 : 2,
                  child: InkWell(
                    onTap: canOpenSession
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SessionDetailsScreen(sessionId: notif.sessionId!),
                              ),
                            );
                          }
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(iconData, color: iconColor, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                '${notif.createdAt.month}/${notif.createdAt.day} ${notif.createdAt.hour.toString().padLeft(2, '0')}:${notif.createdAt.minute.toString().padLeft(2, '0')}',
                                style: theme.textTheme.bodySmall,
                              ),
                              if (canOpenSession) ...[
                                const Spacer(),
                                const Text(
                                  'Tap to view session',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (isPendingOffer && tutorUsername != null) ...[
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ProfileScreen(username: tutorUsername!),
                                  ),
                                );
                              },
                              child: Text(
                                notif.message,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: theme.colorScheme.primary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ] else ...[
                            Text(
                              notif.message,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                          if (isPendingOffer && notif.offerId != null) ...[
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton(
                                  onPressed: () {
                                    final error = appState.declineOffer(notif.offerId!);
                                    if (error != null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(error)),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Request declined')),
                                      );
                                    }
                                  },
                                  child: const Text('Decline'),
                                ),
                                const SizedBox(width: 12),
                                FilledButton(
                                  onPressed: () {
                                    final error = appState.acceptOffer(notif.offerId!);
                                    if (error != null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(error)),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Session created')),
                                      );
                                    }
                                  },
                                  child: const Text('Accept'),
                                ),
                              ],
                            ),
                          ],
                          if (showRateButton && session != null) ...[
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerRight,
                              child: FilledButton.icon(
                                onPressed: () => _showRatingDialog(context, session!),
                                icon: const Icon(Icons.star, size: 16),
                                label: const Text('Rate tutor'),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
