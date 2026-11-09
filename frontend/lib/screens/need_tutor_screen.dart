import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/app_state.dart';
import '../data/subjects.dart';

class NeedTutorScreen extends StatefulWidget {
  const NeedTutorScreen({super.key});

  @override
  State<NeedTutorScreen> createState() => _NeedTutorScreenState();
}

class _NeedTutorScreenState extends State<NeedTutorScreen> {
  String? _selectedSubject;
  final _courseController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _courseController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitPost() {
    setState(() {
      _errorMessage = null;
    });

    if (_selectedSubject == null) {
      setState(() => _errorMessage = 'Please select a subject.');
      return;
    }

    final appState = Provider.of<AppState>(context, listen: false);
    final error = appState.createPost(
      subject: _selectedSubject!,
      course: _courseController.text,
      description: _descriptionController.text,
    );

    if (error != null) {
      setState(() {
        _errorMessage = error;
      });
    } else {
      _courseController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedSubject = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request posted')),
      );
    }
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

    final openPosts = appState.openPostsBy(currentUser.username);
    final canPost = openPosts.length < 3;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Need a Tutor'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (canPost) ...[
                  Text(
                    'Post a Help Request',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Get help from other students on campus (BSU only).',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: theme.colorScheme.onErrorContainer,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  // Campus (read-only)
                  TextFormField(
                    initialValue: 'BSU',
                    enabled: false,
                    decoration: const InputDecoration(
                      labelText: 'Campus',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Subject Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedSubject,
                    decoration: const InputDecoration(
                      labelText: 'Subject *',
                      border: OutlineInputBorder(),
                    ),
                    items: kPresetSubjects.keys.map((sub) {
                      return DropdownMenuItem(
                        value: sub,
                        child: Text(sub),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedSubject = val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Course
                  TextField(
                    controller: _courseController,
                    decoration: InputDecoration(
                      labelText: 'Course Code * (e.g. MATH 101)',
                      border: const OutlineInputBorder(),
                      helperText: _selectedSubject != null
                          ? 'Examples for $_selectedSubject: ${kPresetSubjects[_selectedSubject]?.join(", ")}'
                          : 'Select a subject to see course code examples',
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Description
                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    maxLength: 200,
                    decoration: const InputDecoration(
                      labelText: 'Description *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: _submitPost,
                    icon: const Icon(Icons.send),
                    label: const Text('Post request'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'You have reached the maximum of 3 open requests. Cancel an existing request below to post a new one.',
                      style: TextStyle(
                        color: theme.colorScheme.onTertiaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),
                // My open requests (n/3)
                Text(
                  'My open requests (${openPosts.length}/3)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                openPosts.isEmpty
                    ? const Text('You have no open help requests.')
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: openPosts.length,
                        itemBuilder: (context, index) {
                          final post = openPosts[index];
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
                                        label: Text(post.subject),
                                        backgroundColor:
                                            theme.colorScheme.primaryContainer,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        post.course,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        '${post.createdAt.month}/${post.createdAt.day}',
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(post.description),
                                  const SizedBox(height: 12),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        appState.cancelPost(post.id);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Request cancelled'),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.cancel_outlined, size: 18),
                                      label: const Text('Cancel request'),
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
        ),
      ),
    );
  }
}
