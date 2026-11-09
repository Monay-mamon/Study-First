import 'package:flutter/foundation.dart';
import '../models/models.dart';

// Demo users: alice, bob, charlie (password: demo123)
class AppState extends ChangeNotifier {
  final Map<String, UserProfile> _users = {};
  UserProfile? _currentUser;
  List<HelpPost> _posts = [];

  AppState() {
    _seedDemoUsers();
    _seedDemoPosts();
  }

  UserProfile? get currentUser => _currentUser;
  Map<String, UserProfile> get users => _users;
  List<HelpPost> get posts => List.unmodifiable(_posts);

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

  void _seedDemoPosts() {
    _posts = [
      HelpPost(
        id: 'post_1',
        tutee: 'alice',
        campus: 'BSU',
        subject: 'Math',
        course: 'MATH 101',
        description: 'Need help understanding limits and basic derivatives before the quiz.',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        status: PostStatus.open,
      ),
      HelpPost(
        id: 'post_2',
        tutee: 'alice',
        campus: 'BSU',
        subject: 'Computer Science',
        course: 'CS 101',
        description: 'Struggling with recursion concepts in programming assignments.',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        status: PostStatus.open,
      ),
      HelpPost(
        id: 'post_3',
        tutee: 'bob',
        campus: 'BSU',
        subject: 'Science',
        course: 'PHYS 101',
        description: 'Looking for study partner for Newton laws and kinematics problem sets.',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        status: PostStatus.open,
      ),
      HelpPost(
        id: 'post_4',
        tutee: 'bob',
        campus: 'BSU',
        subject: 'Engineering',
        course: 'ENGR 101',
        description: 'Review session for statics truss analysis problem solving.',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        status: PostStatus.open,
      ),
      HelpPost(
        id: 'post_5',
        tutee: 'charlie',
        campus: 'BSU',
        subject: 'History',
        course: 'HIST 101',
        description: 'Brainstorming session for world history essay thesis statement.',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        status: PostStatus.open,
      ),
    ];
  }

  String? createPost({
    required String subject,
    required String course,
    required String description,
  }) {
    final trimmedSubject = subject.trim();
    final trimmedCourse = course.trim();
    final trimmedDesc = description.trim();

    if (_currentUser == null) {
      return 'You must be logged in to create a post.';
    }
    if (trimmedSubject.isEmpty || trimmedCourse.isEmpty || trimmedDesc.isEmpty) {
      return 'All fields are required.';
    }
    if (trimmedDesc.length > 200) {
      return 'Description must be at most 200 characters.';
    }

    final openCount = _posts
        .where((p) =>
            p.tutee.toLowerCase() == _currentUser!.username.toLowerCase() &&
            p.status == PostStatus.open)
        .length;

    if (openCount >= 3) {
      return 'You can only have 3 open requests.';
    }

    final newPost = HelpPost(
      id: '${DateTime.now().millisecondsSinceEpoch}_${_posts.length}',
      tutee: _currentUser!.username,
      campus: 'BSU',
      subject: trimmedSubject,
      course: trimmedCourse,
      description: trimmedDesc,
      createdAt: DateTime.now(),
      status: PostStatus.open,
    );

    _posts = [..._posts, newPost];
    notifyListeners();
    return null;
  }

  void cancelPost(String id) {
    _posts = _posts.map((p) {
      if (p.id == id) {
        return p.copyWith(status: PostStatus.cancelled);
      }
      return p;
    }).toList();
    notifyListeners();
  }

  List<HelpPost> openPostsBy(String username) {
    return _posts
        .where((p) =>
            p.tutee.toLowerCase() == username.toLowerCase() &&
            p.status == PostStatus.open)
        .toList();
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
