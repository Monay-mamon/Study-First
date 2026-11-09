import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/app_state.dart';
import '../data/subjects.dart';
import '../models/models.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  YearLevel? _selectedYear;
  final Set<String> _selectedSubjects = {};
  final _contactController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AppState>(context, listen: false).currentUser;
    if (user != null) {
      _selectedYear = user.year;
      _selectedSubjects.addAll(user.favoriteSubjects);
      _contactController.text = user.contact;
      _descriptionController.text = user.description;
    }
  }

  @override
  void dispose() {
    _contactController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    setState(() {
      _errorMessage = null;
    });

    if (_selectedYear == null) {
      setState(() => _errorMessage = 'Please select your year level.');
      return;
    }
    if (_selectedSubjects.isEmpty) {
      setState(() => _errorMessage = 'Please select at least one favorite subject.');
      return;
    }
    if (_contactController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Contact info is required.');
      return;
    }
    if (_descriptionController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Short description is required.');
      return;
    }
    if (_descriptionController.text.trim().length > 200) {
      setState(() => _errorMessage = 'Description must be at most 200 characters.');
      return;
    }

    final appState = Provider.of<AppState>(context, listen: false);
    final user = appState.currentUser;
    if (user == null) return;

    final updatedUser = user.copyWith(
      year: _selectedYear,
      campus: 'BSU',
      favoriteSubjects: List.from(_selectedSubjects),
      contact: _contactController.text.trim(),
      description: _descriptionController.text.trim(),
      profileComplete: true,
    );

    appState.updateCurrentUser(updatedUser);

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  String _yearLabel(YearLevel year) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = Provider.of<AppState>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Setup'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => appState.logout(),
            tooltip: 'Logout',
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
                Text(
                  'Complete Your Profile',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please fill in your details to connect with other tutors and students on campus.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
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
                // Year Level
                Text(
                  'Year Level *',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: YearLevel.values.map((year) {
                    return ChoiceChip(
                      label: Text(_yearLabel(year)),
                      selected: _selectedYear == year,
                      onSelected: (selected) {
                        setState(() {
                          _selectedYear = selected ? year : null;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                // Campus
                Text(
                  'Campus',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: 'BSU',
                  enabled: false,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    helperText: 'Tutor meetings happen on BSU campus only.',
                  ),
                ),
                const SizedBox(height: 24),
                // Favorite Subjects
                Text(
                  'Favorite Subjects (Select at least 1) *',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: kPresetSubjects.keys.map((subject) {
                    final isSelected = _selectedSubjects.contains(subject);
                    return FilterChip(
                      label: Text(subject),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedSubjects.add(subject);
                          } else {
                            _selectedSubjects.remove(subject);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                // Contact Info
                Text(
                  'Contact Info *',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _contactController,
                  decoration: const InputDecoration(
                    labelText: 'Email, phone, or messaging handle',
                    border: OutlineInputBorder(),
                    helperText: 'Only shown to people you have an active session with.',
                  ),
                ),
                const SizedBox(height: 24),
                // Short Description
                Text(
                  'Short Description *',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  maxLength: 200,
                  decoration: const InputDecoration(
                    labelText: 'Tell others about your study style, availability, etc.',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: _saveProfile,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Profile'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
