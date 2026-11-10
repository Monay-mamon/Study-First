import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/app_state.dart';
import '../models/models.dart';
import 'profile_screen.dart';

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

                final isPendingOffer = notif.type == NotificationType.newOffer &&
                    offer?.status == OfferStatus.pending;

                String? tutorUsername;
                if (isPendingOffer && offer != null) {
                  tutorUsername = offer.tutor;
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: notif.read
                      ? theme.colorScheme.surface
                      : theme.colorScheme.primaryContainer.withOpacity(0.2),
                  elevation: notif.read ? 1 : 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              notif.type == NotificationType.offerAccepted
                                  ? Icons.check_circle
                                  : notif.type == NotificationType.offerDeclined
                                      ? Icons.cancel
                                      : Icons.notifications,
                              color: notif.type == NotificationType.offerAccepted
                                  ? Colors.green
                                  : notif.type == NotificationType.offerDeclined
                                      ? Colors.red
                                      : theme.colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${notif.createdAt.month}/${notif.createdAt.day} ${notif.createdAt.hour.toString().padLeft(2, '0')}:${notif.createdAt.minute.toString().padLeft(2, '0')}',
                              style: theme.textTheme.bodySmall,
                            ),
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
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
