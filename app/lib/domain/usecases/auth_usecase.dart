import '../../data/repositories/auth_repository.dart';
import '../../data/models/user_model.dart';
import '../../services/storage_service.dart';
import '../../core/utils/logger.dart';

class AuthUseCase {
  final AuthRepository _authRepository;
  final StorageService _storageService = StorageService.instance;

  AuthUseCase(this._authRepository);

  Future<void> startOTP(String phoneNumber) async {
    try {
      // Validate phone number format
      if (!_isValidPhoneNumber(phoneNumber)) {
        throw Exception('Invalid phone number format');
      }

      await _authRepository.startOTP(phoneNumber);
      Logger.info('OTP started successfully');
    } catch (e) {
      Logger.error('Failed to start OTP', error: e);
      rethrow;
    }
  }

  Future<UserModel> verifyOTP(String phoneNumber, String code) async {
    try {
      // Validate OTP code format
      if (!_isValidOTPCode(code)) {
        throw Exception('Invalid OTP code format');
      }

      final result = await _authRepository.verifyOTP(phoneNumber, code);
      
      // Store auth token and user data
      await _storageService.setAuthToken(result.token);
      await _storageService.setUserData(result.user);
      
      Logger.info('User authenticated successfully');
      return result.user;
    } catch (e) {
      Logger.error('Failed to verify OTP', error: e);
      rethrow;
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      // Check if token exists
      final token = await _storageService.getAuthToken();
      if (token == null) {
        return null;
      }

      // Try to get cached user data first
      UserModel? cachedUser = await _storageService.getUserData();
      
      // Refresh user data from server
      try {
        final user = await _authRepository.getCurrentUser();
        await _storageService.setUserData(user);
        return user;
      } catch (e) {
        // If server call fails but we have cached data, return it
        if (cachedUser != null) {
          Logger.warning('Using cached user data due to server error', error: e);
          return cachedUser;
        }
        rethrow;
      }
    } catch (e) {
      Logger.error('Failed to get current user', error: e);
      return null;
    }
  }

  Future<void> updateUserSubjects(List<String> subjects) async {
    try {
      await _authRepository.updateUserSubjects(subjects);
      
      // Update cached user data
      final currentUser = await _storageService.getUserData();
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(subjects: subjects);
        await _storageService.setUserData(updatedUser);
      }
      
      Logger.info('User subjects updated successfully');
    } catch (e) {
      Logger.error('Failed to update user subjects', error: e);
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      // Call server logout
      await _authRepository.logout();
      
      // Clear local storage
      await _storageService.clearAuthData();
      
      Logger.info('User logged out successfully');
    } catch (e) {
      Logger.error('Error during logout', error: e);
      
      // Even if server call fails, clear local data
      await _storageService.clearAuthData();
    }
  }

  Future<bool> isAuthenticated() async {
    try {
      final token = await _storageService.getAuthToken();
      return token != null;
    } catch (e) {
      Logger.error('Error checking authentication status', error: e);
      return false;
    }
  }

  bool _isValidPhoneNumber(String phone) {
    // Basic phone number validation
    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
    return phoneRegex.hasMatch(phone);
  }

  bool _isValidOTPCode(String code) {
    // OTP should be 6 digits
    final otpRegex = RegExp(r'^\d{6}$');
    return otpRegex.hasMatch(code);
  }
}
