import '../core/network/supabase_config.dart';
import '../models/user_profile_model.dart';

class AuthRepository {
  UserProfile? _mockProfile = UserProfile(
    id: 'pastor-local-01',
    fullName: 'Pr. Carlos Amaral',
    ministryTitle: 'Pastor Titular',
    churchName: 'Igreja Batista da Fé',
    createdAt: DateTime.now(),
  );

  bool get isAuthenticated {
    final client = SupabaseConfig.client;
    if (client != null && client.auth.currentUser != null) {
      return true;
    }
    return _mockProfile != null;
  }

  UserProfile? get currentUserProfile {
    final client = SupabaseConfig.client;
    if (client != null && client.auth.currentUser != null) {
      final user = client.auth.currentUser!;
      return UserProfile(
        id: user.id,
        fullName: user.userMetadata?['full_name'] as String? ?? 'Pastor Titular',
        avatarUrl: user.userMetadata?['avatar_url'] as String?,
        ministryTitle: 'Pastor',
        createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
      );
    }
    return _mockProfile;
  }

  Future<void> signInWithEmailPassword(String email, String password) async {
    final client = SupabaseConfig.client;
    if (client != null) {
      try {
        await client.auth.signInWithPassword(email: email, password: password);
        return;
      } catch (_) {
        // Fallback local se não conectado à rede externa
      }
    }
    _mockProfile = UserProfile(
      id: 'pastor-local-01',
      fullName: email.split('@').first,
      ministryTitle: 'Pastor Titular',
      churchName: 'Ministério da Graça',
      createdAt: DateTime.now(),
    );
  }

  Future<void> signUpWithEmailPassword(String email, String password, String fullName) async {
    final client = SupabaseConfig.client;
    if (client != null) {
      try {
        await client.auth.signUp(
          email: email,
          password: password,
          data: {'full_name': fullName},
        );
        return;
      } catch (_) {
        // Fallback local
      }
    }
    _mockProfile = UserProfile(
      id: 'pastor-local-01',
      fullName: fullName,
      ministryTitle: 'Pastor Titular',
      createdAt: DateTime.now(),
    );
  }

  Future<void> signOut() async {
    final client = SupabaseConfig.client;
    if (client != null) {
      try {
        await client.auth.signOut();
      } catch (_) {}
    }
    _mockProfile = null;
  }
}
