import 'package:flutter/foundation.dart';
import '../models/models.dart';

// Demo users: alice, bob, charlie (password: demo123)
class AppState extends ChangeNotifier {
  final Map<String, UserProfile> _users = {};
  UserProfile? _currentUser;

  AppState() {
    _seedDemoUsers();
  }

  UserProfile? get currentUser => _currentUser;
  Map<String, UserProfile> get users => _users;

  UserProfile? userByUsername(String username) {
    return _users[username.trim().toLowerCase()];
  }

  void _seedDemoUsers() {
    final demoUsers = [
      UserProfile(
        username: 'alice',
        password: 'demo123',
        year: YearLevel.junior,
        campus: 'BSU',
        favoriteSubjects: ['Math', 'Computer Science'],
        contact: 'alice@bsu.edu',
        description: 'CS major who loves helping with algorithms and calculus!',
        ratings: [
          Rating(stars: 5, comment: 'Super helpful and clear explanation!', fromUsername: 'bob'),
          Rating(stars: 4, comment: 'Great tutor.', fromUsername: 'charlie'),
        ],
        profileComplete: true,
      ),
      UserProfile(
        username: 'bob',
        password: 'demo123',
        year: YearLevel.sophomore,
        campus: 'BSU',
        favoriteSubjects: ['Science', 'Engineering'],
        contact: 'bob_physics@bsu.edu',
        description: "Physics & Engineering nerd. Let's solve physics problems together.",
        ratings: [
          Rating(stars: 5, comment: 'Amazing session!', fromUsername: 'alice'),
        ],
        profileComplete: true,
      ),
      UserProfile(
        username: 'charlie',
        password: 'demo123',
        year: YearLevel.senior,
        campus: 'BSU',
        favoriteSubjects: ['History', 'Art'],
        contact: 'charlie_history@bsu.edu',
        description: 'Senior art history enthusiast ready to assist.',
        ratings: [
          Rating(stars: 4, comment: 'Very knowledgeable.', fromUsername: 'alice'),
        ],
        profileComplete: true,
      ),
    ];

    for (var user in demoUsers) {
      _users[user.username.toLowerCase()] = user;
    }
  }

  String? register(String username, String password) {
    final trimmedUser = username.trim();
    if (trimmedUser.isEmpty || password.isEmpty) {
      return 'Username and password cannot be empty.';
    }
    final key = trimmedUser.toLowerCase();
    if (_users.containsKey(key)) {
      return 'Username already exists. Please choose another.';
    }

    final newUser = UserProfile(
      username: trimmedUser,
      password: password,
      campus: 'BSU',
      profileComplete: false,
    );

    _users[key] = newUser;
    _currentUser = newUser;
    notifyListeners();
    return null;
  }

  String? login(String username, String password) {
    final trimmedUser = username.trim();
    if (trimmedUser.isEmpty || password.isEmpty) {
      return 'Username and password cannot be empty.';
    }
    final key = trimmedUser.toLowerCase();
    final user = _users[key];
    if (user == null || user.password != password) {
      return 'Invalid username or password.';
    }

    _currentUser = user;
    notifyListeners();
    return null;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  void updateCurrentUser(UserProfile updatedProfile) {
    final key = updatedProfile.username.toLowerCase();
    _users[key] = updatedProfile;
    _currentUser = updatedProfile;
    notifyListeners();
  }
}
