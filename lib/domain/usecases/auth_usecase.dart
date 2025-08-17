import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../data/repositories/auth_repository.dart';
import '../entities/user_entity.dart';

final authUsecaseProvider = Provider<AuthUsecase>((ref) {
  return AuthUsecase(ref.read(authRepositoryProvider));
});

class AuthUsecase {
  final AuthRepository _authRepository;
  
  AuthUsecase(this._authRepository);
  
  // Start OTP verification
  Future<bool> startOtpVerification(String phone) async {
    // Validate phone number format
    if (!_isValidPhoneNumber(phone)) {
      throw AuthException('Please enter a valid phone number');
    }
    
    return await _authRepository.startOtpVerification(phone);
  }
  
  // Verify OTP and complete authentication
  Future<UserEntity> verifyOtp(String phone, String code) async {
    if (code.length != 6) {
      throw AuthException('OTP must be 6 digits');
    }
    
    final result = await _authRepository.verifyOtp(phone, code);
    
    return UserEntity(
      id: result.user.id,
      phone: result.user.phone,
      name: result.user.name,
      email: result.user.email,
      selectedSubjects: result.user.selectedSubjects ?? [],
      createdAt: result.user.createdAt,
      lastLogin: result.user.lastLogin,
      isVerified: result.user.isVerified ?? false,
    );
  }
  
  // Get current user
  Future<UserEntity?> getCurrentUser() async {
    final user = await _authRepository.getUserData();
    if (user == null) return null;
    
    return UserEntity(
      id: user.id,
      phone: user.phone,
      name: user.name,
      email: user.email,
      selectedSubjects: user.selectedSubjects ?? [],
      createdAt: user.createdAt,
      lastLogin: user.lastLogin,
      isVerified: user.isVerified ?? false,
    );
  }
  
  // Check authentication status
  Future<bool> isAuthenticated() async {
    return await _authRepository.isAuthenticated();
  }
  
  // Logout user
  Future<void> logout() async {
    await _authRepository.logout();
  }
  
  // Update user subjects
  Future<UserEntity> updateUserSubjects(UserEntity user, List<String> subjects) async {
    // Validate subjects
    if (subjects.isEmpty) {
      throw AuthException('Please select at least one subject');
    }
    
    if (subjects.length > 4) {
      throw AuthException('Maximum 4 subjects allowed');
    }
    
    // Update locally stored user data
    final updatedUser = user.copyWith(selectedSubjects: subjects);
    
    // Note: In a real implementation, you might want to sync this with the server
    
    return updatedUser;
  }
  
  bool _isValidPhoneNumber(String phone) {
    // Basic Nigerian phone number validation
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    // Check if it's a valid Nigerian number
    if (cleaned.length == 11 && cleaned.startsWith('0')) {
      return true;
    }
    
    if (cleaned.length == 13 && cleaned.startsWith('234')) {
      return true;
    }
    
    if (cleaned.length == 14 && cleaned.startsWith('+234')) {
      return true;
    }
    
    return false;
  }
}

class AuthException implements Exception {
  final String message;
  
  const AuthException(this.message);
  
  @override
  String toString() => 'AuthException: $message';
}
