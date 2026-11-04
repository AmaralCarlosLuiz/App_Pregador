import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../repositories/auth_repository.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    ref.read(authProvider.notifier).clearError();
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authProvider.notifier).signIn(
          _emailController.text.trim(),
          _passwordController.text,
          rememberMe: _rememberMe,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final size = MediaQuery.sizeOf(context);
    final isWideScreen = size.width >= 920;

    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      body: Stack(
        children: [
          // Background Gradiente Executivo Profundo
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF060911),
                    Color(0xFF0F172A),
                    Color(0xFF172554),
                  ],
                ),
              ),
            ),
          ),

          // Efeitos de Iluminação Radial (Glow)
          Positioned(
            top: -120,
            left: -80,
            child: Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryElectricBlue.withValues(alpha: 0.22),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -140,
            right: -80,
            child: Container(
              width: 420,
              height: 420,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accentGold.withValues(alpha: 0.16),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Conteúdo Responsivo (Split-Screen em Desktop / Card Centralizado em Mobile & Tablet)
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width < 600 ? 20 : 40,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isWideScreen ? 1060 : 460),
                  child: isWideScreen
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 11,
                              child: _buildBrandShowcase(context),
                            ),
                            const SizedBox(width: 48),
                            Expanded(
                              flex: 9,
                              child: _buildLoginCard(context, authState),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildCompactMobileHeader(),
                            const SizedBox(height: 24),
                            _buildLoginCard(context, authState),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactMobileHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.auto_stories, color: Colors.white, size: 32),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Pregador',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.6,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFB45309)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'PRO',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Plataforma Homilética & Exegética de Alta Performance',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withValues(alpha: 0.72),
          ),
        ),
      ],
    );
  }

  Widget _buildBrandShowcase(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Badge Superior
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.accentGold.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.4)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified_user, size: 15, color: Color(0xFFFBBF24)),
              SizedBox(width: 8),
              Text(
                'AMBIENTE EXCLUSIVO PARA MINISTROS & OBREIROS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFFBBF24),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Logotipo & Título
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(Icons.auto_stories, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Pregador',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF59E0B), Color(0xFFB45309)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'PRO',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
                const Text(
                  'Bancada Homilética & Bíblica Offline-First',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 28),

        const Text(
          'Prepare, estruture e ministre sermões com excelência teológica.',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.3,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 24),

        // Pilares da Plataforma
        _buildFeatureRow(
          Icons.menu_book_rounded,
          '6 Traduções Bíblicas 100% Offline',
          'ARC, ARA, NAA, NVI, ACF e King James 1611 com comparador simultâneo.',
        ),
        const SizedBox(height: 14),
        _buildFeatureRow(
          Icons.auto_awesome,
          'Assistente Homilético IA & 150 Modelos Prontos',
          'Esboços completos de 5 tópicos com exegese, léxico grego/hebraico e aplicação.',
        ),
        const SizedBox(height: 14),
        _buildFeatureRow(
          Icons.mic_external_on,
          'Modo Púlpito de Alto Contraste OLED',
          'Cronômetro regressivo inteligente, controle de tipografia e tela sempre acesa.',
        ),
        const SizedBox(height: 28),

        // Versículo Inspiracional
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.format_quote, color: Color(0xFFFBBF24), size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '"Procura apresentar-te a Deus aprovado, como obreiro que não tem de que se envergonhar, que maneja bem a palavra da verdade."',
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '— 2 Timóteo 2:15',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFBBF24),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureRow(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryElectricBlue.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.primaryElectricBlue.withValues(alpha: 0.35),
            ),
          ),
          child: Icon(icon, color: const Color(0xFF60A5FA), size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF94A3B8),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard(BuildContext context, AuthState authState) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF131B2E).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF334155).withValues(alpha: 0.8),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 32,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: AppColors.primaryElectricBlue.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Acesso à Plataforma',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Entre com suas credenciais para acessar seu acervo homilético',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 24),

            // Mensagem de Erro (se houver)
            if (authState.errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Color(0xFFF87171), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        authState.errorMessage!,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFFFCA5A5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
            ],

            // Campo E-mail
            const Text(
              'E-mail de Acesso',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFFCBD5E1),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              textInputAction: TextInputAction.next,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'seuemail@exemplo.com',
                hintStyle: const TextStyle(color: Color(0xFF64748B)),
                prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF94A3B8), size: 20),
                filled: true,
                fillColor: const Color(0xFF090D16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF334155)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF334155)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryElectricBlue, width: 1.8),
                ),
              ),
              validator: (val) {
                final text = val?.trim() ?? '';
                if (text.isEmpty) return 'Informe seu e-mail';
                if (!text.contains('@') || !text.contains('.')) {
                  return 'Informe um e-mail válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),

            // Campo Senha
            const Text(
              'Senha',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFFCBD5E1),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submitLogin(),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Digite sua senha',
                hintStyle: const TextStyle(color: Color(0xFF64748B)),
                prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF94A3B8), size: 20),
                suffixIcon: IconButton(
                  tooltip: _obscurePassword ? 'Mostrar senha' : 'Ocultar senha',
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: const Color(0xFF94A3B8),
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
                filled: true,
                fillColor: const Color(0xFF090D16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF334155)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF334155)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryElectricBlue, width: 1.8),
                ),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) return 'Informe sua senha';
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Opção Lembrar Acesso
            Row(
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                    value: _rememberMe,
                    activeColor: AppColors.primaryElectricBlue,
                    onChanged: (v) => setState(() => _rememberMe = v ?? true),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(() => _rememberMe = !_rememberMe),
                  child: const Text(
                    'Manter conectado neste dispositivo',
                    style: TextStyle(fontSize: 12.5, color: Color(0xFFCBD5E1)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            // Botão Entrar 3D
            SizedBox(
              height: 50,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryElectricBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                ),
                onPressed: authState.isLoading ? null : _submitLogin,
                child: authState.isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.login, size: 19),
                          SizedBox(width: 10),
                          Text(
                            'Entrar na Plataforma',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 24),
            const Divider(color: Color(0xFF1E293B), height: 1),
            const SizedBox(height: 20),

            // Seção: Solicitar Criação de Usuário (Por E-mail)
            const Text(
              'Ainda não possui credenciais de acesso?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFFBBF24),
                side: BorderSide(color: AppColors.accentGold.withValues(alpha: 0.6), width: 1.2),
                padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.mark_email_read_outlined, size: 18),
              label: const Text(
                'Solicitar Criação de Usuário por E-mail',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              onPressed: () => _showRequestAccountDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showRequestAccountDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final churchCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String selectedMinistryRole = 'Pastor';
    final formKey = GlobalKey<FormState>();

    const ministryRoles = [
      'Pastor',
      'Pastor Auxiliar',
      'Evangelista',
      'Presbítero',
      'Missionário(a)',
      'Diácono / Obreiro',
      'Professor(a) de EBD / Teologia',
      'Seminarista',
      'Líder de Ministério',
    ];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF131B2E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFF334155)),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accentGold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.person_add_alt_1, color: Color(0xFFFBBF24), size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Solicitar Criação de Usuário',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Envie seus dados por e-mail ao Administrador',
                          style: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 460,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryElectricBlue.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.primaryElectricBlue.withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline, size: 18, color: Color(0xFF60A5FA)),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Sua solicitação será encaminhada para aprovação do Administrador (carlosluizamaral@gmail.com).',
                                  style: TextStyle(fontSize: 12, color: Color(0xFFBFDBFE)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: nameCtrl,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: const InputDecoration(
                            labelText: 'Nome Completo *',
                            hintText: 'Ex: Pr. João da Silva',
                            prefixIcon: Icon(Icons.person_outline, size: 18),
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Informe seu nome completo' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: const InputDecoration(
                            labelText: 'Seu E-mail para Cadastro *',
                            hintText: 'Ex: joao@igreja.com.br',
                            prefixIcon: Icon(Icons.email_outlined, size: 18),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty || !v.contains('@')) {
                              return 'Informe um e-mail válido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: selectedMinistryRole,
                          dropdownColor: const Color(0xFF1E293B),
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: const InputDecoration(
                            labelText: 'Cargo / Função Ministerial',
                            prefixIcon: Icon(Icons.workspace_premium_outlined, size: 18),
                          ),
                          items: ministryRoles
                              .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setDialogState(() => selectedMinistryRole = v);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: churchCtrl,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: const InputDecoration(
                            labelText: 'Igreja / Denominação *',
                            hintText: 'Ex: Igreja Batista Central',
                            prefixIcon: Icon(Icons.church_outlined, size: 18),
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Informe o nome da igreja' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: notesCtrl,
                          maxLines: 2,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: const InputDecoration(
                            labelText: 'Mensagem / Observação (Opcional)',
                            hintText: 'Telefone/WhatsApp para retorno ou observações...',
                            prefixIcon: Icon(Icons.notes_outlined, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar', style: TextStyle(color: Color(0xFF94A3B8))),
                ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accentGold,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.send, size: 16),
                  label: const Text(
                    'Enviar Solicitação por E-mail',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;

                    final fullName = nameCtrl.text.trim();
                    final email = emailCtrl.text.trim();
                    final church = churchCtrl.text.trim();
                    final notes = notesCtrl.text.trim();

                    // 1. Registra a solicitação localmente para o painel do Administrador
                    final repo = ref.read(authRepositoryProvider);
                    await repo.saveAccessRequest(
                      fullName: fullName,
                      email: email,
                      ministryTitle: selectedMinistryRole,
                      churchName: church,
                      notes: notes,
                    );

                    // 2. Dispara o e-mail para o Administrador Master (carlosluizamaral@gmail.com)
                    final subject = Uri.encodeComponent(
                      'Solicitação de Criação de Usuário - Pregador Pro ($fullName)',
                    );
                    final bodyText = '''
Olá Administrador (Pr. Carlos Luiz Amaral),

Solicito a criação do meu usuário de acesso na plataforma Pregador Pro:

• Nome Completo: $fullName
• E-mail para Login: $email
• Cargo Ministerial: $selectedMinistryRole
• Igreja / Ministério: $church
• Observações / Contato: ${notes.isEmpty ? 'Não informado' : notes}

Data da Solicitação: ${DateTime.now().toIso8601String().substring(0, 10)}
''';
                    final body = Uri.encodeComponent(bodyText);
                    final mailtoUri = Uri.parse(
                      'mailto:${AuthRepository.masterAdminEmail}?subject=$subject&body=$body',
                    );

                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                    }

                    try {
                      await launchUrl(mailtoUri, mode: LaunchMode.externalApplication);
                    } catch (_) {
                      await Clipboard.setData(ClipboardData(text: bodyText));
                    }

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Solicitação registrada e preparada para envio a carlosluizamaral@gmail.com!',
                          ),
                          backgroundColor: AppColors.statusReady,
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 5),
                        ),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      nameCtrl.dispose();
      emailCtrl.dispose();
      churchCtrl.dispose();
      notesCtrl.dispose();
    });
  }
}

