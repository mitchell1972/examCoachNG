import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../domain/entities/user.dart';
import '../../../core/utils/validators.dart';

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

class AuthNotifier extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    final authRepo = ref.read(authRepositoryProvider);
    
    final isAuthenticated = await authRepo.isAuthenticated();
    if (!isAuthenticated) {
      return const AuthState();
    }

    final user = await authRepo.getCurrentUser();
    final token = await authRepo.getStoredToken();

    return AuthState(
      user: user,
      token: token,
    );
  }

  Future<void> startOtp(String phone) async {
    state = const AsyncValue.loading();
    
    try {
      final formattedPhone = Validators.formatPhoneNumber(phone);
      final authRepo = ref.read(authRepositoryProvider);
      
      await authRepo.startOtp(formattedPhone);
      
      state = AsyncValue.data(state.valueOrNull ?? const AuthState());
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> verifyOtp(String phone, String code) async {
    state = const AsyncValue.loading();
    
    try {
      final formattedPhone = Validators.formatPhoneNumber(phone);
      final authRepo = ref.read(authRepositoryProvider);
      
      final user = await authRepo.verifyOtp(formattedPhone, code);
      final token = await authRepo.getStoredToken();
      
      state = AsyncValue.data(AuthState(
        user: user,
        token: token,
      ));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> logout() async {
    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.logout();
      
      state = const AsyncValue.data(AuthState());
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> saveSelectedSubjects(List<String> subjects) async {
    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.saveSelectedSubjects(subjects);
      await authRepo.markOnboardingComplete();
    } catch (error) {
      // Handle error silently for non-critical operation
    }
  }

  Future<List<String>> getSelectedSubjects() async {
    final authRepo = ref.read(authRepositoryProvider);
    return await authRepo.getSelectedSubjects();
  }

  Future<bool> isOnboardingComplete() async {
    final authRepo = ref.read(authRepositoryProvider);
    return await authRepo.isOnboardingComplete();
  }
}
