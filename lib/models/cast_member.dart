class CastMember {
  final String name;
  final String character;
  final String profilePath;

  const CastMember({
    required this.name,
    required this.character,
    required this.profilePath,
  });

  factory CastMember.fromJson(Map<String, dynamic> json) {
    return CastMember(
      name: json['name'] as String? ?? 'Unknown Actor',
      character: json['character'] as String? ?? 'Character',
      profilePath: json['profile_path'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'character': character,
      'profile_path': profilePath,
    };
  }
}
