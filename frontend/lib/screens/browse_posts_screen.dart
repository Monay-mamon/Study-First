import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/app_state.dart';
import '../data/subjects.dart';
import '../models/models.dart';
import 'profile_screen.dart';

class BrowsePostsScreen extends StatefulWidget {
  const BrowsePostsScreen({super.key});

  @override
  State<BrowsePostsScreen> createState() => _BrowsePostsScreenState();
}

class _BrowsePostsScreenState extends State<BrowsePostsScreen> {
  String? _selectedSubject; // null or 'All subjects' means all
  final _courseSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _courseSearchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _courseSearchController.dispose();
    super.dispose();
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

    final pendingOffers = appState.pendingOffersBy(currentUser.username);

    // Filter open posts from other users
    final query = _courseSearchController.text.trim().toLowerCase();
    final openPosts = appState.posts.where((p) {
      if (p.status != PostStatus.open) return false;
      // Exclude own posts
      if (p.tutee.toLowerCase() == currentUser.username.toLowerCase()) return false;
      // Filter by subject
      if (_selectedSubject != null && _selectedSubject != 'All subjects') {
        if (p.subject != _selectedSubject) return false;
      }
      // Filter by course query
      if (query.isNotEmpty) {
        if (!p.course.toLowerCase().contains(query) &&
            !p.description.toLowerCase().contains(query)) {
          return false;
        }
      }
      return true;
    }).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Become a Tutor'),
          bottom: TabBar(
            tabs: [
              const Tab(text: 'Browse Posts'),
              Tab(text: 'My Pending Requests (${pendingOffers.length}/3)'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Browse Posts
            Column(
              children: [
                // Filters Bar
                Container(
                  padding: const EdgeInsets.all(16.0),
                  color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Campus (BSU read-only)
                          Expanded(
                            flex: 1,
                            child: TextFormField(
                              initialValue: 'BSU',
                              enabled: false,
                              decoration: const InputDecoration(
                                labelText: 'Campus',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Subject Filter Dropdown
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<String>(
                              value: _selectedSubject,
                              decoration: const InputDecoration(
                                labelText: 'Subject',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: 'All subjects',
                                  child: Text('All subjects'),
                                ),
                                ...kPresetSubjects.keys.map((sub) {
                                  return DropdownMenuItem(
                                    value: sub,
                                    child: Text(sub),
                                  );
                                }),
                              ],
                              onChanged: (val) {
                                setState(() {
                                  _selectedSubject = val == 'All subjects' ? null : val;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Course Search
                      TextField(
                        controller: _courseSearchController,
                        decoration: const InputDecoration(
                          labelText: 'Search course code or keyword',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.search),
                          isDense: true,
                        ),
                      ),
                    ],
                  ),
                ),
                // Posts List
                Expanded(
                  child: openPosts.isEmpty
                      ? const Center(
                          child: Text(
                            'No posts match your filters.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: openPosts.length,
                          itemBuilder: (context, index) {
                            final post = openPosts[index];
                            final alreadyRequested = appState.hasPendingOffer(
                                currentUser.username, post.id);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Chip(
                                          label: Text(post.subject),
                                          backgroundColor:
                                              theme.colorScheme.primaryContainer,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          post.course,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const Spacer(),
                                        InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => ProfileScreen(
                                                    username: post.tutee),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            'by @${post.tutee}',
                                            style: TextStyle(
                                              color: theme.colorScheme.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(post.description),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Text(
                                          'Campus: ${post.campus} • Posted: ${post.createdAt.month}/${post.createdAt.day}',
                                          style: theme.textTheme.bodySmall,
                                        ),
                                        const Spacer(),
                                        alreadyRequested
                                            ? const OutlinedButton(
                                                onPressed: null,
                                                child: Text('Requested'),
                                              )
                                            : FilledButton.icon(
                                                onPressed: () {
                                                  final error = appState.sendOffer(post.id);
                                                  if (error != null) {
                                                    ScaffoldMessenger.of(context)
                                                        .showSnackBar(
                                                      SnackBar(content: Text(error)),
                                                    );
                                                  } else {
                                                    ScaffoldMessenger.of(context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                          content: Text('Request sent')),
                                                    );
                                                  }
                                                },
                                                icon: const Icon(Icons.handshake, size: 18),
                                                label: const Text('Offer to tutor'),
                                              ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
            // Tab 2: My Pending Requests
            pendingOffers.isEmpty
                ? const Center(
                    child: Text(
                      'No pending requests.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: pendingOffers.length,
                    itemBuilder: (context, index) {
                      final offer = pendingOffers[index];
                      final post = appState.posts.cast<HelpPost?>().firstWhere(
                            (p) => p?.id == offer.postId,
                            orElse: () => null,
                          );

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Chip(
                                    label: Text(post?.subject ?? 'Subject'),
                                    backgroundColor:
                                        theme.colorScheme.secondaryContainer,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    post?.course ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ProfileScreen(
                                              username: offer.tutee),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'for @${offer.tutee}',
                                      style: TextStyle(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (post != null) ...[
                                const SizedBox(height: 8),
                                Text(post.description),
                              ],
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    appState.withdrawOffer(offer.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Offer withdrawn')),
                                    );
                                  },
                                  icon: const Icon(Icons.undo, size: 18),
                                  label: const Text('Withdraw'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: theme.colorScheme.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
