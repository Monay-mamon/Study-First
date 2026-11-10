enum YearLevel { freshman, sophomore, junior, senior }

enum PostStatus { open, matched, cancelled }

enum OfferStatus { pending, accepted, declined, withdrawn }

enum NotificationType {
  newOffer,
  offerAccepted,
  offerDeclined,
  cancelRequested,
  cancelConfirmed,
  cancelDeclined,
  completeRequested,
  sessionCompleted,
}

enum SessionStatus { active, completed, cancelled }

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

class TutorOffer {
  final String id;
  final String postId;
  final String tutor; // username
  final String tutee; // username
  final OfferStatus status;
  final DateTime createdAt;

  TutorOffer({
    required this.id,
    required this.postId,
    required this.tutor,
    required this.tutee,
    required this.status,
    required this.createdAt,
  });

  TutorOffer copyWith({
    String? id,
    String? postId,
    String? tutor,
    String? tutee,
    OfferStatus? status,
    DateTime? createdAt,
  }) {
    return TutorOffer(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      tutor: tutor ?? this.tutor,
      tutee: tutee ?? this.tutee,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class AppNotification {
  final String id;
  final String recipient; // username
  final NotificationType type;
  final String message;
  final String? offerId;
  final String? sessionId;
  final DateTime createdAt;
  final bool read;

  AppNotification({
    required this.id,
    required this.recipient,
    required this.type,
    required this.message,
    this.offerId,
    this.sessionId,
    required this.createdAt,
    this.read = false,
  });

  AppNotification copyWith({
    String? id,
    String? recipient,
    NotificationType? type,
    String? message,
    String? offerId,
    String? sessionId,
    DateTime? createdAt,
    bool? read,
  }) {
    return AppNotification(
      id: id ?? this.id,
      recipient: recipient ?? this.recipient,
      type: type ?? this.type,
      message: message ?? this.message,
      offerId: offerId ?? this.offerId,
      sessionId: sessionId ?? this.sessionId,
      createdAt: createdAt ?? this.createdAt,
      read: read ?? this.read,
    );
  }
}

class TutoringSession {
  final String id;
  final String tutor; // username
  final String tutee; // username
  final String subject;
  final String course;
  final String postId;
  final DateTime createdAt;
  final SessionStatus status;
  final String tutorNote;
  final String tuteeNote;
  final String? cancelRequestedBy;
  final String? completeRequestedBy;
  final bool rated;

  TutoringSession({
    required this.id,
    required this.tutor,
    required this.tutee,
    required this.subject,
    required this.course,
    required this.postId,
    required this.createdAt,
    required this.status,
    this.tutorNote = '',
    this.tuteeNote = '',
    this.cancelRequestedBy,
    this.completeRequestedBy,
    this.rated = false,
  });

  TutoringSession copyWith({
    String? id,
    String? tutor,
    String? tutee,
    String? subject,
    String? course,
    String? postId,
    DateTime? createdAt,
    SessionStatus? status,
    String? tutorNote,
    String? tuteeNote,
    String? cancelRequestedBy,
    String? completeRequestedBy,
    bool? rated,
  }) {
    return TutoringSession(
      id: id ?? this.id,
      tutor: tutor ?? this.tutor,
      tutee: tutee ?? this.tutee,
      subject: subject ?? this.subject,
      course: course ?? this.course,
      postId: postId ?? this.postId,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      tutorNote: tutorNote ?? this.tutorNote,
      tuteeNote: tuteeNote ?? this.tuteeNote,
      cancelRequestedBy: cancelRequestedBy,
      completeRequestedBy: completeRequestedBy,
      rated: rated ?? this.rated,
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
