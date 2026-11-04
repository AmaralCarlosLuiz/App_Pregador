import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/supabase_config.dart';
import '../../core/services/backup_service.dart';
import '../../core/services/health_check_service.dart';
import '../../models/user_profile_model.dart';
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
    final isAdmin = profile?.isAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Perfil & Configurações',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.5)),
              ),
              icon: const Icon(Icons.logout, size: 16),
              label: const Text('Sair'),
              onPressed: () => _confirmSignOut(context, ref),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // 1. CARD DE PERFIL PASTORAL & CREDENCIAL ADMIN
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                        : [const Color(0xFF1E3A8A), const Color(0xFF0F172A)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isAdmin
                        ? AppColors.accentGold.withValues(alpha: 0.45)
                        : Colors.white.withValues(alpha: 0.1),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                            ),
                          ),
                          child: const CircleAvatar(
                            radius: 34,
                            backgroundColor: Color(0xFF0F172A),
                            child: Icon(Icons.person, color: AppColors.accentGold, size: 36),
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  Text(
                                    profile?.fullName ?? 'Pr. Carlos Luiz Amaral',
                                    style: const TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  if (isAdmin)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFFF59E0B), Color(0xFFB45309)],
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.verified_user, size: 11, color: Colors.white),
                                          SizedBox(width: 4),
                                          Text(
                                            'ADMINISTRADOR FULL',
                                            style: TextStyle(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.white,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${profile?.ministryTitle ?? 'Pastor'} • ${profile?.churchName ?? 'Ministério Local'}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[300],
                                ),
                              ),
                              if (profile?.email != null && profile!.email.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  profile.email,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF93C5FD),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: [
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
                                          SupabaseConfig.isInitialized
                                              ? 'Supabase BaaS Conectado'
                                              : 'Modo Offline-First Ativo',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // 2. SEGURANÇA, SENHA E CONTA (INCLUINDO PAINEL ADMIN)
              const Text(
                '🔐 Segurança, Credenciais & Administração',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 10),

              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.lock_reset, color: AppColors.accentGold),
                      title: const Text(
                        'Alterar Senha de Acesso',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Text('Atualize sua senha de login com segurança'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () => _showChangePasswordDialog(context, ref),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.badge_outlined, color: AppColors.primaryBlue),
                      title: const Text('Editar Dados Ministeriais do Perfil'),
                      subtitle: const Text('Atualizar nome, título pastoral e igreja'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () => _showEditProfileDialog(context, ref, profile),
                    ),
                    if (isAdmin) ...[
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.admin_panel_settings, color: Color(0xFF10B981)),
                        title: const Text(
                          'Painel do Administrador: Usuários & Solicitações',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text(
                          'Cadastrar novos usuários ou aprovar solicitações recebidas',
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'FULL ACCESS',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ),
                        onTap: () => _showAdminUsersSheet(context, ref),
                      ),
                    ],
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                      title: const Text(
                        'Sair da Conta / Trocar de Usuário (Logoff)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                        ),
                      ),
                      subtitle: const Text(
                        'Encerra a sessão atual e volta para a tela de Login',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.redAccent),
                      onTap: () => _confirmSignOut(context, ref),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // 3. RESILIÊNCIA, BLINDAGEM E BACKUPS
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

              // 4. APARÊNCIA & LEITURA
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

              // 5. HARDWARE & PÚLPITO
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
                      trailing: Text(
                        'Ativo',
                        style: TextStyle(color: AppColors.statusReady, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Center(
                child: Column(
                  children: [
                    Text(
                      '© 2026 - Pregador Pro',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Desenvolvido por Carlos Luiz Amaral',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Encerrar Sessão'),
          content: const Text(
            'Deseja realmente sair da sua conta? Seus sermões permanecem salvos no cache offline e na nuvem.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
              icon: const Icon(Icons.logout, size: 16),
              label: const Text('Sair da Conta'),
              onPressed: () {
                Navigator.pop(ctx);
                ref.read(authProvider.notifier).signOut();
              },
            ),
          ],
        );
      },
    );
  }

  void _showChangePasswordDialog(BuildContext context, WidgetRef ref) {
    final currentPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool obscureCurrent = true;
    bool obscureNew = true;
    String? dialogError;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.lock_reset, color: AppColors.accentGold),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Alterar Senha de Acesso',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 420,
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (dialogError != null) ...[
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  dialogError!,
                                  style: const TextStyle(fontSize: 12, color: Colors.redAccent),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      TextFormField(
                        controller: currentPassCtrl,
                        obscureText: obscureCurrent,
                        decoration: InputDecoration(
                          labelText: 'Senha Atual',
                          prefixIcon: const Icon(Icons.lock_outline, size: 18),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureCurrent ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              size: 18,
                            ),
                            onPressed: () => setDialogState(() => obscureCurrent = !obscureCurrent),
                          ),
                        ),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Digite sua senha atual' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: newPassCtrl,
                        obscureText: obscureNew,
                        decoration: InputDecoration(
                          labelText: 'Nova Senha',
                          prefixIcon: const Icon(Icons.key_outlined, size: 18),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureNew ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              size: 18,
                            ),
                            onPressed: () => setDialogState(() => obscureNew = !obscureNew),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().length < 6) {
                            return 'A nova senha deve ter no mínimo 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: confirmPassCtrl,
                        obscureText: obscureNew,
                        decoration: const InputDecoration(
                          labelText: 'Confirmar Nova Senha',
                          prefixIcon: Icon(Icons.verified_outlined, size: 18),
                        ),
                        validator: (v) {
                          if (v != newPassCtrl.text) {
                            return 'A confirmação não coincide com a nova senha';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primaryBlue),
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Salvar Nova Senha'),
                  onPressed: () async {
                    setDialogState(() => dialogError = null);
                    if (!formKey.currentState!.validate()) return;

                    try {
                      await ref.read(authProvider.notifier).changePassword(
                            currentPassword: currentPassCtrl.text,
                            newPassword: newPassCtrl.text,
                          );
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Senha alterada com sucesso!'),
                            backgroundColor: AppColors.statusReady,
                          ),
                        );
                      }
                    } catch (e) {
                      setDialogState(() {
                        dialogError = e.toString().replaceFirst('Exception: ', '');
                      });
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      currentPassCtrl.dispose();
      newPassCtrl.dispose();
      confirmPassCtrl.dispose();
    });
  }

  void _showEditProfileDialog(BuildContext context, WidgetRef ref, UserProfile? profile) {
    final nameCtrl = TextEditingController(text: profile?.fullName ?? '');
    final titleCtrl = TextEditingController(text: profile?.ministryTitle ?? 'Pastor');
    final churchCtrl = TextEditingController(text: profile?.churchName ?? '');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Editar Dados do Perfil'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nome de Exibição',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Título Ministerial',
                    prefixIcon: Icon(Icons.workspace_premium_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: churchCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Igreja / Ministério',
                    prefixIcon: Icon(Icons.church_outlined),
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
              onPressed: () async {
                await ref.read(authProvider.notifier).updateProfile(
                      fullName: nameCtrl.text,
                      ministryTitle: titleCtrl.text,
                      churchName: churchCtrl.text,
                    );
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Perfil atualizado com sucesso!'),
                      backgroundColor: AppColors.statusReady,
                    ),
                  );
                }
              },
              child: const Text('Salvar Alterações'),
            ),
          ],
        );
      },
    ).then((_) {
      nameCtrl.dispose();
      titleCtrl.dispose();
      churchCtrl.dispose();
    });
  }

  void _showAdminUsersSheet(BuildContext context, WidgetRef ref) {
    final repo = ref.read(authRepositoryProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.82,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.admin_panel_settings, color: Color(0xFF10B981), size: 24),
                            SizedBox(width: 10),
                            Text(
                              'Gestão de Acessos (Admin Full)',
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                              ),
                              icon: const Icon(Icons.person_add, size: 16),
                              label: const Text('Novo Usuário'),
                              onPressed: () async {
                                await _showCreateUserByAdminDialog(context, ref);
                                setModalState(() {});
                              },
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Expanded(
                      child: FutureBuilder(
                        future: Future.wait([
                          repo.getRegisteredUsers(),
                          repo.getAccessRequests(),
                        ]),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          final users = snapshot.data![0] as List<UserProfile>;
                          final requests = snapshot.data![1] as List<AccessRequestItem>;

                          return ListView(
                            children: [
                              if (requests.isNotEmpty) ...[
                                const Text(
                                  'SOLICITAÇÕES DE ACESSO RECEBIDAS:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.accentGold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...requests.map((req) {
                                  final isApproved = req.status == 'approved';
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    child: ListTile(
                                      leading: Icon(
                                        isApproved ? Icons.check_circle : Icons.pending_actions,
                                        color: isApproved ? AppColors.statusReady : AppColors.accentGold,
                                      ),
                                      title: Text(
                                        '${req.fullName} (${req.ministryTitle})',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text('${req.email} • ${req.churchName}'),
                                      trailing: isApproved
                                          ? const Chip(label: Text('Aprovado', style: TextStyle(fontSize: 11)))
                                          : FilledButton(
                                              style: FilledButton.styleFrom(
                                                backgroundColor: AppColors.statusReady,
                                              ),
                                              onPressed: () async {
                                                await repo.registerAuthorizedUser(
                                                  email: req.email,
                                                  password: 'Mudar@2026',
                                                  fullName: req.fullName,
                                                  ministryTitle: req.ministryTitle,
                                                  churchName: req.churchName,
                                                );
                                                await repo.markAccessRequestApproved(req.id);
                                                setModalState(() {});
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Usuário ${req.email} liberado com senha inicial: Mudar@2026',
                                                      ),
                                                      backgroundColor: AppColors.statusReady,
                                                    ),
                                                  );
                                                }
                                              },
                                              child: const Text('Liberar Acesso'),
                                            ),
                                    ),
                                  );
                                }),
                                const SizedBox(height: 20),
                              ],
                              Text(
                                'USUÁRIOS CADASTRADOS (${users.length}):',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...users.map((u) {
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: u.isAdmin
                                          ? AppColors.accentGold.withValues(alpha: 0.2)
                                          : AppColors.primaryBlue.withValues(alpha: 0.15),
                                      child: Icon(
                                        u.isAdmin ? Icons.verified_user : Icons.person,
                                        color: u.isAdmin ? AppColors.accentGold : AppColors.primaryBlue,
                                        size: 18,
                                      ),
                                    ),
                                    title: Text(
                                      u.fullName,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text('${u.email} • ${u.ministryTitle}'),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: (u.isAdmin ? AppColors.accentGold : AppColors.primaryBlue)
                                            .withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        u.isAdmin ? 'ADMIN FULL' : 'MEMBRO',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: u.isAdmin ? AppColors.accentGold : AppColors.primaryBlue,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showCreateUserByAdminDialog(BuildContext context, WidgetRef ref) async {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController(text: 'Mudar@2026');
    final titleCtrl = TextEditingController(text: 'Pastor');
    final churchCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Liberar Novo Usuário'),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Nome Completo'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(labelText: 'E-mail de Login'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: passCtrl,
                    decoration: const InputDecoration(labelText: 'Senha Inicial'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(labelText: 'Cargo Ministerial'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: churchCtrl,
                    decoration: const InputDecoration(labelText: 'Igreja'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                if (emailCtrl.text.trim().isEmpty || passCtrl.text.trim().isEmpty) return;
                await ref.read(authRepositoryProvider).registerAuthorizedUser(
                      email: emailCtrl.text,
                      password: passCtrl.text,
                      fullName: nameCtrl.text.trim().isEmpty ? 'Ministro' : nameCtrl.text,
                      ministryTitle: titleCtrl.text,
                      churchName: churchCtrl.text,
                    );
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Criar Usuário'),
            ),
          ],
        );
      },
    );

    nameCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    titleCtrl.dispose();
    churchCtrl.dispose();
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
                      const Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.health_and_safety, color: Color(0xFF10B981), size: 24),
                            SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                'Auditoria de Saúde do Sistema',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
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
                                    Expanded(
                                      child: Text(
                                        item.title,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ),
                                    if (item.latencyMs != null)
                                      Text(
                                        item.latencyMs!,
                                        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold),
                                      ),
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
    ).then((_) => textController.dispose());
  }
}
