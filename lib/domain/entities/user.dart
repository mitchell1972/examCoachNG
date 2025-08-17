import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String phone,
    String? email,
    String? firstName,
    String? lastName,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _User;

  const User._();

  String get displayName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (email != null) {
      return email!.split('@').first;
    } else {
      return phone;
    }
  }

  String get initials {
    if (firstName != null && lastName != null) {
      return '${firstName![0]}${lastName![0]}';
    } else if (firstName != null) {
      return firstName![0];
    } else if (email != null) {
      return email![0].toUpperCase();
    } else {
      return phone[0];
    }
  }
}

@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    User? user,
    String? token,
    @Default(false) bool isLoading,
    String? error,
  }) = _AuthState;

  const AuthState._();

  bool get isAuthenticated => user != null && token != null;
}
