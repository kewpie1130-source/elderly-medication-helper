class LocalUser {
  final String userId;
  final String email;
  final String displayName;
  final String passwordSalt;
  final String passwordHash;
  final String createdAt;
  final String? lastSignedInAt;

  const LocalUser({
    required this.userId,
    required this.email,
    required this.displayName,
    required this.passwordSalt,
    required this.passwordHash,
    required this.createdAt,
    this.lastSignedInAt,
  });

  bool get hasPassword => passwordHash.isNotEmpty;

  String get shortLabel => displayName.trim().isEmpty ? email : displayName;

  Map<String, Object?> toMap() {
    return {
      'userId': userId,
      'email': email,
      'displayName': displayName,
      'passwordSalt': passwordSalt,
      'passwordHash': passwordHash,
      'createdAt': createdAt,
      'lastSignedInAt': lastSignedInAt,
    };
  }

  factory LocalUser.fromMap(Map<String, Object?> map) {
    return LocalUser(
      userId: map['userId'] as String? ?? '',
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String? ?? '',
      passwordSalt: map['passwordSalt'] as String? ?? '',
      passwordHash: map['passwordHash'] as String? ?? '',
      createdAt: map['createdAt'] as String? ?? '',
      lastSignedInAt: map['lastSignedInAt'] as String?,
    );
  }

  LocalUser copyWith({
    String? userId,
    String? email,
    String? displayName,
    String? passwordSalt,
    String? passwordHash,
    String? createdAt,
    String? lastSignedInAt,
  }) {
    return LocalUser(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      passwordSalt: passwordSalt ?? this.passwordSalt,
      passwordHash: passwordHash ?? this.passwordHash,
      createdAt: createdAt ?? this.createdAt,
      lastSignedInAt: lastSignedInAt ?? this.lastSignedInAt,
    );
  }
}
