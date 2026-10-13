import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/network/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'presentation/navigation/adaptive_navigation_shell.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialização resiliente do Supabase BaaS (com fallback offline-first)
  await SupabaseConfig.initialize();

  runApp(
    const ProviderScope(
      child: PregadorProApp(),
    ),
  );
}

class PregadorProApp extends ConsumerWidget {
  const PregadorProApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);

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

      // Shell Adaptativo Multiplataforma
      home: const AdaptiveNavigationShell(),
    );
  }
}
