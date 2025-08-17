import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';
import '../api/dio_client.dart';
import '../models/user_model.dart';

class AuthRepository {
  final DioClient _dioClient = DioClient.instance;
  
  Future<Map<String, dynamic>> startOTP(String phoneNumber) async {
    try {
      Logger.info('Starting OTP for phone: $phoneNumber');
      
      final response = await _dioClient.post(
        '${AppConstants.authEndpoint}/otp/start',
        data: {'phone': phoneNumber},
      );
      
      if (response.statusCode == 200) {
        Logger.info('OTP started successfully');
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to start OTP: ${response.statusMessage}');
      }
    } catch (e) {
      Logger.error('Error starting OTP', error: e);
      rethrow;
    }
  }
  
  Future<AuthResult> verifyOTP(String phoneNumber, String code) async {
    try {
      Logger.info('Verifying OTP for phone: $phoneNumber');
      
      final response = await _dioClient.post(
        '${AppConstants.authEndpoint}/otp/verify',
        data: {
          'phone': phoneNumber,
          'code': code,
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final token = data['token'] as String;
        final userData = data['user'] as Map<String, dynamic>;
        
        Logger.info('OTP verified successfully');
        
        return AuthResult(
          token: token,
          user: UserModel.fromJson(userData),
        );
      } else {
        throw Exception('Failed to verify OTP: ${response.statusMessage}');
      }
    } catch (e) {
      Logger.error('Error verifying OTP', error: e);
      rethrow;
    }
  }
  
  Future<UserModel> getCurrentUser() async {
    try {
      Logger.info('Getting current user');
      
      final response = await _dioClient.get('/me');
      
      if (response.statusCode == 200) {
        final userData = response.data as Map<String, dynamic>;
        Logger.info('Current user retrieved successfully');
        
        return UserModel.fromJson(userData);
      } else {
        throw Exception('Failed to get current user: ${response.statusMessage}');
      }
    } catch (e) {
      Logger.error('Error getting current user', error: e);
      rethrow;
    }
  }
  
  Future<void> updateUserSubjects(List<String> subjects) async {
    try {
      Logger.info('Updating user subjects: $subjects');
      
      final response = await _dioClient.put(
        '/me/subjects',
        data: {'subjects': subjects},
      );
      
      if (response.statusCode == 200) {
        Logger.info('User subjects updated successfully');
      } else {
        throw Exception('Failed to update subjects: ${response.statusMessage}');
      }
    } catch (e) {
      Logger.error('Error updating user subjects', error: e);
      rethrow;
    }
  }
  
  Future<void> logout() async {
    try {
      Logger.info('Logging out user');
      
      await _dioClient.post('/auth/logout');
      Logger.info('User logged out successfully');
    } catch (e) {
      Logger.error('Error logging out', error: e);
      // Don't rethrow - logout should succeed even if server call fails
    }
  }
}

class AuthResult {
  final String token;
  final UserModel user;
  
  AuthResult({
    required this.token,
    required this.user,
  });
}
