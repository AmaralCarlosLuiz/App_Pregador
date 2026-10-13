import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  SupabaseConfig._();

  // Projeto Supabase Oficial - Pregador Pro
  static const String supabaseUrl = 'https://yahvhltbfpebaievpumg.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlhaHZobHRiZnBlYmFpZXZwdW1nIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTE4NTczOTUsImV4cCI6MjEwNzQzMzM5NX0.JoosKRUGOPWq4DzGt9oNObzdoAOnZXi0Va1YHsfUUuU';

  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        publishableKey: supabaseAnonKey,
      );
      _isInitialized = true;
    } catch (_) {
      // Supabase continuará com fallback offline-first quando não conectado
      _isInitialized = false;
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
