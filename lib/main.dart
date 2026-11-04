import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/network/supabase_config.dart';
import 'core/security/source_protection_wrapper.dart';
import 'core/theme/app_theme.dart';
import 'presentation/auth/login_screen.dart';
import 'presentation/navigation/adaptive_navigation_shell.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'repositories/auth_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inicializa sessão local instantaneamente (< 10ms) sem bloquear na rede
  final authRepo = AuthRepository();
  await authRepo.init();

  // 2. Dispara conexão com Supabase em background (Zero bloqueio de tela inicial)
  unawaited(SupabaseConfig.initialize());

  runApp(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepo),
      ],
      child: const PregadorProApp(),
    ),
  );
}

class PregadorProApp extends ConsumerWidget {
  const PregadorProApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'Pregador Pro',
      debugShowCheckedModeBanner: false,

      // Design System Material 3 e Temas
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeState.themeMode,

      // Suporte de Localização em Português do Brasil
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
        Locale('en', 'US'),
      ],

      // Camada Global de Blindagem e Proteção de Código Fonte (Botão Direito / F12)
      builder: (context, child) {
        return SourceProtectionWrapper(
          child: child ?? const SizedBox.shrink(),
        );
      },

      // Roteamento Instantâneo Protegido por Autenticação
      home: authState.isAuthenticated
          ? const AdaptiveNavigationShell()
          : const LoginScreen(),
    );
  }
}
