import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  SupabaseConfig._();

  // Projeto Supabase Oficial - Pregador Pro
  static const String supabaseUrl = 'https://yahvhltbfpebaievpumg.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlhaHZobHRiZnBlYmFpZXZwdW1nIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTE4NTczOTUsImV4cCI6MjEwNzQzMzM5NX0.JoosKRUGOPWq4DzGt9oNObzdoAOnZXi0Va1YHsfUUuU';

  static bool _isInitialized = false;
  static bool _isInitializing = false;
  static bool get isInitialized => _isInitialized;

  /// Inicialização não-bloqueante com timeout curto para nunca atrasar o boot do app
  static Future<void> initialize() async {
    if (_isInitialized || _isInitializing) return;
    _isInitializing = true;
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        publishableKey: supabaseAnonKey,
      ).timeout(const Duration(milliseconds: 1200));
      _isInitialized = true;
    } catch (_) {
      // Supabase continuará com fallback offline-first instantâneo quando sem rede
      _isInitialized = false;
    } finally {
      _isInitializing = false;
    }
  }

  static SupabaseClient? get client {
    if (_isInitialized) {
      try {
        return Supabase.instance.client;
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
