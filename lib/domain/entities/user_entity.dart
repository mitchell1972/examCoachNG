class UserEntity {
  final String id;
  final String phone;
  final String? name;
  final String? email;
  final List<String> selectedSubjects;
  final DateTime? createdAt;
  final DateTime? lastLogin;
  final bool isVerified;
  
  const UserEntity({
    required this.id,
    required this.phone,
    this.name,
    this.email,
    this.selectedSubjects = const [],
    this.createdAt,
    this.lastLogin,
    this.isVerified = false,
  });
  
  String get displayName => name ?? phone;
  
  bool get hasSelectedSubjects => selectedSubjects.isNotEmpty;
  
  UserEntity copyWith({
    String? id,
    String? phone,
    String? name,
    String? email,
    List<String>? selectedSubjects,
    DateTime? createdAt,
    DateTime? lastLogin,
    bool? isVerified,
  }) {
    return UserEntity(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      email: email ?? this.email,
      selectedSubjects: selectedSubjects ?? this.selectedSubjects,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      isVerified: isVerified ?? this.isVerified,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserEntity && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
  
  @override
  String toString() => 'UserEntity(id: $id, phone: $phone, name: $name)';
}
