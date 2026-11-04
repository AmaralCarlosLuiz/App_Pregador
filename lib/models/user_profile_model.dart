class UserProfile {
  final String id;
  final String email;
  final String fullName;
  final String? avatarUrl;
  final String ministryTitle;
  final String? churchName;
  final String role; // 'admin' | 'member'
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    this.email = '',
    required this.fullName,
    this.avatarUrl,
    this.ministryTitle = 'Pastor',
    this.churchName,
    this.role = 'member',
    required this.createdAt,
  });

  bool get isAdmin =>
      role.toLowerCase() == 'admin' ||
      email.trim().toLowerCase() == 'carlosluizamaral@gmail.com';

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final emailStr = (json['email'] as String? ?? '').trim();
    final isMasterAdmin = emailStr.toLowerCase() == 'carlosluizamaral@gmail.com';
    return UserProfile(
      id: json['id'] as String? ?? '',
      email: emailStr,
      fullName: json['full_name'] as String? ?? 'Ministro da Palavra',
      avatarUrl: json['avatar_url'] as String?,
      ministryTitle: json['ministry_title'] as String? ?? 'Pastor',
      churchName: json['church_name'] as String?,
      role: isMasterAdmin ? 'admin' : (json['role'] as String? ?? 'member'),
      createdAt: json['created_at'] != null
          ? (DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'ministry_title': ministryTitle,
      'church_name': churchName,
      'role': role,
      'created_at': createdAt.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? fullName,
    String? avatarUrl,
    String? ministryTitle,
    String? churchName,
    String? role,
    DateTime? createdAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      ministryTitle: ministryTitle ?? this.ministryTitle,
      churchName: churchName ?? this.churchName,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class AccessRequestItem {
  final String id;
  final String fullName;
  final String email;
  final String ministryTitle;
  final String churchName;
  final String notes;
  final String status; // 'pending' | 'approved'
  final DateTime requestedAt;

  const AccessRequestItem({
    required this.id,
    required this.fullName,
    required this.email,
    required this.ministryTitle,
    required this.churchName,
    this.notes = '',
    this.status = 'pending',
    required this.requestedAt,
  });

  factory AccessRequestItem.fromJson(Map<String, dynamic> json) {
    return AccessRequestItem(
      id: json['id'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      ministryTitle: json['ministry_title'] as String? ?? 'Pastor',
      churchName: json['church_name'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      requestedAt: json['requested_at'] != null
          ? (DateTime.tryParse(json['requested_at'].toString()) ?? DateTime.now())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'ministry_title': ministryTitle,
      'church_name': churchName,
      'notes': notes,
      'status': status,
      'requested_at': requestedAt.toIso8601String(),
    };
  }
}
