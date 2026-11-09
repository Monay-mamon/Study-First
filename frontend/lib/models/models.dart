enum YearLevel { freshman, sophomore, junior, senior }

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
