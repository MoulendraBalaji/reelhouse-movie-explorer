class UserProfile {
  final String name;
  final String email;
  final String bio;
  final String memberSince;
  final String favoriteGenre;
  final int watchedCount;
  final double totalHours;

  const UserProfile({
    required this.name,
    required this.email,
    this.bio = 'Classic cinema enthusiast & projectionist apprentice.',
    this.memberSince = '1934',
    this.favoriteGenre = 'Drama',
    this.watchedCount = 42,
    this.totalHours = 89.5,
  });

  UserProfile copyWith({
    String? name,
    String? email,
    String? bio,
    String? memberSince,
    String? favoriteGenre,
    int? watchedCount,
    double? totalHours,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      memberSince: memberSince ?? this.memberSince,
      favoriteGenre: favoriteGenre ?? this.favoriteGenre,
      watchedCount: watchedCount ?? this.watchedCount,
      totalHours: totalHours ?? this.totalHours,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String? ?? 'Cinema Patron',
      email: json['email'] as String? ?? 'projectionist@reelhouse.cinema',
      bio: json['bio'] as String? ?? 'Classic cinema enthusiast & projectionist apprentice.',
      memberSince: json['member_since'] as String? ?? '1934',
      favoriteGenre: json['favorite_genre'] as String? ?? 'Drama',
      watchedCount: json['watched_count'] is int ? json['watched_count'] as int : 42,
      totalHours: (json['total_hours'] as num?)?.toDouble() ?? 89.5,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'bio': bio,
      'member_since': memberSince,
      'favorite_genre': favoriteGenre,
      'watched_count': watchedCount,
      'total_hours': totalHours,
    };
  }
}
