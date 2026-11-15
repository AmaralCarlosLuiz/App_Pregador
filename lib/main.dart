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

  // 1. Restaura sessão local e preferências (tema claro/escuro, púlpito) ANTES do 1º frame,
  //    em paralelo (<10ms), para o app abrir já no tema salvo, sem "piscar".
  final authRepo = AuthRepository();
  final results = await Future.wait<Object?>([
    authRepo.init(),
    ThemeNotifier.loadSaved(),
  ]);
  final savedTheme = results[1] as ThemeState;

  // 2. Dispara conexão com Supabase em background (Zero bloqueio de tela inicial)
  unawaited(SupabaseConfig.initialize());

  runApp(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepo),
        themeProvider.overrideWith((ref) => ThemeNotifier(savedTheme)),
      ],
      child: const PregadorProApp(),
    ),
  );
}

class PregadorProApp extends ConsumerWidget {
  const PregadorProApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // select(): o app raiz só reconstrói quando o TEMA ou o LOGIN mudam (não a cada
    // alteração de perfil, fonte do púlpito etc.) — menos trabalho = toque mais fluido.
    final themeMode = ref.watch(themeProvider.select((s) => s.themeMode));
    final isAuthenticated = ref.watch(authProvider.select((s) => s.isAuthenticated));

    return MaterialApp(
      title: 'Pregador Pro',
      debugShowCheckedModeBanner: false,

      // Design System Material 3 e Temas
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

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
      home: isAuthenticated
          ? const AdaptiveNavigationShell()
          : const LoginScreen(),
    );
  }
}
