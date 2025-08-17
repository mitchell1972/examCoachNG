import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../data/models/user_model.dart';
import '../../../domain/usecases/auth_usecase.dart';
import '../../../core/utils/logger.dart';

// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// Auth use case provider
final authUseCaseProvider = Provider<AuthUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthUseCase(repository);
});

// Auth state class
class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

// Auth state notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthUseCase _authUseCase;

  AuthNotifier(this._authUseCase) : super(const AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      state = state.copyWith(isLoading: true);
      
      final user = await _authUseCase.getCurrentUser();
      if (user != null) {
        state = state.copyWith(
          user: user,
          isAuthenticated: true,
          isLoading: false,
        );
        Logger.info('User authenticated from stored credentials');
      } else {
        state = state.copyWith(
          isAuthenticated: false,
          isLoading: false,
        );
      }
    } catch (e) {
      Logger.error('Error checking auth status', error: e);
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        error: 'Failed to check authentication status',
      );
    }
  }

  Future<void> startOTP(String phoneNumber) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      await _authUseCase.startOTP(phoneNumber);
      
      state = state.copyWith(isLoading: false);
      Logger.info('OTP request sent successfully');
    } catch (e) {
      Logger.error('Error starting OTP', error: e);
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e),
      );
    }
  }

  Future<bool> verifyOTP(String phoneNumber, String code) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final user = await _authUseCase.verifyOTP(phoneNumber, code);
      
      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
      );
      
      Logger.info('User authenticated successfully');
      return true;
    } catch (e) {
      Logger.error('Error verifying OTP', error: e);
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e),
      );
      return false;
    }
  }

  Future<void> updateUserSubjects(List<String> subjects) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      await _authUseCase.updateUserSubjects(subjects);
      
      // Update local user state
      if (state.user != null) {
        final updatedUser = state.user!.copyWith(subjects: subjects);
        state = state.copyWith(
          user: updatedUser,
          isLoading: false,
        );
      }
      
      Logger.info('User subjects updated successfully');
    } catch (e) {
      Logger.error('Error updating user subjects', error: e);
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e),
      );
    }
  }

  Future<void> refreshUser() async {
    try {
      final user = await _authUseCase.getCurrentUser();
      if (user != null) {
        state = state.copyWith(user: user);
        Logger.info('User data refreshed');
      }
    } catch (e) {
      Logger.error('Error refreshing user data', error: e);
    }
  }

  Future<void> logout() async {
    try {
      state = state.copyWith(isLoading: true);
      
      await _authUseCase.logout();
      
      state = const AuthState(
        isAuthenticated: false,
        isLoading: false,
      );
      
      Logger.info('User logged out successfully');
    } catch (e) {
      Logger.error('Error during logout', error: e);
      // Still clear the state even if logout fails
      state = const AuthState(
        isAuthenticated: false,
        isLoading: false,
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  String _getErrorMessage(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return error.toString();
  }
}

// Auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authUseCase = ref.watch(authUseCaseProvider);
  return AuthNotifier(authUseCase);
});

// Convenience providers
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final isAuthLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});

final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).error;
});
