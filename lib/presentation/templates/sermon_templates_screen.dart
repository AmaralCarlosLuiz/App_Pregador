import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../models/sermon_block.dart';
import '../../models/sermon_model.dart';
import '../../models/sermon_template_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/templates_provider.dart';
import '../editor/sermon_editor_screen.dart';

class SermonTemplatesScreen extends ConsumerStatefulWidget {
  const SermonTemplatesScreen({super.key});

  @override
  ConsumerState<SermonTemplatesScreen> createState() => _SermonTemplatesScreenState();
}

class _SermonTemplatesScreenState extends ConsumerState<SermonTemplatesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedType = 'Todos';
  String? _selectedTag;
  final Set<String> _expandedTemplateIds = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final templatesAsync = ref.watch(templatesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Acervo de Modelos Homiléticos',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Biblioteca de inspiração e esboços prontos para clonar e personalizar',
              style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      body: templatesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Erro ao carregar modelos: $err',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (allTemplates) {
          // Filtragem dinâmica
          final query = _searchController.text.toLowerCase().trim();
          final filteredTemplates = allTemplates.where((t) {
            // Filtro por tipo
            if (_selectedType != 'Todos' &&
                t.sermonType.toLowerCase() != _selectedType.toLowerCase()) {
              return false;
            }
            // Filtro por tag
            if (_selectedTag != null &&
                !t.tags.any((tag) => tag.toLowerCase() == _selectedTag!.toLowerCase())) {
              return false;
            }
            // Busca por texto
            if (query.isNotEmpty) {
              final inTitle = t.title.toLowerCase().contains(query);
              final inTheme = t.theme.toLowerCase().contains(query);
              final inVerse = t.keyVerse.toLowerCase().contains(query);
              final inTags = t.tags.any((tag) => tag.toLowerCase().contains(query));
              if (!inTitle && !inTheme && !inVerse && !inTags) {
                return false;
              }
            }
            return true;
          }).toList();

          // Contagens por tipo
          final countExpositivo = allTemplates.where((t) => t.sermonType == 'Expositivo').length;
          final countTematico = allTemplates.where((t) => t.sermonType == 'Temático').length;
          final countTextual = allTemplates.where((t) => t.sermonType == 'Textual').length;

          // Extração das principais tags únicas
          final allTags = <String>{};
          for (final t in allTemplates) {
            allTags.addAll(t.tags);
          }
          final topTags = allTags.take(12).toList();

          return Column(
            children: [
              // Barra de Busca e Filtros Superiores
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Campo de Busca
                    TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Buscar por título, tema, versículo ou tema...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark ? AppColors.borderDark : AppColors.borderLight,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark ? AppColors.borderDark : AppColors.borderLight,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Filtros por Tipologia Homilética em Wrap Responsivo
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _buildTypeFilterChip('Todos', 'Todos (${allTemplates.length})', isDark),
                        _buildTypeFilterChip('Expositivo', 'Expositivo ($countExpositivo)', isDark),
                        _buildTypeFilterChip('Temático', 'Temático ($countTematico)', isDark),
                        _buildTypeFilterChip('Textual', 'Textual ($countTextual)', isDark),
                      ],
                    ),

                    if (topTags.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      // Tags Rápidas em Wrap (nunca cortam botões na borda)
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (_selectedTag != null)
                            ActionChip(
                              avatar: const Icon(Icons.close, size: 14),
                              label: Text('Limpar: $_selectedTag', style: const TextStyle(fontSize: 11)),
                              onPressed: () => setState(() => _selectedTag = null),
                              visualDensity: VisualDensity.compact,
                            ),
                          ...topTags.map((tag) {
                            final isSelected = _selectedTag == tag;
                            return ChoiceChip(
                              label: Text(tag, style: const TextStyle(fontSize: 11)),
                              selected: isSelected,
                              onSelected: (val) {
                                setState(() {
                                  _selectedTag = val ? tag : null;
                                });
                              },
                              visualDensity: VisualDensity.compact,
                            );
                          }),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Lista de Modelos Filtrados
              Expanded(
                child: filteredTemplates.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            Text(
                              'Nenhum modelo encontrado para este filtro.',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _selectedType = 'Todos';
                                  _selectedTag = null;
                                });
                              },
                              child: const Text('Limpar filtros'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredTemplates.length,
                        itemBuilder: (context, index) {
                          final tpl = filteredTemplates[index];
                          final isExpanded = _expandedTemplateIds.contains(tpl.id);
                          return _buildTemplateCard(context, tpl, isDark, isExpanded);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTypeFilterChip(String type, String label, bool isDark) {
    final isSelected = _selectedType == type;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.primaryBlue.withValues(alpha: 0.2),
      onSelected: (_) {
        setState(() {
          _selectedType = type;
        });
      },
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildTemplateCard(
    BuildContext context,
    SermonTemplate template,
    bool isDark,
    bool isExpanded,
  ) {
    final rawBlocks = (template.content['blocks'] as List<dynamic>?) ?? [];
    final introduction = template.content['introduction'] as String? ?? '';
    final conclusion = template.content['conclusion'] as String? ?? '';
    final appeal = template.content['appeal'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131B2E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: AppColors.cardShadow3D(isDark: isDark),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho: Título e Tipo
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    template.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getTypeColor(template.sermonType).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    template.sermonType,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getTypeColor(template.sermonType),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Tema
            Text(
              'Tema: ${template.theme}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 6),

            // Versículo Chave
            Row(
              children: [
                const Icon(Icons.bookmark_border, size: 16, color: AppColors.accentGold),
                const SizedBox(width: 6),
                Text(
                  template.keyVerse,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentGold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Tags
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: template.tags.map((tag) {
                return Chip(
                  label: Text(tag, style: const TextStyle(fontSize: 11)),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                );
              }).toList(),
            ),

            // Área Expandida: Pré-visualização da Estrutura Homilética
            if (isExpanded) ...[
              const SizedBox(height: 14),
              const Divider(),
              const SizedBox(height: 8),

              if (introduction.isNotEmpty) ...[
                const Text(
                  'Exórdio / Introdução:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                ),
                const SizedBox(height: 4),
                Text(
                  introduction,
                  style: TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: isDark ? Colors.grey[300] : Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              const Text(
                'Divisões Principais (Corpo do Sermão):',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
              ),
              const SizedBox(height: 6),

              ...rawBlocks.map((b) {
                final blockMap = b as Map<String, dynamic>;
                final blockTitle = blockMap['title'] as String? ?? '';
                final blockRef = blockMap['biblicalReference'] as String? ?? '';
                final blockExp = blockMap['explanation'] as String? ?? '';
                final blockIll = blockMap['illustration'] as String? ?? '';
                final blockApp = blockMap['application'] as String? ?? '';

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              blockTitle,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (blockRef.isNotEmpty)
                            Text(
                              blockRef,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.accentGold,
                              ),
                            ),
                        ],
                      ),
                      if (blockExp.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text('• Exegese: $blockExp', style: const TextStyle(fontSize: 12)),
                      ],
                      if (blockIll.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text('• Ilustração: $blockIll', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ],
                      if (blockApp.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text('• Aplicação: $blockApp', style: const TextStyle(fontSize: 12, color: AppColors.homileticPoint)),
                      ],
                    ],
                  ),
                );
              }),

              if (conclusion.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text(
                  'Conclusão & Apelo:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                ),
                const SizedBox(height: 4),
                Text('• Síntese: $conclusion', style: const TextStyle(fontSize: 12)),
                if (appeal.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text('• Apelo Pastoral: $appeal', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ],
            ],

            const SizedBox(height: 14),

            // Rodapé do Card: Botões de Ação
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      if (isExpanded) {
                        _expandedTemplateIds.remove(template.id);
                      } else {
                        _expandedTemplateIds.add(template.id);
                      }
                    });
                  },
                  icon: Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 18,
                  ),
                  label: Text(
                    isExpanded ? 'Recolher' : 'Ver Estrutura (${rawBlocks.length} pontos)',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Usar este Modelo'),
                  onPressed: () => _useTemplate(context, template),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'expositivo':
        return AppColors.primaryBlue;
      case 'temático':
        return AppColors.homileticPoint;
      case 'textual':
        return const Color(0xFFD97706); // Âmbar
      default:
        return AppColors.primaryBlue;
    }
  }

  void _useTemplate(BuildContext context, SermonTemplate template) {
    final rawBlocks = (template.content['blocks'] as List<dynamic>?) ?? [];
    final blocks = rawBlocks
        .map((b) => HomileticBlock.fromJson(b as Map<String, dynamic>))
        .toList();

    final userId = ref.read(authProvider).userProfile?.id ?? 'admin-master-01';
    final newSermon = Sermon(
      id: UniqueKeyString.generate(),
      userId: userId,
      title: template.title,
      biblicalReference: template.keyVerse,
      sermonType: template.sermonType,
      category: template.tags.isNotEmpty ? template.tags.first : 'Geral',
      introduction: template.content['introduction'] as String? ?? '',
      blocks: blocks,
      conclusion: template.content['conclusion'] as String? ?? '',
      appeal: template.content['appeal'] as String? ?? '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Modelo "${template.title}" clonado para edição!'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SermonEditorScreen(initialSermon: newSermon),
      ),
    );
  }
}
