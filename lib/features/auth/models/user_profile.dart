class UserProfile {
  final String id;
  final String fullName;
  final String? username;
  final String? avatarUrl;
  final String? bio;
  final int credits;
  final bool isPremium;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserProfile({
    required this.id,
    required this.fullName,
    this.username,
    this.avatarUrl,
    this.bio,
    this.credits = 10,
    this.isPremium = false,
    this.createdAt,
    this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      fullName: json['full_name'] as String? ?? 'مستخدم أنشئلي',
      username: json['username'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      credits: (json['credits'] as num?)?.toInt() ?? 10,
      isPremium: json['is_premium'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'username': username,
      'avatar_url': avatarUrl,
      'bio': bio,
      'credits': credits,
      'is_premium': isPremium,
    };
  }

  UserProfile copyWith({
    String? fullName,
    String? username,
    String? avatarUrl,
    String? bio,
    int? credits,
    bool? isPremium,
  }) {
    return UserProfile(
      id: id,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      credits: credits ?? this.credits,
      isPremium: isPremium ?? this.isPremium,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
