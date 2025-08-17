import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String phone,
    String? name,
    String? email,
    List<String>? selectedSubjects,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'last_login') DateTime? lastLogin,
    bool? isVerified,
    Map<String, dynamic>? metadata,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  
  factory User.fromJsonString(String jsonString) => 
      User.fromJson(json.decode(jsonString));
}

extension UserExtension on User {
  String toJsonString() => json.encode(toJson());
  
  bool get hasSelectedSubjects => selectedSubjects != null && selectedSubjects!.isNotEmpty;
  
  String get displayName => name ?? phone;
  
  User copyWithSubjects(List<String> subjects) => copyWith(selectedSubjects: subjects);
}
