import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile_model.dart';
import '../repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

class AuthState {
  final bool isInitialized;
  final bool isAuthenticated;
  final bool isLoading;
  final UserProfile? userProfile;
  final String? errorMessage;

  const AuthState({
    this.isInitialized = true,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.userProfile,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isInitialized,
    bool? isAuthenticated,
    bool? isLoading,
    UserProfile? userProfile,
    bool clearProfile = false,
    String? errorMessage,
  }) {
    return AuthState(
      isInitialized: isInitialized ?? this.isInitialized,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      userProfile: clearProfile ? null : (userProfile ?? this.userProfile),
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthNotifier(this._repo)
      : super(AuthState(
          isInitialized: true,
          isAuthenticated: _repo.isAuthenticated,
          userProfile: _repo.currentUserProfile,
        )) {
    if (!_repo.isAuthenticated) {
      _ensureInitialized();
    }
  }

  Future<void> _ensureInitialized() async {
    await _repo.init();
    if (!mounted) return;
    state = AuthState(
      isInitialized: true,
      isAuthenticated: _repo.isAuthenticated,
      userProfile: _repo.currentUserProfile,
    );
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
  }

  Future<bool> signIn(
    String email,
    String password, {
    bool rememberMe = true,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final profile = await _repo.signInWithEmailPassword(
        email,
        password,
        rememberMe: rememberMe,
      );
      if (!mounted) return false;
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        userProfile: profile,
        errorMessage: null,
      );
      return true;
    } catch (e) {
      if (!mounted) return false;
      final cleanMsg = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(isLoading: false, errorMessage: cleanMsg);
      return false;
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _repo.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  Future<void> updateProfile({
    required String fullName,
    required String ministryTitle,
    required String churchName,
  }) async {
    final updated = await _repo.updateProfile(
      fullName: fullName,
      ministryTitle: ministryTitle,
      churchName: churchName,
    );
    if (!mounted) return;
    state = state.copyWith(userProfile: updated);
  }

  Future<void> signOut() async {
    await _repo.signOut();
    if (!mounted) return;
    state = const AuthState(
      isInitialized: true,
      isAuthenticated: false,
      userProfile: null,
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo);
});
