enum YearLevel { freshman, sophomore, junior, senior }

enum PostStatus { open, matched, cancelled }

class Rating {
  final int stars;
  final String comment;
  final String fromUsername;

  Rating({
    required this.stars,
    required this.comment,
    required this.fromUsername,
  });
}

class HelpPost {
  final String id;
  final String tutee; // username
  final String campus;
  final String subject;
  final String course;
  final String description;
  final DateTime createdAt;
  final PostStatus status;

  HelpPost({
    required this.id,
    required this.tutee,
    required this.campus,
    required this.subject,
    required this.course,
    required this.description,
    required this.createdAt,
    required this.status,
  });

  HelpPost copyWith({
    String? id,
    String? tutee,
    String? campus,
    String? subject,
    String? course,
    String? description,
    DateTime? createdAt,
    PostStatus? status,
  }) {
    return HelpPost(
      id: id ?? this.id,
      tutee: tutee ?? this.tutee,
      campus: campus ?? this.campus,
      subject: subject ?? this.subject,
      course: course ?? this.course,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }
}

class UserProfile {
  final String username;
  final String password;
  final YearLevel? year;
  final String campus;
  final List<String> favoriteSubjects;
  final String contact;
  final String description;
  final List<Rating> ratings;
  final bool profileComplete;

  UserProfile({
    required this.username,
    required this.password,
    this.year,
    this.campus = 'BSU',
    this.favoriteSubjects = const [],
    this.contact = '',
    this.description = '',
    this.ratings = const [],
    this.profileComplete = false,
  });

  double? get averageRating {
    if (ratings.isEmpty) return null;
    final total = ratings.fold<int>(0, (sum, r) => sum + r.stars);
    return total / ratings.length;
  }

  UserProfile copyWith({
    String? username,
    String? password,
    YearLevel? year,
    String? campus,
    List<String>? favoriteSubjects,
    String? contact,
    String? description,
    List<Rating>? ratings,
    bool? profileComplete,
  }) {
    return UserProfile(
      username: username ?? this.username,
      password: password ?? this.password,
      year: year ?? this.year,
      campus: campus ?? this.campus,
      favoriteSubjects: favoriteSubjects ?? this.favoriteSubjects,
      contact: contact ?? this.contact,
      description: description ?? this.description,
      ratings: ratings ?? this.ratings,
      profileComplete: profileComplete ?? this.profileComplete,
    );
  }
}
