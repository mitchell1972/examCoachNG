class User {
  final String id;
  final String phone;
  final String? name;
  final String? email;
  final List<String> subjects;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  const User({
    required this.id,
    required this.phone,
    this.name,
    this.email,
    this.subjects = const [],
    this.createdAt,
    this.lastLoginAt,
  });

  User copyWith({
    String? id,
    String? phone,
    String? name,
    String? email,
    List<String>? subjects,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return User(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      email: email ?? this.email,
      subjects: subjects ?? this.subjects,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is User &&
      other.id == id &&
      other.phone == phone &&
      other.name == name &&
      other.email == email &&
      other.subjects == subjects &&
      other.createdAt == createdAt &&
      other.lastLoginAt == lastLoginAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      phone.hashCode ^
      name.hashCode ^
      email.hashCode ^
      subjects.hashCode ^
      createdAt.hashCode ^
      lastLoginAt.hashCode;
  }
}
