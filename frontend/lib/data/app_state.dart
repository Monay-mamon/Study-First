import 'package:flutter/foundation.dart';
import '../models/models.dart';

// Demo users: alice, bob, charlie (password: demo123)
class AppState extends ChangeNotifier {
  final Map<String, UserProfile> _users = {};
  UserProfile? _currentUser;
  List<HelpPost> _posts = [];
  List<TutorOffer> _offers = [];
  List<AppNotification> _notifications = [];
  List<TutoringSession> _sessions = [];

  AppState() {
    _seedDemoUsers();
    _seedDemoPosts();
    _seedDemoOffers();
    _seedDemoNotifications();
  }

  UserProfile? get currentUser => _currentUser;
  Map<String, UserProfile> get users => _users;
  List<HelpPost> get posts => List.unmodifiable(_posts);
  List<TutorOffer> get offers => List.unmodifiable(_offers);
  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  List<TutoringSession> get sessions => List.unmodifiable(_sessions);

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

  void _seedDemoOffers() {
    _offers = [
      TutorOffer(
        id: 'offer_1',
        postId: 'post_1', // alice's post
        tutor: 'bob',
        tutee: 'alice',
        status: OfferStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];
  }

  void _seedDemoNotifications() {
    _notifications = [
      AppNotification(
        id: 'notif_1',
        recipient: 'alice',
        type: NotificationType.newOffer,
        message: 'bob wants to tutor you in Math (MATH 101)',
        offerId: 'offer_1',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        read: false,
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
    final now = DateTime.now();
    final post = _posts.cast<HelpPost?>().firstWhere(
          (p) => p?.id == id,
          orElse: () => null,
        );

    final pendingForPost = _offers
        .where((o) => o.postId == id && o.status == OfferStatus.pending)
        .toList();

    _posts = _posts.map((p) {
      if (p.id == id) {
        return p.copyWith(status: PostStatus.cancelled);
      }
      return p;
    }).toList();

    _offers = _offers.map((o) {
      if (o.postId == id && o.status == OfferStatus.pending) {
        return o.copyWith(status: OfferStatus.declined);
      }
      return o;
    }).toList();

    final cancelNotifs = pendingForPost.map((o) => AppNotification(
          id: '${now.millisecondsSinceEpoch}_canc_${o.id}',
          recipient: o.tutor,
          type: NotificationType.offerDeclined,
          message: 'The request for ${post?.subject ?? 'subject'} was cancelled.',
          offerId: o.id,
          createdAt: now,
          read: false,
        ));

    _notifications = [..._notifications, ...cancelNotifs];
    notifyListeners();
  }

  List<HelpPost> openPostsBy(String username) {
    return _posts
        .where((p) =>
            p.tutee.toLowerCase() == username.toLowerCase() &&
            p.status == PostStatus.open)
        .toList();
  }

  String? sendOffer(String postId) {
    if (_currentUser == null) {
      return 'You must be logged in to send an offer.';
    }
    final post = _posts.cast<HelpPost?>().firstWhere(
          (p) => p?.id == postId,
          orElse: () => null,
        );
    if (post == null) {
      return 'Post not found.';
    }
    if (post.tutee.toLowerCase() == _currentUser!.username.toLowerCase()) {
      return 'You cannot offer on your own post.';
    }
    if (post.status != PostStatus.open) {
      return 'This post is no longer open.';
    }
    if (hasPendingOffer(_currentUser!.username, postId)) {
      return 'You already sent a request for this post.';
    }
    final pendingCount = pendingOffersBy(_currentUser!.username).length;
    if (pendingCount >= 3) {
      return 'You can only have 3 pending requests.';
    }

    final now = DateTime.now();
    final newOffer = TutorOffer(
      id: '${now.millisecondsSinceEpoch}_${_offers.length}',
      postId: postId,
      tutor: _currentUser!.username,
      tutee: post.tutee,
      status: OfferStatus.pending,
      createdAt: now,
    );

    final newNotif = AppNotification(
      id: '${now.millisecondsSinceEpoch}_notif',
      recipient: post.tutee,
      type: NotificationType.newOffer,
      message: '${_currentUser!.username} wants to tutor you in ${post.subject} (${post.course})',
      offerId: newOffer.id,
      createdAt: now,
      read: false,
    );

    _offers = [..._offers, newOffer];
    _notifications = [..._notifications, newNotif];
    notifyListeners();
    return null;
  }

  void withdrawOffer(String id) {
    _offers = _offers.map((o) {
      if (o.id == id) {
        return o.copyWith(status: OfferStatus.withdrawn);
      }
      return o;
    }).toList();
    notifyListeners();
  }

  List<TutorOffer> pendingOffersBy(String tutor) {
    return _offers
        .where((o) =>
            o.tutor.toLowerCase() == tutor.toLowerCase() &&
            o.status == OfferStatus.pending)
        .toList();
  }

  List<TutorOffer> pendingOffersForTutee(String tutee) {
    return _offers
        .where((o) =>
            o.tutee.toLowerCase() == tutee.toLowerCase() &&
            o.status == OfferStatus.pending)
        .toList();
  }

  bool hasPendingOffer(String tutor, String postId) {
    return _offers.any((o) =>
        o.tutor.toLowerCase() == tutor.toLowerCase() &&
        o.postId == postId &&
        o.status == OfferStatus.pending);
  }

  String? acceptOffer(String offerId) {
    if (_currentUser == null) return 'Not logged in.';
    final offer = _offers.cast<TutorOffer?>().firstWhere(
          (o) => o?.id == offerId,
          orElse: () => null,
        );
    if (offer == null) return 'Offer not found.';
    if (offer.tutee.toLowerCase() != _currentUser!.username.toLowerCase()) {
      return 'Only the tutee can accept this offer.';
    }
    if (offer.status != OfferStatus.pending) {
      return 'Offer is no longer pending.';
    }

    final post = _posts.cast<HelpPost?>().firstWhere(
          (p) => p?.id == offer.postId,
          orElse: () => null,
        );
    if (post == null) return 'Associated post not found.';

    final now = DateTime.now();

    // 1. Mark offer accepted, 2. Decline other pending offers on this post
    _offers = _offers.map((o) {
      if (o.id == offerId) {
        return o.copyWith(status: OfferStatus.accepted);
      }
      if (o.postId == offer.postId && o.status == OfferStatus.pending) {
        return o.copyWith(status: OfferStatus.declined);
      }
      return o;
    }).toList();

    // 3. Mark post matched
    _posts = _posts.map((p) {
      if (p.id == offer.postId) {
        return p.copyWith(status: PostStatus.matched);
      }
      return p;
    }).toList();

    // 4. Create active tutoring session
    final newSession = TutoringSession(
      id: '${now.millisecondsSinceEpoch}_session',
      tutor: offer.tutor,
      tutee: offer.tutee,
      subject: post.subject,
      course: post.course,
      postId: post.id,
      createdAt: now,
      status: SessionStatus.active,
    );
    _sessions = [..._sessions, newSession];

    // 5. Notify accepted tutor
    final acceptedNotif = AppNotification(
      id: '${now.millisecondsSinceEpoch}_acc',
      recipient: offer.tutor,
      type: NotificationType.offerAccepted,
      message: 'Your request to tutor @${offer.tutee} in ${post.subject} was accepted!',
      offerId: offer.id,
      createdAt: now,
      read: false,
    );

    // 6. Notify declined tutors
    final declinedOffers = _offers
        .where((o) => o.postId == offer.postId && o.status == OfferStatus.declined && o.id != offer.id);
    final declinedNotifs = declinedOffers.map((d) => AppNotification(
          id: '${now.millisecondsSinceEpoch}_dec_${d.id}',
          recipient: d.tutor,
          type: NotificationType.offerDeclined,
          message: 'Your request for @${d.tutee} in ${post.subject} was declined.',
          offerId: d.id,
          createdAt: now,
          read: false,
        ));

    _notifications = [..._notifications, acceptedNotif, ...declinedNotifs];
    notifyListeners();
    return null;
  }

  String? declineOffer(String offerId) {
    if (_currentUser == null) return 'Not logged in.';
    final offer = _offers.cast<TutorOffer?>().firstWhere(
          (o) => o?.id == offerId,
          orElse: () => null,
        );
    if (offer == null) return 'Offer not found.';
    if (offer.tutee.toLowerCase() != _currentUser!.username.toLowerCase()) {
      return 'Only the tutee can decline this offer.';
    }
    if (offer.status != OfferStatus.pending) {
      return 'Offer is no longer pending.';
    }

    final post = _posts.cast<HelpPost?>().firstWhere(
          (p) => p?.id == offer.postId,
          orElse: () => null,
        );
    final now = DateTime.now();

    _offers = _offers.map((o) {
      if (o.id == offerId) {
        return o.copyWith(status: OfferStatus.declined);
      }
      return o;
    }).toList();

    final declineNotif = AppNotification(
      id: '${now.millisecondsSinceEpoch}_dec',
      recipient: offer.tutor,
      type: NotificationType.offerDeclined,
      message: 'Your request for @${offer.tutee} in ${post?.subject ?? 'subject'} was declined.',
      offerId: offer.id,
      createdAt: now,
      read: false,
    );

    _notifications = [..._notifications, declineNotif];
    notifyListeners();
    return null;
  }

  List<AppNotification> notificationsFor(String username) {
    final list = _notifications
        .where((n) => n.recipient.toLowerCase() == username.toLowerCase())
        .toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  int unreadCountFor(String username) {
    return notificationsFor(username).where((n) => !n.read).length;
  }

  void markAllRead(String username) {
    _notifications = _notifications.map((n) {
      if (n.recipient.toLowerCase() == username.toLowerCase() && !n.read) {
        return n.copyWith(read: true);
      }
      return n;
    }).toList();
    notifyListeners();
  }

  List<TutoringSession> sessionsFor(String username) {
    final list = _sessions
        .where((s) =>
            s.status == SessionStatus.active &&
            (s.tutor.toLowerCase() == username.toLowerCase() ||
                s.tutee.toLowerCase() == username.toLowerCase()))
        .toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  bool hasActiveSessionBetween(String a, String b) {
    return _sessions.any((s) =>
        s.status == SessionStatus.active &&
        ((s.tutor.toLowerCase() == a.toLowerCase() &&
                s.tutee.toLowerCase() == b.toLowerCase()) ||
            (s.tutor.toLowerCase() == b.toLowerCase() &&
                s.tutee.toLowerCase() == a.toLowerCase())));
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
