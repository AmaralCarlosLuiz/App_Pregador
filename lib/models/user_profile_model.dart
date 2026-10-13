class UserProfile {
  final String id;
  final String fullName;
  final String? avatarUrl;
  final String ministryTitle;
  final String? churchName;
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    required this.fullName,
    this.avatarUrl,
    this.ministryTitle = 'Pastor',
    this.churchName,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? '',
      fullName: json['full_name'] as String? ?? 'Ministro da Palavra',
      avatarUrl: json['avatar_url'] as String?,
      ministryTitle: json['ministry_title'] as String? ?? 'Pastor',
      churchName: json['church_name'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'ministry_title': ministryTitle,
      'church_name': churchName,
      'created_at': createdAt.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? id,
    String? fullName,
    String? avatarUrl,
    String? ministryTitle,
    String? churchName,
    DateTime? createdAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      ministryTitle: ministryTitle ?? this.ministryTitle,
      churchName: churchName ?? this.churchName,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
