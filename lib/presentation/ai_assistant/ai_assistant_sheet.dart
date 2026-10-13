import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/ai_homiletics_service.dart';
import '../../core/services/sermon_share_service.dart';
import '../../providers/ai_assistant_provider.dart';
import '../../providers/sermon_provider.dart';
import '../editor/sermon_editor_screen.dart';

class AiAssistantSheet extends ConsumerStatefulWidget {
  final String? initialTheme;
  final String? initialReference;
  final ValueChanged<GeneratedOutlineResult>? onApplyGeneratedOutline;

  const AiAssistantSheet({
    super.key,
    this.initialTheme,
    this.initialReference,
    this.onApplyGeneratedOutline,
  });

  @override
  ConsumerState<AiAssistantSheet> createState() => _AiAssistantSheetState();
}

class _AiAssistantSheetState extends ConsumerState<AiAssistantSheet> {
  late final TextEditingController _themeCtrl;
  late final TextEditingController _refCtrl;
  String _selectedSermonType = 'Expositivo';

  late final TextEditingController _illustrationContextCtrl;
  late final TextEditingController _exegesisPassageCtrl;

  @override
  void initState() {
    super.initState();
    _themeCtrl = TextEditingController(text: widget.initialTheme ?? 'Salvos pelo Mérito de Cristo');
    _refCtrl = TextEditingController(text: widget.initialReference ?? 'Efésios 2:1-10');
    _illustrationContextCtrl = TextEditingController(text: widget.initialTheme ?? 'Confiança em meio à crise');
    _exegesisPassageCtrl = TextEditingController(text: widget.initialReference ?? 'Filipenses 4:6-7');
  }

  @override
  void dispose() {
    _themeCtrl.dispose();
    _refCtrl.dispose();
    _illustrationContextCtrl.dispose();
    _exegesisPassageCtrl.dispose();
    super.dispose();
  }

  void _applyPreset(String theme, String reference, String type) {
    setState(() {
      _themeCtrl.text = theme;
      _refCtrl.text = reference;
      _selectedSermonType = type;
    });
  }

  void _saveSermonToLibrary(GeneratedOutlineResult outline) async {
    final sermon = outline.toSermon();
    await ref.read(sermonRepositoryProvider).saveSermon(sermon);
    await ref.read(sermonListProvider.notifier).loadSermons();

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sermão "${sermon.title}" salvo com sucesso em Meus Sermões!'),
          backgroundColor: AppColors.statusReady,
          action: SnackBarAction(
            label: 'Editar',
            textColor: Colors.white,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SermonEditorScreen(initialSermon: sermon),
                ),
              );
            },
          ),
        ),
      );
    }
  }

  void _openInEditor(GeneratedOutlineResult outline) {
    final sermon = outline.toSermon();
    Navigator.pop(context);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SermonEditorScreen(initialSermon: sermon),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final aiState = ref.watch(aiAssistantProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            // Handle do Sheet
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),

            // Header com Ícone e Título
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7C3AED), Color(0xFF6366F1)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Assistente de Homilética IA',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Esboços Ricos com 5 Tópicos, Pontes Bíblicas e Exegese',
                            style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Tabs com Indicador Elegante
            const TabBar(
              labelColor: Color(0xFF7C3AED),
              indicatorColor: Color(0xFF7C3AED),
              indicatorWeight: 3,
              tabs: [
                Tab(icon: Icon(Icons.auto_awesome, size: 18), text: 'Gerador Esboço'),
                Tab(icon: Icon(Icons.lightbulb_outline, size: 18), text: 'Ilustrações'),
                Tab(icon: Icon(Icons.translate, size: 18), text: 'Grego & Hebraico'),
              ],
            ),

            // Tab Views
            Expanded(
              child: aiState.isLoading
                  ? _buildLoadingState(isDark)
                  : TabBarView(
                      children: [
                        _buildOutlineGeneratorTab(aiState, isDark),
                        _buildIllustrationsTab(aiState, isDark),
                        _buildLexicalExegesisTab(aiState, isDark),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ESTADO DE CARREGAMENTO INTELIGENTE
  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const CircularProgressIndicator(
                color: Color(0xFF7C3AED),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Construindo Esboço Homilético Profundo...',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Analisando texto bíblico • Cruzando pontes teológicas • Estruturando 5 divisões com exegese e aplicação',
              style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // TAB 1: GERADOR DE ESBOÇO
  Widget _buildOutlineGeneratorTab(AiAssistantState aiState, bool isDark) {
    final outline = aiState.generatedOutline;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            children: [
              // Sugestões Rápidas de Presets
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text('Sugestões:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                  ActionChip(
                    visualDensity: VisualDensity.compact,
                    label: const Text('Efésios 2 (Graça Soberana)', style: TextStyle(fontSize: 11)),
                    onPressed: () => _applyPreset('Salvos pelo Mérito de Cristo', 'Efésios 2:1-10', 'Expositivo'),
                  ),
                  ActionChip(
                    visualDensity: VisualDensity.compact,
                    label: const Text('Romanos 8 (Amor Inabalável)', style: TextStyle(fontSize: 11)),
                    onPressed: () => _applyPreset('Mais que Vencedores em Cristo', 'Romanos 8:31-39', 'Expositivo'),
                  ),
                  ActionChip(
                    visualDensity: VisualDensity.compact,
                    label: const Text('Salmos 23 (O Bom Pastor)', style: TextStyle(fontSize: 11)),
                    onPressed: () => _applyPreset('O Senhor é o Meu Pastor', 'Salmos 23:1-6', 'Expositivo'),
                  ),
                  ActionChip(
                    visualDensity: VisualDensity.compact,
                    label: const Text('Marcos 4 (Tempestade)', style: TextStyle(fontSize: 11)),
                    onPressed: () => _applyPreset('Paz em Meio à Tempestade', 'Marcos 4:35-41', 'Textual'),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Formulário de Entrada
              TextField(
                controller: _themeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tema ou Ideia Central da Mensagem',
                  hintText: 'Ex: A Graça que Transforma',
                  prefixIcon: Icon(Icons.topic_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _refCtrl,
                decoration: const InputDecoration(
                  labelText: 'Texto Bíblico Principal',
                  hintText: 'Ex: Efésios 2:1-10',
                  prefixIcon: Icon(Icons.bookmark_border),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedSermonType,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Sermão Homilético',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: AppConstants.sermonTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedSermonType = val);
                },
              ),
              const SizedBox(height: 16),

              // Botão Gerar
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    ref.read(aiAssistantProvider.notifier).generateOutline(
                          theme: _themeCtrl.text,
                          biblicalReference: _refCtrl.text,
                          sermonType: _selectedSermonType,
                        );
                  },
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7C3AED).withValues(alpha: 0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                          SizedBox(width: 10),
                          Text(
                            'Gerar Esboço Estruturado com IA (5 Tópicos)',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Resultado Gerado Completo
              if (outline != null) ...[
                // Banner Resumo com 3D Depth
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                          : [const Color(0xFFF5F3FF), Colors.white],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF7C3AED).withValues(alpha: 0.3), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7C3AED).withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF7C3AED).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '✨ Esboço Estruturado Completo (5 Pontos)',
                              style: TextStyle(color: Color(0xFF7C3AED), fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.accentGold.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              outline.sermonType,
                              style: const TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.w600, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        outline.title,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20, letterSpacing: -0.4),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.menu_book, size: 16, color: AppColors.primaryElectricBlue),
                          const SizedBox(width: 6),
                          Text(
                            outline.biblicalReference,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryElectricBlue, fontSize: 13),
                          ),
                        ],
                      ),

                      // Contexto Histórico
                      if (outline.historicalContext.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.history_edu, size: 18, color: Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  outline.historicalContext,
                                  style: TextStyle(fontSize: 12, height: 1.4, color: isDark ? Colors.grey[300] : Colors.grey[700]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Pontes Bíblicas (Cross-References)
                      if (outline.crossReferences.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Text(
                          '🔗 Passagens Bíblicas de Ponte (AT e NT):',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.accentGold),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: outline.crossReferences.map((refStr) {
                            return Chip(
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                              label: Text(refStr, style: const TextStyle(fontSize: 10.5)),
                              backgroundColor: AppColors.accentGold.withValues(alpha: 0.12),
                              side: BorderSide.none,
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Introdução
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.format_quote, size: 18, color: AppColors.primaryElectricBlue),
                          SizedBox(width: 6),
                          Text('Introdução Homilética:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(outline.introduction, style: const TextStyle(fontSize: 13, height: 1.5)),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                const Text(
                  'DIVISÕES HOMILÉTICAS ESTRUTURADAS (5 PONTOS):',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: Colors.grey),
                ),
                const SizedBox(height: 10),

                // Os 5 Pontos Homiléticos
                ...outline.blocks.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final b = entry.value;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título do Ponto
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF7C3AED).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${idx + 1}',
                                style: const TextStyle(color: Color(0xFF7C3AED), fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    b.title,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    b.biblicalReference,
                                    style: const TextStyle(fontSize: 11.5, color: AppColors.primaryElectricBlue, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Exegese
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.black.withValues(alpha: 0.2) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.menu_book, size: 14, color: AppColors.primaryBlue),
                                  SizedBox(width: 6),
                                  Text('Exegese & Hermenêutica:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryBlue)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(b.explanation, style: const TextStyle(fontSize: 12.5, height: 1.45)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Ilustração
                        if (b.illustration.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B5CF6).withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.2)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.lightbulb_outline, size: 14, color: Color(0xFF8B5CF6)),
                                    SizedBox(width: 6),
                                    Text('Ilustração Prática:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF8B5CF6))),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(b.illustration, style: const TextStyle(fontSize: 12.5, height: 1.45, fontStyle: FontStyle.italic)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],

                        // Aplicação
                        if (b.application.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.accentGold.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.25)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.gps_fixed, size: 14, color: AppColors.accentGold),
                                    SizedBox(width: 6),
                                    Text('Aplicação Pastoral:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.accentGold)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(b.application, style: const TextStyle(fontSize: 12.5, height: 1.45)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                }),

                // Conclusão e Apelo
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Conclusão:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.teal)),
                      const SizedBox(height: 4),
                      Text(outline.conclusion, style: const TextStyle(fontSize: 12.5, height: 1.45)),
                      const SizedBox(height: 12),
                      const Text('Apelo & Oração:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.purple)),
                      const SizedBox(height: 4),
                      Text(outline.appeal, style: const TextStyle(fontSize: 12.5, height: 1.45)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        // STICKY BOTTOM ACTION BAR (Ações Cruciais: Salvar, Editar, WhatsApp, Cancelar)
        if (outline != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  width: 1.2,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Wrap(
              spacing: 10,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Cancelar / Limpar
                OutlinedButton.icon(
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('Cancelar / Limpar'),
                  onPressed: () {
                    ref.read(aiAssistantProvider.notifier).clearOutline();
                  },
                ),

                // Compartilhar WhatsApp
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF25D366),
                    side: const BorderSide(color: Color(0xFF25D366)),
                  ),
                  icon: const Icon(Icons.chat_bubble, size: 16),
                  label: const Text('WhatsApp'),
                  onPressed: () {
                    final sermon = outline.toSermon();
                    SermonShareService.shareViaWhatsApp(context, sermon);
                  },
                ),

                // Se aberto de dentro de um editor ativo
                if (widget.onApplyGeneratedOutline != null)
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.statusReady,
                    ),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Inserir no Sermão Aberto'),
                    onPressed: () {
                      widget.onApplyGeneratedOutline!(outline);
                      Navigator.pop(context);
                    },
                  ),

                // Editar no Editor Completo
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryElectricBlue,
                    side: const BorderSide(color: AppColors.primaryElectricBlue),
                  ),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Editar no Editor'),
                  onPressed: () => _openInEditor(outline),
                ),

                // Salvar em Meus Sermões
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  icon: const Icon(Icons.save, size: 16),
                  label: const Text('Salvar em Meus Sermões', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () => _saveSermonToLibrary(outline),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // TAB 2: ILUSTRAÇÕES PRÁTICAS
  Widget _buildIllustrationsTab(AiAssistantState aiState, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        TextField(
          controller: _illustrationContextCtrl,
          decoration: const InputDecoration(
            labelText: 'Contexto ou Ponto do Sermão',
            hintText: 'Ex: A fidelidade de Deus em meio ao desemprego',
            prefixIcon: Icon(Icons.lightbulb_outline),
          ),
        ),
        const SizedBox(height: 14),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF7C3AED),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          icon: const Icon(Icons.search),
          label: const Text('Sugerir 3 Ilustrações Práticas'),
          onPressed: () {
            ref.read(aiAssistantProvider.notifier).requestIllustrations(
                  theme: _themeCtrl.text,
                  pointContext: _illustrationContextCtrl.text,
                );
          },
        ),
        const SizedBox(height: 20),
        if (aiState.suggestedIllustrations.isNotEmpty) ...[
          ...aiState.suggestedIllustrations.asMap().entries.map((entry) {
            final idx = entry.key;
            final text = entry.value;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_stories, size: 18, color: Color(0xFF7C3AED)),
                        const SizedBox(width: 8),
                        Text(
                          'Ilustração ${idx + 1}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(text, style: const TextStyle(fontSize: 13, height: 1.45)),
                  ],
                ),
              ),
            );
          }),
        ],
      ],
    );
  }

  // TAB 3: EXEGESE LÉXICA GREGO & HEBRAICO
  Widget _buildLexicalExegesisTab(AiAssistantState aiState, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        TextField(
          controller: _exegesisPassageCtrl,
          decoration: const InputDecoration(
            labelText: 'Passagem Bíblica para Análise Original',
            hintText: 'Ex: Filipenses 4:6-7 ou Efésios 2:8',
            prefixIcon: Icon(Icons.translate),
          ),
        ),
        const SizedBox(height: 14),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF7C3AED),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          icon: const Icon(Icons.menu_book),
          label: const Text('Consultar Léxico Grego / Hebraico'),
          onPressed: () {
            ref.read(aiAssistantProvider.notifier).lookupLexicalInsights(
                  _exegesisPassageCtrl.text,
                );
          },
        ),
        const SizedBox(height: 20),
        if (aiState.lexicalInsights.isNotEmpty) ...[
          ...aiState.lexicalInsights.map((insight) {
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        insight.word,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF7C3AED)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          insight.strongNumber,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${insight.transliteration} • ${insight.language}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Significado: ${insight.meaning}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    insight.theologicalInsight,
                    style: TextStyle(fontSize: 12.5, height: 1.4, color: isDark ? Colors.grey[300] : Colors.grey[700]),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }
}
