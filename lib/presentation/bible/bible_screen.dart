import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../models/bible_model.dart';
import '../../providers/bible_provider.dart';
import '../../providers/bible_tts_provider.dart';
import 'widgets/bible_quick_selector_sheet.dart';
import 'widgets/bible_verse_actions_dialog.dart';

class BibleScreen extends ConsumerStatefulWidget {
  final Function(BibleVerse verse)? onVerseSelectedForSermon;

  const BibleScreen({
    super.key,
    this.onVerseSelectedForSermon,
  });

  @override
  ConsumerState<BibleScreen> createState() => _BibleScreenState();
}

class _BibleScreenState extends ConsumerState<BibleScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSearchVisible = false;
  bool _isVoiceBarExpanded = true;

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _openQuickSelector(BibleState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BibleQuickSelectorSheet(
        currentBookId: state.selectedBookId,
        currentChapter: state.selectedChapter,
        onSelected: (bookId, chapter) {
          ref.read(bibleTtsProvider.notifier).stop();
          ref.read(bibleTtsProvider.notifier).clearSelection();
          ref.read(bibleStateProvider.notifier).selectBook(bookId);
          ref.read(bibleStateProvider.notifier).selectChapter(chapter);
          _scrollToTop();
        },
      ),
    );
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bibleStateProvider);
    final ttsState = ref.watch(bibleTtsProvider);
    final versesAsync = ref.watch(currentChapterVersesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentVerses = versesAsync.valueOrNull ?? const <BibleVerse>[];

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _openQuickSelector(state),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.menu_book, size: 20, color: AppColors.accentGold),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    state.currentReference,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.arrow_drop_down, size: 20),
              ],
            ),
          ),
        ),
        actions: [
          // Botão Selecionar Trecho p/ Leitura em Voz
          IconButton(
            tooltip: ttsState.isSelectionMode
                ? 'Sair da Seleção de Trecho'
                : 'Selecionar Trecho para Leitura em Voz',
            icon: Icon(
              ttsState.isSelectionMode ? Icons.checklist_rtl : Icons.fact_check_outlined,
              color: ttsState.isSelectionMode ? AppColors.accentGold : null,
            ),
            onPressed: () {
              ref.read(bibleTtsProvider.notifier).toggleSelectionMode();
            },
          ),

          // Botão Ouvir / Painel de Voz (RJ)
          IconButton(
            tooltip: ttsState.isPlaying
                ? 'Parar Leitura em Voz'
                : 'Ouvir em Voz Humana (Brasil • RJ)',
            icon: Icon(
              ttsState.isPlaying ? Icons.stop_circle_outlined : Icons.record_voice_over,
              color: ttsState.isPlaying
                  ? Colors.redAccent
                  : (_isVoiceBarExpanded ? AppColors.accentGold : null),
            ),
            onPressed: () {
              if (ttsState.isPlaying) {
                ref.read(bibleTtsProvider.notifier).stop();
              } else {
                setState(() => _isVoiceBarExpanded = true);
                if (currentVerses.isNotEmpty) {
                  ref
                      .read(bibleTtsProvider.notifier)
                      .speakSelectedOrChapter(currentVerses);
                }
              }
            },
          ),

          // Seletor de Tradução (ARC, NVI, ACF, etc.)
          PopupMenuButton<String>(
            tooltip: 'Alternar Versão da Bíblia',
            initialValue: state.selectedVersion,
            onSelected: (version) {
              ref.read(bibleStateProvider.notifier).setVersion(version);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'ARC',
                child: Text('ARC (Almeida Revista e Corrigida)'),
              ),
              PopupMenuItem(
                value: 'ARA',
                child: Text('ARA (Almeida Revista e Atualizada)'),
              ),
              PopupMenuItem(
                value: 'NAA',
                child: Text('NAA (Nova Almeida Atualizada)'),
              ),
              PopupMenuItem(
                value: 'NVI',
                child: Text('NVI (Nova Versão Internacional)'),
              ),
              PopupMenuItem(
                value: 'ACF',
                child: Text('ACF (Almeida Corrigida Fiel)'),
              ),
              PopupMenuItem(
                value: 'BKJ',
                child: Text('BKJ 1611 (King James Fiel 1611)'),
              ),
            ],
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                state.selectedVersion,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ),

          // Comparar Versões da Bíblia (até 3 versões simultâneas)
          IconButton(
            tooltip: state.isComparing ? 'Sair do Modo Comparação' : 'Comparar até 3 Versões',
            icon: Icon(
              Icons.compare_arrows,
              color: state.isComparing ? AppColors.accentGold : null,
            ),
            onPressed: () {
              ref.read(bibleStateProvider.notifier).toggleComparisonMode();
            },
          ),

          // Alternar Barra de Busca
          IconButton(
            icon: Icon(_isSearchVisible ? Icons.search_off : Icons.search),
            tooltip: 'Buscar na Bíblia',
            onPressed: () {
              setState(() {
                _isSearchVisible = !_isSearchVisible;
                if (!_isSearchVisible) {
                  _searchController.clear();
                  ref.read(bibleStateProvider.notifier).clearSearch();
                }
              });
            },
          ),

          // Menu de Tipografia (Tamanho da Fonte)
          PopupMenuButton<double>(
            tooltip: 'Ajustar Tamanho da Fonte',
            icon: const Icon(Icons.format_size),
            onSelected: (size) {
              ref.read(bibleStateProvider.notifier).setFontSize(size);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 15.0, child: Text('Texto Pequeno (15px)')),
              PopupMenuItem(value: 18.0, child: Text('Texto Padrão (18px)')),
              PopupMenuItem(value: 22.0, child: Text('Texto Grande (22px)')),
              PopupMenuItem(value: 26.0, child: Text('Modo Púlpito (26px)')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de Leitura em Voz Humana (Masculina / Feminina • Brasil - RJ)
          if (_isVoiceBarExpanded || ttsState.isPlaying || ttsState.isSelectionMode)
            _buildVoiceStudioBar(ttsState, currentVerses, isDark),

          // Barra de Seleção de Versões Comparativas
          if (state.isComparing)
            _buildComparisonSelectorBar(state, isDark),

          // Barra de Pesquisa Condicional
          if (_isSearchVisible)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                onSubmitted: (query) {
                  ref.read(bibleStateProvider.notifier).search(query);
                },
                decoration: InputDecoration(
                  hintText: 'Digite palavra ou frase (ex: "todas as coisas")...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(bibleStateProvider.notifier).clearSearch();
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
                ),
              ),
            ),

          // Banner de Resultados de Busca
          if (state.searchQuery.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.accentGold.withValues(alpha: 0.15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Resultados para "${state.searchQuery}": ${state.searchResults.length} encontrados',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _searchController.clear();
                      ref.read(bibleStateProvider.notifier).clearSearch();
                    },
                    child: const Text('Voltar à Leitura', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),

          // Corpo Principal
          Expanded(
            child: state.searchQuery.isNotEmpty
                ? _buildSearchResults(state, isDark)
                : state.isComparing
                    ? ref.watch(currentChapterComparisonVersesProvider).when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (err, stack) => Center(
                          child: Text('Erro ao comparar versões: $err'),
                        ),
                        data: (comparisons) {
                          if (comparisons.isEmpty) {
                            return const Center(child: Text('Nenhum texto disponível.'));
                          }
                          return _buildComparisonVerseView(comparisons, state, isDark);
                        },
                      )
                    : versesAsync.when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (err, stack) => Center(
                          child: Text('Erro ao carregar versículos: $err'),
                        ),
                        data: (verses) {
                          if (verses.isEmpty) {
                            return const Center(child: Text('Nenhum texto disponível.'));
                          }
                          return _buildVersesList(verses, state, ttsState, isDark);
                        },
                      ),
          ),

          // Barra Inferior de Navegação entre Capítulos
          if (state.searchQuery.isEmpty)
            _buildBottomChapterBar(state, isDark),
        ],
      ),
    );
  }

  /// Painel de Controle de Leitura em Voz Humana (Masculina e Feminina • Brasil / RJ)
  Widget _buildVoiceStudioBar(
    BibleTtsState ttsState,
    List<BibleVerse> currentVerses,
    bool isDark,
  ) {
    final selectedCount = ttsState.selectedVerseNumbers.length;
    final currentSpoken = ttsState.currentVerse;
    final isMale = ttsState.gender == BibleVoiceGender.male;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111C30) : const Color(0xFFF0F7FF),
        border: Border(
          bottom: BorderSide(
            color: ttsState.isPlaying
                ? AppColors.accentGold.withValues(alpha: 0.5)
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.spaceBetween,
            children: [
              // Identificação & Seletor de Timbre (Masculino / Feminino - RJ)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: (ttsState.isPlaying ? AppColors.accentGold : AppColors.primaryBlue)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      ttsState.isPlaying ? Icons.graphic_eq : Icons.record_voice_over,
                      size: 16,
                      color: ttsState.isPlaying ? AppColors.accentGold : AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Voz Humana (RJ):',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(width: 8),

                  // Chip Voz Masculina (RJ)
                  ChoiceChip(
                    visualDensity: VisualDensity.compact,
                    label: const Text('Masculina (RJ)', style: TextStyle(fontSize: 11.5)),
                    avatar: Icon(
                      Icons.mic,
                      size: 14,
                      color: isMale ? Colors.white : AppColors.primaryBlue,
                    ),
                    selected: isMale,
                    selectedColor: AppColors.primaryBlue,
                    labelStyle: TextStyle(
                      color: isMale ? Colors.white : null,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (_) {
                      ref.read(bibleTtsProvider.notifier).setGender(BibleVoiceGender.male);
                    },
                  ),
                  const SizedBox(width: 6),

                  // Chip Voz Feminina (RJ)
                  ChoiceChip(
                    visualDensity: VisualDensity.compact,
                    label: const Text('Feminina (RJ)', style: TextStyle(fontSize: 11.5)),
                    avatar: Icon(
                      Icons.spatial_audio_off,
                      size: 14,
                      color: !isMale ? Colors.white : const Color(0xFF7C3AED),
                    ),
                    selected: !isMale,
                    selectedColor: const Color(0xFF7C3AED),
                    labelStyle: TextStyle(
                      color: !isMale ? Colors.white : null,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (_) {
                      ref.read(bibleTtsProvider.notifier).setGender(BibleVoiceGender.female);
                    },
                  ),
                ],
              ),

              // Controles de Velocidade, Seleção de Trecho e Play/Pause/Stop
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Seletor de Cadência / Velocidade
                  PopupMenuButton<double>(
                    tooltip: 'Cadência da Voz',
                    onSelected: (rate) {
                      ref.read(bibleTtsProvider.notifier).setSpeechRate(rate);
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 0.86, child: Text('0.85x • Leitura Meditativa')),
                      PopupMenuItem(value: 0.96, child: Text('1.0x • Cadência Natural (RJ)')),
                      PopupMenuItem(value: 1.10, child: Text('1.15x • Leitura Dinâmica')),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? Colors.white24 : Colors.black12,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.speed, size: 14, color: AppColors.accentGold),
                          const SizedBox(width: 4),
                          Text(
                            ttsState.speechRate < 0.9
                                ? '0.85x'
                                : (ttsState.speechRate > 1.02 ? '1.15x' : '1.0x RJ'),
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Botão Selecionar Trecho
                  OutlinedButton.icon(
                    onPressed: () {
                      ref.read(bibleTtsProvider.notifier).toggleSelectionMode();
                    },
                    icon: Icon(
                      ttsState.isSelectionMode ? Icons.check_box : Icons.checklist_rtl,
                      size: 15,
                    ),
                    label: Text(
                      ttsState.isSelectionMode
                          ? (selectedCount > 0
                              ? 'Trecho ($selectedCount vers.)'
                              : 'Toque nos versículos')
                          : 'Selecionar Trecho',
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      foregroundColor:
                          ttsState.isSelectionMode ? AppColors.accentGold : AppColors.primaryBlue,
                      side: BorderSide(
                        color: ttsState.isSelectionMode
                            ? AppColors.accentGold
                            : AppColors.primaryBlue.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Controles de Reprodução Ativa ou Botão Iniciar Leitura
                  if (!ttsState.isPlaying)
                    ElevatedButton.icon(
                      onPressed: currentVerses.isEmpty
                          ? null
                          : () {
                              ref
                                  .read(bibleTtsProvider.notifier)
                                  .speakSelectedOrChapter(currentVerses);
                            },
                      icon: const Icon(Icons.play_arrow_rounded, size: 18),
                      label: Text(
                        selectedCount > 0
                            ? 'Ouvir Trecho ($selectedCount)'
                            : 'Ouvir Capítulo',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        backgroundColor: AppColors.accentGold,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    )
                  else ...[
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Versículo Anterior',
                      onPressed: ttsState.currentQueueIndex > 0
                          ? () => ref.read(bibleTtsProvider.notifier).previousVerse()
                          : null,
                      icon: const Icon(Icons.skip_previous_rounded, size: 20),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: ttsState.isPaused ? 'Continuar Leitura' : 'Pausar Leitura',
                      onPressed: () => ref.read(bibleTtsProvider.notifier).pauseOrResume(),
                      icon: Icon(
                        ttsState.isPaused
                            ? Icons.play_circle_fill_rounded
                            : Icons.pause_circle_filled_rounded,
                        size: 26,
                        color: AppColors.accentGold,
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Próximo Versículo',
                      onPressed: ttsState.currentQueueIndex + 1 < ttsState.queue.length
                          ? () => ref.read(bibleTtsProvider.notifier).nextVerse()
                          : null,
                      icon: const Icon(Icons.skip_next_rounded, size: 20),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Parar Leitura',
                      onPressed: () => ref.read(bibleTtsProvider.notifier).stop(),
                      icon: const Icon(Icons.stop_circle_rounded, size: 22, color: Colors.redAccent),
                    ),
                  ],
                ],
              ),
            ],
          ),

          // Status da leitura em andamento ou instrução de seleção de trecho
          if (ttsState.isPlaying && currentSpoken != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.volume_up_rounded, size: 14, color: AppColors.accentGold),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Lendo agora: ${currentSpoken.reference} • ${ttsState.voiceProfileLabel}'
                    '${ttsState.isPaused ? " (Pausado)" : ""}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accentGold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ] else if (ttsState.isSelectionMode) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    selectedCount == 0
                        ? 'Toque nos versículos abaixo para marcar o trecho que deseja ouvir.'
                        : '$selectedCount versículo(s) selecionado(s) para leitura em voz.',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      onPressed: () {
                        ref.read(bibleTtsProvider.notifier).selectVerseRange(currentVerses);
                      },
                      child: const Text('Marcar Todos', style: TextStyle(fontSize: 11)),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      onPressed: () {
                        ref.read(bibleTtsProvider.notifier).clearSelection();
                      },
                      child: const Text('Limpar', style: TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
              ],
            ),
          ],

          if (ttsState.errorMessage != null) ...[
            const SizedBox(height: 4),
            Text(
              ttsState.errorMessage!,
              style: const TextStyle(fontSize: 11, color: Colors.redAccent),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVersesList(
    List<BibleVerse> verses,
    BibleState state,
    BibleTtsState ttsState,
    bool isDark,
  ) {
    final activeSpokenVerse = ttsState.currentVerse;

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: verses.length,
      itemBuilder: (context, index) {
        final verse = verses[index];
        final isBookmarked = state.bookmarks.any(
          (b) =>
              b.bookId.toLowerCase() == verse.bookId.toLowerCase() &&
              b.chapter == verse.chapter &&
              b.verse == verse.verse,
        );
        final isSelectedForAudio = ttsState.selectedVerseNumbers.contains(verse.verse);
        final isCurrentlySpeaking = ttsState.isPlaying &&
            activeSpokenVerse != null &&
            activeSpokenVerse.bookId == verse.bookId &&
            activeSpokenVerse.chapter == verse.chapter &&
            activeSpokenVerse.verse == verse.verse;

        return InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            if (ttsState.isSelectionMode) {
              ref.read(bibleTtsProvider.notifier).toggleVerseSelection(verse.verse);
            } else {
              _showVerseActions(verse, isBookmarked, verses);
            }
          },
          onLongPress: () {
            ref.read(bibleTtsProvider.notifier).toggleVerseSelection(verse.verse);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isCurrentlySpeaking
                  ? AppColors.accentGold.withValues(alpha: 0.22)
                  : isSelectedForAudio
                      ? AppColors.primaryBlue.withValues(alpha: 0.14)
                      : isBookmarked
                          ? AppColors.accentGold.withValues(alpha: 0.12)
                          : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: isCurrentlySpeaking
                  ? Border.all(color: AppColors.accentGold, width: 1.5)
                  : isSelectedForAudio
                      ? Border.all(
                          color: AppColors.primaryBlue.withValues(alpha: 0.45),
                          width: 1,
                        )
                      : null,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Checkbox no Modo de Seleção de Trecho
                if (ttsState.isSelectionMode)
                  Padding(
                    padding: const EdgeInsets.only(right: 8, top: 2),
                    child: Icon(
                      isSelectedForAudio
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked,
                      size: 18,
                      color: isSelectedForAudio ? AppColors.primaryBlue : Colors.grey,
                    ),
                  ),

                // Número do Versículo em Destaque
                Container(
                  width: 32,
                  margin: const EdgeInsets.only(top: 2),
                  child: Text(
                    '${verse.verse}',
                    style: TextStyle(
                      fontSize: state.fontSize * 0.75,
                      fontWeight: FontWeight.bold,
                      color: isCurrentlySpeaking || isBookmarked
                          ? AppColors.accentGold
                          : AppColors.primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                // Texto do Versículo com Tipografia Ajustável
                Expanded(
                  child: Text(
                    verse.text,
                    style: TextStyle(
                      fontSize: state.fontSize,
                      height: 1.5,
                      fontWeight: isCurrentlySpeaking ? FontWeight.w600 : FontWeight.normal,
                      color: isDark ? Colors.grey[100] : Colors.grey[900],
                      letterSpacing: 0.1,
                    ),
                  ),
                ),

                if (isBookmarked)
                  const Padding(
                    padding: EdgeInsets.only(left: 6, top: 4),
                    child: Icon(Icons.bookmark, size: 16, color: AppColors.accentGold),
                  ),

                // Botão Rápido p/ Ouvir o Versículo Individualmente
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: isCurrentlySpeaking
                        ? 'Parar Leitura'
                        : 'Ouvir ${verse.reference} (${ttsState.voiceProfileLabel})',
                    icon: Icon(
                      isCurrentlySpeaking
                          ? Icons.stop_circle_rounded
                          : Icons.volume_up_rounded,
                      size: 18,
                      color: isCurrentlySpeaking
                          ? AppColors.accentGold
                          : (isDark ? Colors.white38 : Colors.black38),
                    ),
                    onPressed: () {
                      if (isCurrentlySpeaking) {
                        ref.read(bibleTtsProvider.notifier).stop();
                      } else {
                        ref.read(bibleTtsProvider.notifier).speakSingleVerse(verse);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchResults(BibleState state, bool isDark) {
    if (state.isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.searchResults.isEmpty) {
      return const Center(
        child: Text('Nenhum versículo encontrado para os termos pesquisados.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.searchResults.length,
      itemBuilder: (context, index) {
        final verse = state.searchResults[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(14),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  verse.reference,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                ),
                Row(
                  children: [
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Ouvir Versículo',
                      icon: const Icon(Icons.volume_up_rounded, size: 18, color: AppColors.accentGold),
                      onPressed: () {
                        ref.read(bibleTtsProvider.notifier).speakSingleVerse(verse);
                      },
                    ),
                    Text(
                      verse.version,
                      style: const TextStyle(fontSize: 11, color: AppColors.accentGold),
                    ),
                  ],
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                verse.text,
                style: const TextStyle(fontSize: 14, height: 1.4),
              ),
            ),
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: () {
              ref.read(bibleTtsProvider.notifier).stop();
              ref.read(bibleStateProvider.notifier).selectBook(verse.bookId);
              ref.read(bibleStateProvider.notifier).selectChapter(verse.chapter);
              ref.read(bibleStateProvider.notifier).clearSearch();
              _scrollToTop();
            },
          ),
        );
      },
    );
  }

  Widget _buildBottomChapterBar(BibleState state, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: state.hasPreviousChapter
                ? () {
                    ref.read(bibleTtsProvider.notifier).stop();
                    ref.read(bibleTtsProvider.notifier).clearSelection();
                    ref.read(bibleStateProvider.notifier).previousChapter();
                    _scrollToTop();
                  }
                : null,
            icon: const Icon(Icons.chevron_left, size: 20),
            label: const Text('Cap. Anterior'),
          ),
          Text(
            state.currentReference,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          TextButton.icon(
            onPressed: state.hasNextChapter
                ? () {
                    ref.read(bibleTtsProvider.notifier).stop();
                    ref.read(bibleTtsProvider.notifier).clearSelection();
                    ref.read(bibleStateProvider.notifier).nextChapter();
                    _scrollToTop();
                  }
                : null,
            label: const Text('Próx. Cap.'),
            icon: const Icon(Icons.chevron_right, size: 20),
          ),
        ],
      ),
    );
  }

  void _showVerseActions(
    BibleVerse verse,
    bool isBookmarked,
    List<BibleVerse> chapterVerses,
  ) {
    showDialog(
      context: context,
      builder: (_) => BibleVerseActionsDialog(
        verse: verse,
        isBookmarked: isBookmarked,
        onToggleBookmark: () {
          ref.read(bibleStateProvider.notifier).toggleBookmark(verse);
        },
        onInsertToSermon: widget.onVerseSelectedForSermon,
        onSpeakVerse: (gender) async {
          await ref.read(bibleTtsProvider.notifier).setGender(gender);
          ref.read(bibleTtsProvider.notifier).speakSingleVerse(verse);
        },
        onSpeakFromHere: () {
          ref.read(bibleTtsProvider.notifier).speakFromVerse(verse, chapterVerses);
        },
        onStartExcerptSelection: () {
          ref
              .read(bibleTtsProvider.notifier)
              .toggleSelectionMode(initialVerseNumber: verse.verse);
        },
      ),
    );
  }

  Widget _buildComparisonSelectorBar(BibleState state, bool isDark) {
    const availableVersions = ['ARC', 'ARA', 'NAA', 'NVI', 'ACF', 'BKJ'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.compare_arrows, size: 18, color: AppColors.accentGold),
          const SizedBox(width: 8),
          const Text(
            'Comparar (até 3 versões):',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: availableVersions.map((v) {
                final isSelected = state.comparisonVersions.contains(v);
                return FilterChip(
                  visualDensity: VisualDensity.compact,
                  label: Text(v, style: const TextStyle(fontSize: 11)),
                  selected: isSelected,
                  selectedColor: AppColors.primaryBlue.withValues(alpha: 0.2),
                  checkmarkColor: AppColors.primaryBlue,
                  onSelected: (_) {
                    ref.read(bibleStateProvider.notifier).toggleComparisonVersion(v);
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonVerseView(
    List<BibleVerseComparison> comparisons,
    BibleState state,
    bool isDark,
  ) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: comparisons.length,
      itemBuilder: (context, index) {
        final comp = comparisons[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        comp.reference,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 16),
                      tooltip: 'Copiar Comparação do Versículo',
                      onPressed: () {
                        final buffer = StringBuffer();
                        buffer.writeln('${comp.reference}:');
                        comp.textsByVersion.forEach((ver, text) {
                          buffer.writeln('[$ver] $text');
                        });
                        Clipboard.setData(ClipboardData(text: buffer.toString()));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Comparação do versículo ${comp.verse} copiada!'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...state.comparisonVersions.map((version) {
                  final text = comp.textsByVersion[version] ?? '(versículo não encontrado)';
                  final Color badgeColor = _getVersionBadgeColor(version);

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
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            version,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: badgeColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            text,
                            style: TextStyle(
                              fontSize: state.fontSize,
                              height: 1.45,
                              color: isDark ? Colors.grey[200] : Colors.grey[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getVersionBadgeColor(String version) {
    switch (version) {
      case 'ARC':
        return AppColors.primaryBlue;
      case 'ARA':
        return const Color(0xFF2563EB);
      case 'NAA':
        return const Color(0xFF0D9488);
      case 'NVI':
        return const Color(0xFF059669);
      case 'ACF':
        return const Color(0xFFD97706);
      case 'BKJ':
        return const Color(0xFF7C3AED);
      default:
        return AppColors.primaryBlue;
    }
  }
}
