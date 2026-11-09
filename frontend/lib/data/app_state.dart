import 'package:flutter/foundation.dart';
import '../models/models.dart';

class AppState extends ChangeNotifier {
  final Map<String, UserProfile> _users = {};
  UserProfile? _currentUser;

  UserProfile? get currentUser => _currentUser;
  Map<String, UserProfile> get users => _users;

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
