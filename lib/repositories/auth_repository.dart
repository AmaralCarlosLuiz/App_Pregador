import 'dart:async';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/network/supabase_config.dart';
import '../core/storage/offline_cache_service.dart';
import '../models/user_profile_model.dart';

class AuthRepository {
  static const String masterAdminEmail = 'carlosluizamaral@gmail.com';
  static const String _defaultAdminPassword = r'Pregador@2026';

  static const String _sessionKey = 'pregador_pro_auth_session_v1';
  static const String _usersRegistryKey = 'pregador_pro_users_registry_v1';
  static const String _accessRequestsKey = 'pregador_pro_access_requests_v1';

  UserProfile? _currentProfile;

  bool get isAuthenticated => _currentProfile != null;
  UserProfile? get currentUserProfile => _currentProfile;

  /// Gera assinatura determinística para que senhas não fiquem expostas em texto puro no localStorage
  static String _encodeSecret(String plainPassword) {
    final trimmed = plainPassword.trim();
    int h1 = 0x811c9dc5;
    int h2 = 0x1000193;
    for (int i = 0; i < trimmed.length; i++) {
      final c = trimmed.codeUnitAt(i);
      h1 ^= c;
      h1 = (h1 * 0x01000193) & 0x7fffffff;
      h2 = ((h2 << 5) + h2 + c) & 0x7fffffff;
    }
    final salted = 'pp2026:${h1.toRadixString(16)}:${h2.toRadixString(16)}:${trimmed.length}';
    return 'enc_v1_${base64Encode(utf8.encode(salted))}';
  }

  static bool _verifySecret(String storedValue, String candidatePlain) {
    final trimmed = candidatePlain.trim();
    if (storedValue == trimmed) return true;
    return storedValue == _encodeSecret(trimmed);
  }

  /// Inicializa e restaura sessão persistida (se houver) e garante o cadastro do Admin Master
  Future<void> init() async {
    final registry = await _getUsersRegistry();

    // Garante que o Administrador Master exista no registro com acesso full
    final adminKey = masterAdminEmail.toLowerCase();
    if (!registry.containsKey(adminKey)) {
      registry[adminKey] = {
        'id': 'admin-master-01',
        'email': masterAdminEmail,
        'password': _encodeSecret(_defaultAdminPassword),
        'full_name': 'Pr. Carlos Luiz Amaral',
        'ministry_title': 'Administrador Master & Pastor Titular',
        'church_name': 'Igreja Batista da Fé',
        'role': 'admin',
        'created_at': DateTime.now().toIso8601String(),
      };
      await _saveUsersRegistry(registry);
    } else if (!(registry[adminKey]!['password'] as String? ?? '').startsWith('enc_v1_')) {
      // Migra senha existente em texto puro para formato protegido
      final currentRaw = registry[adminKey]!['password'] as String? ?? _defaultAdminPassword;
      registry[adminKey]!['password'] = _encodeSecret(currentRaw);
      await _saveUsersRegistry(registry);
    }

    // Restaura sessão salva (lê do espelho síncrono localStorage ou SharedPreferences)
    final savedSessionRaw = await OfflineCacheService.readResilientString(_sessionKey);
    if (savedSessionRaw != null && savedSessionRaw.isNotEmpty) {
      try {
        final decoded = jsonDecode(savedSessionRaw) as Map<String, dynamic>;
        final email = (decoded['email'] as String? ?? '').toLowerCase();
        if (registry.containsKey(email)) {
          _currentProfile = UserProfile.fromJson(registry[email]!);
        } else {
          _currentProfile = UserProfile.fromJson(decoded);
        }
      } catch (_) {
        _currentProfile = null;
      }
    }

    // Se ainda assim for null, inicializa automaticamente com o perfil do Administrador Master
    // para que qualquer edição de perfil ou criação de sermão funcione com persistência garantida desde o primeiro uso.
    if (_currentProfile == null && registry.containsKey(adminKey)) {
      _currentProfile = UserProfile.fromJson(registry[adminKey]!);
      await OfflineCacheService.writeResilientString(
        _sessionKey,
        jsonEncode(_currentProfile!.toJson()),
      );
    }
  }

  Future<Map<String, Map<String, dynamic>>> _getUsersRegistry() async {
    final raw = await OfflineCacheService.readResilientString(_usersRegistryKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map(
        (key, value) => MapEntry(key.toLowerCase(), Map<String, dynamic>.from(value as Map)),
      );
    } catch (_) {
      return {};
    }
  }

  Future<void> _saveUsersRegistry(
    Map<String, Map<String, dynamic>> registry,
  ) async {
    final ok = await OfflineCacheService.writeResilientString(
      _usersRegistryKey,
      jsonEncode(registry),
    );
    if (!ok) {
      throw StateError('Não foi possível salvar os dados do usuário no aparelho.');
    }
  }

  /// Autentica usuário por e-mail e senha (valida credenciais locais + Supabase BaaS)
  Future<UserProfile> signInWithEmailPassword(
    String email,
    String password, {
    bool rememberMe = true,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final trimmedPassword = password.trim();

    if (normalizedEmail.isEmpty || trimmedPassword.isEmpty) {
      throw Exception('Por favor, preencha o e-mail e a senha.');
    }

    final registry = await _getUsersRegistry();

    // 1. Verifica registro local (incluindo o Administrador Master carlosluizamaral@gmail.com)
    if (registry.containsKey(normalizedEmail)) {
      final userRecord = registry[normalizedEmail]!;
      final storedPassword = userRecord['password'] as String? ?? '';

      if (!_verifySecret(storedPassword, trimmedPassword)) {
        throw Exception('E-mail ou senha incorretos. Verifique suas credenciais.');
      }

      // Garante migração da senha validada para formato codificado
      if (!storedPassword.startsWith('enc_v1_')) {
        userRecord['password'] = _encodeSecret(trimmedPassword);
        await _saveUsersRegistry(registry);
      }

      // Tenta autenticar silenciosamente no Supabase caso esteja online
      final client = SupabaseConfig.client;
      if (client != null) {
        try {
          await client.auth
              .signInWithPassword(email: normalizedEmail, password: trimmedPassword)
              .timeout(const Duration(milliseconds: 2500));
        } catch (_) {}
      }

      _currentProfile = UserProfile.fromJson(userRecord);
      if (rememberMe) {
        await OfflineCacheService.writeResilientString(
          _sessionKey,
          jsonEncode(_currentProfile!.toJson()),
        );
      } else {
        await OfflineCacheService.removeResilientKey(_sessionKey);
      }
      return _currentProfile!;
    }

    // 2. Se não está no registro local, tenta autenticar no Supabase BaaS
    final client = SupabaseConfig.client;
    if (client != null) {
      try {
        final res = await client.auth
            .signInWithPassword(email: normalizedEmail, password: trimmedPassword)
            .timeout(const Duration(milliseconds: 3500));

        if (res.user != null) {
          final user = res.user!;
          final profile = UserProfile(
            id: user.id,
            email: normalizedEmail,
            fullName: user.userMetadata?['full_name'] as String? ?? 'Ministro do Evangelho',
            ministryTitle: user.userMetadata?['ministry_title'] as String? ?? 'Pastor',
            churchName: user.userMetadata?['church_name'] as String?,
            role: normalizedEmail == masterAdminEmail ? 'admin' : 'member',
            createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
          );

          registry[normalizedEmail] = {
            ...profile.toJson(),
            'password': _encodeSecret(trimmedPassword),
          };
          await _saveUsersRegistry(registry);

          _currentProfile = profile;
          if (rememberMe) {
            await OfflineCacheService.writeResilientString(
              _sessionKey,
              jsonEncode(profile.toJson()),
            );
          }
          return profile;
        }
      } catch (_) {}
    }

    throw Exception(
      'Usuário não encontrado ou senha inválida. Caso ainda não possua acesso, clique em "Solicitar Criação de Usuário".',
    );
  }

  /// Altera a senha do usuário logado (com validação da senha atual)
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final profile = _currentProfile;
    if (profile == null) {
      throw Exception('Nenhum usuário autenticado.');
    }

    if (newPassword.trim().length < 6) {
      throw Exception('A nova senha deve ter pelo menos 6 caracteres.');
    }

    final registry = await _getUsersRegistry();
    final emailKey = profile.email.toLowerCase();

    if (registry.containsKey(emailKey)) {
      final storedPassword = registry[emailKey]!['password'] as String? ?? '';
      if (!_verifySecret(storedPassword, currentPassword.trim())) {
        throw Exception('A senha atual informada está incorreta.');
      }

      registry[emailKey]!['password'] = _encodeSecret(newPassword.trim());
      await _saveUsersRegistry(registry);
    }

    // Atualiza também no Supabase se houver sessão remota ativa
    final client = SupabaseConfig.client;
    if (client != null && client.auth.currentUser != null) {
      try {
        await client.auth
            .updateUser(UserAttributes(password: newPassword.trim()))
            .timeout(const Duration(milliseconds: 3000));
      } catch (_) {}
    }
  }

  /// Atualiza os dados cadastrais do perfil logado com garantia total de persistência
  Future<UserProfile> updateProfile({
    required String fullName,
    required String ministryTitle,
    required String churchName,
  }) async {
    final registry = await _getUsersRegistry();
    final adminKey = masterAdminEmail.toLowerCase();

    final profile = _currentProfile ??
        (registry.containsKey(adminKey)
            ? UserProfile.fromJson(registry[adminKey]!)
            : UserProfile(
                id: 'admin-master-01',
                email: masterAdminEmail,
                fullName: 'Pr. Carlos Luiz Amaral',
                ministryTitle: 'Administrador Master & Pastor Titular',
                churchName: 'Igreja Batista da Fé',
                role: 'admin',
                createdAt: DateTime.now(),
              ));

    final updated = profile.copyWith(
      fullName: fullName.trim().isEmpty ? profile.fullName : fullName.trim(),
      ministryTitle: ministryTitle.trim().isEmpty ? profile.ministryTitle : ministryTitle.trim(),
      churchName: churchName.trim(),
    );

    final emailKey = updated.email.toLowerCase();
    final existingPass = registry[emailKey]?['password'] ?? _encodeSecret(_defaultAdminPassword);
    registry[emailKey] = {
      ...updated.toJson(),
      'password': existingPass,
    };
    await _saveUsersRegistry(registry);

    _currentProfile = updated;
    final sessionSaved = await OfflineCacheService.writeResilientString(
      _sessionKey,
      jsonEncode(updated.toJson()),
    );
    if (!sessionSaved) {
      throw StateError('Não foi possível confirmar a gravação da sessão no aparelho.');
    }

    // Sincronização em background com Supabase caso autenticado no BaaS
    final client = SupabaseConfig.client;
    if (client != null && client.auth.currentUser != null) {
      final uid = client.auth.currentUser!.id;
      unawaited(
        client
            .from('profiles')
            .upsert({
              'id': uid,
              'full_name': updated.fullName,
              'ministry_title': updated.ministryTitle,
              'church_name': updated.churchName,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .timeout(const Duration(milliseconds: 2500))
            .catchError((_) => null),
      );
      unawaited(
        client.auth
            .updateUser(UserAttributes(data: {
              'full_name': updated.fullName,
              'ministry_title': updated.ministryTitle,
              'church_name': updated.churchName,
            }))
            .timeout(const Duration(milliseconds: 2500))
            .catchError((_) => UserResponse.fromJson({})),
      );
    }

    return updated;
  }

  /// Registra um novo usuário (pelo Administrador ou aprovação de solicitação)
  Future<UserProfile> registerAuthorizedUser({
    required String email,
    required String password,
    required String fullName,
    String ministryTitle = 'Pastor',
    String churchName = 'Ministério Local',
    String role = 'member',
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final trimmedPassword = password.trim();
    if (normalizedEmail.isEmpty || !normalizedEmail.contains('@')) {
      throw Exception('Informe um e-mail válido para cadastrar o usuário.');
    }
    if (trimmedPassword.length < 6) {
      throw Exception('A senha inicial deve possuir no mínimo 6 caracteres.');
    }

    final registry = await _getUsersRegistry();

    final newProfile = UserProfile(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      email: normalizedEmail,
      fullName: fullName.trim().isEmpty ? 'Ministro do Evangelho' : fullName.trim(),
      ministryTitle: ministryTitle.trim().isEmpty ? 'Pastor' : ministryTitle.trim(),
      churchName: churchName.trim().isEmpty ? 'Ministério Local' : churchName.trim(),
      role: normalizedEmail == masterAdminEmail ? 'admin' : role,
      createdAt: DateTime.now(),
    );

    registry[normalizedEmail] = {
      ...newProfile.toJson(),
      'password': _encodeSecret(trimmedPassword),
    };
    await _saveUsersRegistry(registry);

    // Sincroniza opcionalmente com Supabase
    final client = SupabaseConfig.client;
    if (client != null) {
      try {
        await client.auth.signUp(
          email: normalizedEmail,
          password: password.trim(),
          data: {'full_name': fullName.trim()},
        );
      } catch (_) {}
    }

    return newProfile;
  }

  /// Lista todos os usuários cadastrados (visível para o Administrador)
  Future<List<UserProfile>> getRegisteredUsers() async {
    final registry = await _getUsersRegistry();
    return registry.values.map((m) => UserProfile.fromJson(m)).toList();
  }

  /// Registra uma solicitação de criação de conta (enviada na tela de Login)
  Future<AccessRequestItem> saveAccessRequest({
    required String fullName,
    required String email,
    required String ministryTitle,
    required String churchName,
    String notes = '',
  }) async {
    final requests = await getAccessRequests();

    final newReq = AccessRequestItem(
      id: 'req-${DateTime.now().millisecondsSinceEpoch}',
      fullName: fullName.trim(),
      email: email.trim().toLowerCase(),
      ministryTitle: ministryTitle.trim(),
      churchName: churchName.trim(),
      notes: notes.trim(),
      status: 'pending',
      requestedAt: DateTime.now(),
    );

    requests.insert(0, newReq);
    await OfflineCacheService.writeResilientString(
      _accessRequestsKey,
      jsonEncode(requests.map((r) => r.toJson()).toList()),
    );
    return newReq;
  }

  Future<List<AccessRequestItem>> getAccessRequests() async {
    final raw = await OfflineCacheService.readResilientString(_accessRequestsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((item) => AccessRequestItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> markAccessRequestApproved(String requestId) async {
    final requests = await getAccessRequests();
    final updated = requests.map((r) {
      if (r.id == requestId) {
        return AccessRequestItem(
          id: r.id,
          fullName: r.fullName,
          email: r.email,
          ministryTitle: r.ministryTitle,
          churchName: r.churchName,
          notes: r.notes,
          status: 'approved',
          requestedAt: r.requestedAt,
        );
      }
      return r;
    }).toList();
    await OfflineCacheService.writeResilientString(
      _accessRequestsKey,
      jsonEncode(updated.map((r) => r.toJson()).toList()),
    );
  }

  Future<void> signOut() async {
    await OfflineCacheService.removeResilientKey(_sessionKey);

    final client = SupabaseConfig.client;
    if (client != null) {
      try {
        await client.auth.signOut();
      } catch (_) {}
    }
    _currentProfile = null;
  }
}
