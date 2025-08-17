import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../api/api_client.dart';
import '../api/dto/auth_dto.dart';
import '../../domain/entities/user.dart';
import '../../core/utils/constants.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;

  AuthRepository(this._apiClient, this._prefs, this._secureStorage);

  Future<void> startOtp(String phone) async {
    await _apiClient.post(
      ApiEndpoints.otpStart,
      data: {'phone': phone},
    );
  }

  Future<User> verifyOtp(String phone, String code) async {
    final response = await _apiClient.post(
      ApiEndpoints.otpVerify,
      data: {
        'phone': phone,
        'code': code,
      },
    );

    final authResponse = AuthResponseDto.fromJson(response.data);
    
    // Store token securely
    await _secureStorage.write(key: StorageKeys.authToken, value: authResponse.token);
    await _prefs.setString(StorageKeys.userId, authResponse.user.id);
    
    return authResponse.user.toDomain();
  }

  Future<String?> getStoredToken() async {
    return await _secureStorage.read(key: StorageKeys.authToken);
  }

  Future<String?> getStoredUserId() async {
    return _prefs.getString(StorageKeys.userId);
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: StorageKeys.authToken);
    await _prefs.remove(StorageKeys.userId);
    await _prefs.remove(StorageKeys.selectedSubjects);
    await _prefs.remove(StorageKeys.onboardingComplete);
  }

  Future<bool> isAuthenticated() async {
    final token = await getStoredToken();
    final userId = await getStoredUserId();
    return token != null && userId != null;
  }

  Future<User?> getCurrentUser() async {
    try {
      final response = await _apiClient.get('/me/profile');
      final userDto = UserDto.fromJson(response.data);
      return userDto.toDomain();
    } catch (e) {
      return null;
    }
  }

  Future<void> saveSelectedSubjects(List<String> subjects) async {
    await _prefs.setStringList(StorageKeys.selectedSubjects, subjects);
  }

  Future<List<String>> getSelectedSubjects() async {
    return _prefs.getStringList(StorageKeys.selectedSubjects) ?? [];
  }

  Future<void> markOnboardingComplete() async {
    await _prefs.setBool(StorageKeys.onboardingComplete, true);
  }

  Future<bool> isOnboardingComplete() async {
    return _prefs.getBool(StorageKeys.onboardingComplete) ?? false;
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  final prefs = ref.read(sharedPreferencesProvider);
  const secureStorage = FlutterSecureStorage();
  
  return AuthRepository(apiClient, prefs, secureStorage);
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized');
});
