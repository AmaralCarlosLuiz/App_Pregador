import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/ai_homiletics_service.dart';
import '../../providers/ai_assistant_provider.dart';

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
    _themeCtrl = TextEditingController(text: widget.initialTheme ?? 'Vencendo a Tempestade');
    _refCtrl = TextEditingController(text: widget.initialReference ?? 'Marcos 4:35-41');
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

  @override
  Widget build(BuildContext context) {
    final aiState = ref.watch(aiAssistantProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            // Handle do Sheet
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
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
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.psychology_alt, color: Color(0xFF8B5CF6), size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Assistente de Homilética IA',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Esboços, Ilustrações e Exegese Bíblica',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
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

            // Tabs
            const TabBar(
              labelColor: Color(0xFF8B5CF6),
              indicatorColor: Color(0xFF8B5CF6),
              tabs: [
                Tab(icon: Icon(Icons.auto_awesome, size: 18), text: 'Gerador Esboço'),
                Tab(icon: Icon(Icons.lightbulb_outline, size: 18), text: 'Ilustrações'),
                Tab(icon: Icon(Icons.translate, size: 18), text: 'Grego & Hebraico'),
              ],
            ),

            // Tab Views
            Expanded(
              child: aiState.isLoading
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Color(0xFF8B5CF6)),
                          SizedBox(height: 16),
                          Text(
                            'Consultando fontes teológicas e gerando homilética...',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : TabBarView(
                      children: [
                        _buildOutlineGeneratorTab(aiState),
                        _buildIllustrationsTab(aiState),
                        _buildLexicalExegesisTab(aiState),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // TAB 1: GERADOR DE ESBOÇO
  Widget _buildOutlineGeneratorTab(AiAssistantState aiState) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        TextField(
          controller: _themeCtrl,
          decoration: const InputDecoration(
            labelText: 'Tema ou Ideia Central da Mensagem',
            prefixIcon: Icon(Icons.topic_outlined),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _refCtrl,
          decoration: const InputDecoration(
            labelText: 'Texto Bíblico Principal',
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
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF8B5CF6),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          icon: const Icon(Icons.auto_awesome),
          label: const Text('Gerar Esboço Estruturado com IA'),
          onPressed: () {
            ref.read(aiAssistantProvider.notifier).generateOutline(
                  theme: _themeCtrl.text,
                  biblicalReference: _refCtrl.text,
                  sermonType: _selectedSermonType,
                );
          },
        ),

        const SizedBox(height: 24),

        // Resultado Gerado
        if (aiState.generatedOutline != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Esboço Homilético Gerado:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    if (widget.onApplyGeneratedOutline != null)
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.statusReady,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        ),
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Inserir no Sermão'),
                        onPressed: () {
                          widget.onApplyGeneratedOutline!(aiState.generatedOutline!);
                          Navigator.pop(context);
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  aiState.generatedOutline!.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'Texto: ${aiState.generatedOutline!.biblicalReference} • ${aiState.generatedOutline!.sermonType}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 12),
                const Text('📖 Introdução:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(aiState.generatedOutline!.introduction, style: const TextStyle(fontSize: 13, height: 1.4)),
                const SizedBox(height: 12),
                ...aiState.generatedOutline!.blocks.map((b) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(b.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryBlue)),
                        Text('Explicação: ${b.explanation}', style: const TextStyle(fontSize: 12)),
                        Text('Ilustração: ${b.illustration}', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // TAB 2: ILUSTRAÇÕES PRÁTICAS
  Widget _buildIllustrationsTab(AiAssistantState aiState) {
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
            backgroundColor: const Color(0xFF8B5CF6),
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
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ilustração ${entry.key + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.homileticIllustration,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(entry.value, style: const TextStyle(fontSize: 13, height: 1.5)),
                  ],
                ),
              ),
            );
          }),
        ],
      ],
    );
  }

  // TAB 3: EXEGESE GREGO & HEBRAICO
  Widget _buildLexicalExegesisTab(AiAssistantState aiState) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        TextField(
          controller: _exegesisPassageCtrl,
          decoration: const InputDecoration(
            labelText: 'Passagem Bíblica ou Termo Teológico',
            hintText: 'Ex: Filipenses 4:6 ou Romanos 8:37',
            prefixIcon: Icon(Icons.translate),
          ),
        ),
        const SizedBox(height: 14),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF8B5CF6),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          icon: const Icon(Icons.menu_book),
          label: const Text('Pesquisar Raízes em Grego / Hebraico'),
          onPressed: () {
            ref.read(aiAssistantProvider.notifier).lookupLexicalInsights(
                  _exegesisPassageCtrl.text,
                );
          },
        ),
        const SizedBox(height: 20),
        if (aiState.lexicalInsights.isNotEmpty) ...[
          ...aiState.lexicalInsights.map((insight) {
            return Card(
              margin: const EdgeInsets.only(bottom: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          insight.word,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.accentGold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Strong ${insight.strongNumber}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.goldDark),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Transliteração: ${insight.transliteration} • ${insight.language}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Significado Original: ${insight.meaning}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      insight.theologicalInsight,
                      style: const TextStyle(fontSize: 13, height: 1.4),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ],
    );
  }
}
