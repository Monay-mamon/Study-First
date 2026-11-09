import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/app_state.dart';
import '../models/models.dart';
import 'profile_setup_screen.dart';

class ProfileScreen extends StatelessWidget {
  final String username;

  const ProfileScreen({super.key, required this.username});

  bool _canViewContact(AppState appState, UserProfile profile) {
    // Contact info is shown only if it is the current user's own profile.
    // (Sessions come later, but this helper encapsulates the rule.)
    final currentUser = appState.currentUser;
    if (currentUser == null) return false;
    return currentUser.username.toLowerCase() == profile.username.toLowerCase();
  }

  String _yearLabel(YearLevel? year) {
    if (year == null) return 'Unknown Year';
    switch (year) {
      case YearLevel.freshman:
        return 'Freshman';
      case YearLevel.sophomore:
        return 'Sophomore';
      case YearLevel.junior:
        return 'Junior';
      case YearLevel.senior:
        return 'Senior';
    }
  }

  void _showReportDialog(BuildContext context) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Report User: $username'),
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

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.userByUsername(username);
    final theme = Theme.of(context);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('User not found.')),
      );
    }

    final currentUser = appState.currentUser;
    final isOwnProfile = currentUser != null &&
        currentUser.username.toLowerCase() == user.username.toLowerCase();

    return Scaffold(
      appBar: AppBar(
        title: Text(user.username),
        actions: [
          if (!isOwnProfile)
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
                // Header card
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Text(
                            user.username.isNotEmpty
                                ? user.username[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          user.username,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_yearLabel(user.year)} • ${user.campus}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Average Rating
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              user.averageRating != null
                                  ? '${user.averageRating!.toStringAsFixed(1)} (${user.ratings.length} ${user.ratings.length == 1 ? 'rating' : 'ratings'})'
                                  : 'No ratings yet',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Favorite Subjects
                Text(
                  'Favorite Subjects',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: user.favoriteSubjects.map((sub) {
                    return Chip(label: Text(sub));
                  }).toList(),
                ),
                const SizedBox(height: 24),
                // Description
                Text(
                  'About',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user.description.isNotEmpty
                      ? user.description
                      : 'No description provided.',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                // Contact Info
                Text(
                  'Contact Info',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _canViewContact(appState, user)
                        ? user.contact
                        : 'Contact info is revealed after you have a session together.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 24),
                // Ratings List
                Text(
                  'Ratings & Reviews',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                user.ratings.isEmpty
                    ? const Text('No reviews yet.')
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: user.ratings.length,
                        itemBuilder: (context, index) {
                          final rating = user.ratings[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Row(
                                        children: List.generate(
                                          5,
                                          (starIdx) => Icon(
                                            starIdx < rating.stars
                                                ? Icons.star
                                                : Icons.star_border,
                                            size: 16,
                                            color: Colors.amber,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => ProfileScreen(
                                                  username: rating.fromUsername),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          'by ${rating.fromUsername}',
                                          style: TextStyle(
                                            color: theme.colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (rating.comment.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(rating.comment),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                if (isOwnProfile) ...[
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProfileSetupScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Profile'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
