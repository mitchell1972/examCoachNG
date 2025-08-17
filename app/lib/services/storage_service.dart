import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/logger.dart';
import '../data/models/user_model.dart';

class StorageService {
  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._internal();

  late SharedPreferences _prefs;
  late FlutterSecureStorage _secureStorage;

  StorageService._internal() {
    _secureStorage = const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ),
      iOptions: IOSOptions(
        accessibility: IOSAccessibility.first_unlock_this_device,
      ),
    );
  }

  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      Logger.info('Storage service initialized');
    } catch (e) {
      Logger.error('Failed to initialize storage service', error: e);
      rethrow;
    }
  }

  // Secure storage methods (for sensitive data like tokens)
  Future<void> setAuthToken(String token) async {
    try {
      await _secureStorage.write(key: AppConstants.tokenKey, value: token);
      Logger.debug('Auth token stored securely');
    } catch (e) {
      Logger.error('Failed to store auth token', error: e);
      rethrow;
    }
  }

  Future<String?> getAuthToken() async {
    try {
      return await _secureStorage.read(key: AppConstants.tokenKey);
    } catch (e) {
      Logger.error('Failed to retrieve auth token', error: e);
      return null;
    }
  }

  Future<void> clearAuthToken() async {
    try {
      await _secureStorage.delete(key: AppConstants.tokenKey);
      Logger.debug('Auth token cleared');
    } catch (e) {
      Logger.error('Failed to clear auth token', error: e);
    }
  }

  // Regular storage methods (for non-sensitive data)
  Future<void> setUserData(UserModel user) async {
    try {
      final userJson = json.encode(user.toJson());
      await _prefs.setString(AppConstants.userKey, userJson);
      Logger.debug('User data stored');
    } catch (e) {
      Logger.error('Failed to store user data', error: e);
      rethrow;
    }
  }

  Future<UserModel?> getUserData() async {
    try {
      final userJson = _prefs.getString(AppConstants.userKey);
      if (userJson != null) {
        final userMap = json.decode(userJson) as Map<String, dynamic>;
        return UserModel.fromJson(userMap);
      }
      return null;
    } catch (e) {
      Logger.error('Failed to retrieve user data', error: e);
      return null;
    }
  }

  Future<void> setSelectedSubjects(List<String> subjects) async {
    try {
      await _prefs.setStringList(AppConstants.selectedSubjectsKey, subjects);
      Logger.debug('Selected subjects stored');
    } catch (e) {
      Logger.error('Failed to store selected subjects', error: e);
      rethrow;
    }
  }

  Future<List<String>> getSelectedSubjects() async {
    try {
      return _prefs.getStringList(AppConstants.selectedSubjectsKey) ?? [];
    } catch (e) {
      Logger.error('Failed to retrieve selected subjects', error: e);
      return [];
    }
  }

  Future<void> setOnboardingComplete(bool complete) async {
    try {
      await _prefs.setBool(AppConstants.onboardingCompleteKey, complete);
      Logger.debug('Onboarding status updated');
    } catch (e) {
      Logger.error('Failed to store onboarding status', error: e);
      rethrow;
    }
  }

  Future<bool> isOnboardingComplete() async {
    try {
      return _prefs.getBool(AppConstants.onboardingCompleteKey) ?? false;
    } catch (e) {
      Logger.error('Failed to retrieve onboarding status', error: e);
      return false;
    }
  }

  Future<void> setLastSyncTime(DateTime dateTime) async {
    try {
      await _prefs.setString(AppConstants.lastSyncKey, dateTime.toIso8601String());
      Logger.debug('Last sync time updated');
    } catch (e) {
      Logger.error('Failed to store last sync time', error: e);
    }
  }

  Future<DateTime?> getLastSyncTime() async {
    try {
      final syncTimeString = _prefs.getString(AppConstants.lastSyncKey);
      if (syncTimeString != null) {
        return DateTime.parse(syncTimeString);
      }
      return null;
    } catch (e) {
      Logger.error('Failed to retrieve last sync time', error: e);
      return null;
    }
  }

  Future<void> clearAuthData() async {
    try {
      await clearAuthToken();
      await _prefs.remove(AppConstants.userKey);
      Logger.info('Auth data cleared');
    } catch (e) {
      Logger.error('Failed to clear auth data', error: e);
    }
  }

  Future<void> clearAllData() async {
    try {
      await _secureStorage.deleteAll();
      await _prefs.clear();
      Logger.info('All storage data cleared');
    } catch (e) {
      Logger.error('Failed to clear all data', error: e);
    }
  }

  // Generic storage methods
  Future<void> setString(String key, String value) async {
    try {
      await _prefs.setString(key, value);
    } catch (e) {
      Logger.error('Failed to store string value', error: e);
      rethrow;
    }
  }

  Future<String?> getString(String key) async {
    try {
      return _prefs.getString(key);
    } catch (e) {
      Logger.error('Failed to retrieve string value', error: e);
      return null;
    }
  }

  Future<void> setBool(String key, bool value) async {
    try {
      await _prefs.setBool(key, value);
    } catch (e) {
      Logger.error('Failed to store bool value', error: e);
      rethrow;
    }
  }

  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    try {
      return _prefs.getBool(key) ?? defaultValue;
    } catch (e) {
      Logger.error('Failed to retrieve bool value', error: e);
      return defaultValue;
    }
  }

  Future<void> setInt(String key, int value) async {
    try {
      await _prefs.setInt(key, value);
    } catch (e) {
      Logger.error('Failed to store int value', error: e);
      rethrow;
    }
  }

  Future<int> getInt(String key, {int defaultValue = 0}) async {
    try {
      return _prefs.getInt(key) ?? defaultValue;
    } catch (e) {
      Logger.error('Failed to retrieve int value', error: e);
      return defaultValue;
    }
  }
}
