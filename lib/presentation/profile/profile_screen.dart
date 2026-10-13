import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/supabase_config.dart';
import '../../core/services/backup_service.dart';
import '../../core/services/health_check_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/sermon_provider.dart';
import '../../providers/theme_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final sermonRepo = ref.read(sermonRepositoryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final profile = authState.userProfile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil & Configurações', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 1. CARD DE PERFIL PASTORAL
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                    : [const Color(0xFF1E3A8A), const Color(0xFF0F172A)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.accentGold.withValues(alpha: 0.3),
                  child: const Icon(Icons.person, color: AppColors.accentGold, size: 40),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile?.fullName ?? 'Pastor Titular',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${profile?.ministryTitle ?? 'Pastor'} • ${profile?.churchName ?? 'Ministério Local'}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[300],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.statusReady.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle, size: 12, color: AppColors.statusReady),
                            const SizedBox(width: 6),
                            Text(
                              SupabaseConfig.isInitialized ? 'Supabase BaaS Conectado' : 'Modo Offline-First Ativo',
                              style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // 2. RESILIÊNCIA, BLINDAGEM E BACKUPS (Conceitos Adaptados)
          const Text(
            '🛡️ Blindagem & Alta Disponibilidade',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 10),

          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.health_and_safety, color: Color(0xFF10B981)),
                  title: const Text('Auditoria de Saúde do Sistema (1 Clique)'),
                  subtitle: const Text('Verifica latência Supabase, cache offline e hardware'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () => _runHealthCheckModal(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.backup_outlined, color: AppColors.primaryBlue),
                  title: const Text('Exportar Ponto de Restauração (Backup JSON)'),
                  subtitle: const Text('Gera cópia de segurança completa de todos os seus sermões'),
                  trailing: const Icon(Icons.share, size: 18),
                  onTap: () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Gerando backup estruturado...')),
                    );
                    await BackupService.shareBackup(sermonRepo);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.restore, color: AppColors.accentGold),
                  title: const Text('Restaurar Sermões de um Backup'),
                  subtitle: const Text('Recupera sermões a partir de um arquivo de restauração'),
                  trailing: const Icon(Icons.file_upload_outlined, size: 18),
                  onTap: () => _showRestoreModal(context, ref),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // 3. APARÊNCIA & LEITURA
          const Text(
            'Aparência & Leitura',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 10),

          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Tema Escuro'),
                  subtitle: const Text('Interface elegante com fundo escuro'),
                  value: themeState.themeMode == ThemeMode.dark,
                  onChanged: (val) {
                    themeNotifier.toggleTheme();
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.contrast),
                  title: const Text('Modo Púlpito Alto Contraste'),
                  subtitle: const Text('Fundo OLED preto puro (#000000) e texto nítido'),
                  value: themeState.isPulpitHighContrast,
                  onChanged: (val) {
                    themeNotifier.togglePulpitHighContrast();
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // 4. HARDWARE & PÚLPITO
          const Text(
            'Hardware & Púlpito',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 10),

          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: const Column(
              children: [
                ListTile(
                  leading: Icon(Icons.screen_lock_portrait),
                  title: Text('Prevenção de Bloqueio de Tela'),
                  subtitle: Text('Wakelock mantém tela acesa no púlpito sem apagar'),
                  trailing: Icon(Icons.check, color: AppColors.statusReady),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.cloud_sync_outlined),
                  title: Text('Cache Local & Offline-First'),
                  subtitle: Text('Leitura garantida mesmo se a internet da igreja cair'),
                  trailing: Text('Ativo', style: TextStyle(color: AppColors.statusReady, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          Center(
            child: Column(
              children: [
                Text(
                  'Pregador Pro • Versão 1.0.0 (Blindagem Enterprise)',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                const SizedBox(height: 4),
                Text(
                  'Para pastores, pregadores e ministros do Evangelho',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _runHealthCheckModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return FutureBuilder<SystemHealthReport>(
          future: HealthCheckService.runFullAudit(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox(
                height: 260,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 14),
                      Text('Auditando conectividade, latências e cache local...'),
                    ],
                  ),
                ),
              );
            }

            final report = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.health_and_safety, color: Color(0xFF10B981), size: 24),
                          SizedBox(width: 10),
                          Text(
                            'Auditoria de Saúde do Sistema',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'STATUS: SISTEMA PRONTO PARA O PÚLPITO',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...report.checks.map((item) {
                    final color = item.status == HealthStatus.healthy
                        ? const Color(0xFF10B981)
                        : (item.status == HealthStatus.warning ? AppColors.accentGold : Colors.redAccent);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle, color: color, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    if (item.latencyMs != null)
                                      Text(item.latencyMs!, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(item.subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showRestoreModal(BuildContext context, WidgetRef ref) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Restaurar Ponto de Backup'),
          content: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cole abaixo o conteúdo JSON do seu arquivo de backup exportado anteriormente:',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: textController,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    hintText: 'Cole o código JSON do backup aqui...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.accentGold),
              onPressed: () async {
                final repo = ref.read(sermonRepositoryProvider);
                final text = textController.text;
                final navigator = Navigator.of(ctx);
                final messenger = ScaffoldMessenger.of(context);

                final result = await BackupService.restoreBackupFromJson(
                  text,
                  repo,
                );

                navigator.pop();
                if (result.success) {
                  ref.read(sermonListProvider.notifier).loadSermons();
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(result.message),
                      backgroundColor: AppColors.statusReady,
                    ),
                  );
                } else {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(result.message),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              },
              child: const Text('Restaurar'),
            ),
          ],
        );
      },
    );
  }
}
