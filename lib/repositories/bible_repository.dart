import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/network/supabase_config.dart';
import '../models/bible_model.dart';

class BibleRepository {
  // Metadados dos 66 Livros Canônicos
  static const List<BibleBookMetadata> canonicalBooks = [
    // --- ANTIGO TESTAMENTO (39) ---
    BibleBookMetadata(id: 'gn', name: 'Gênesis', testament: 'Antigo', category: 'Pentateuco', totalChapters: 50),
    BibleBookMetadata(id: 'ex', name: 'Êxodo', testament: 'Antigo', category: 'Pentateuco', totalChapters: 40),
    BibleBookMetadata(id: 'lv', name: 'Levítico', testament: 'Antigo', category: 'Pentateuco', totalChapters: 27),
    BibleBookMetadata(id: 'nm', name: 'Números', testament: 'Antigo', category: 'Pentateuco', totalChapters: 36),
    BibleBookMetadata(id: 'dt', name: 'Deuteronômio', testament: 'Antigo', category: 'Pentateuco', totalChapters: 34),
    BibleBookMetadata(id: 'js', name: 'Josué', testament: 'Antigo', category: 'Históricos', totalChapters: 24),
    BibleBookMetadata(id: 'jz', name: 'Juízes', testament: 'Antigo', category: 'Históricos', totalChapters: 21),
    BibleBookMetadata(id: 'rt', name: 'Rute', testament: 'Antigo', category: 'Históricos', totalChapters: 4),
    BibleBookMetadata(id: '1sm', name: '1 Samuel', testament: 'Antigo', category: 'Históricos', totalChapters: 31),
    BibleBookMetadata(id: '2sm', name: '2 Samuel', testament: 'Antigo', category: 'Históricos', totalChapters: 24),
    BibleBookMetadata(id: '1rs', name: '1 Reis', testament: 'Antigo', category: 'Históricos', totalChapters: 22),
    BibleBookMetadata(id: '2rs', name: '2 Reis', testament: 'Antigo', category: 'Históricos', totalChapters: 25),
    BibleBookMetadata(id: '1cr', name: '1 Crônicas', testament: 'Antigo', category: 'Históricos', totalChapters: 29),
    BibleBookMetadata(id: '2cr', name: '2 Crônicas', testament: 'Antigo', category: 'Históricos', totalChapters: 36),
    BibleBookMetadata(id: 'ed', name: 'Esdras', testament: 'Antigo', category: 'Históricos', totalChapters: 10),
    BibleBookMetadata(id: 'ne', name: 'Neemias', testament: 'Antigo', category: 'Históricos', totalChapters: 13),
    BibleBookMetadata(id: 'et', name: 'Ester', testament: 'Antigo', category: 'Históricos', totalChapters: 10),
    BibleBookMetadata(id: 'jó', name: 'Jó', testament: 'Antigo', category: 'Poéticos', totalChapters: 42),
    BibleBookMetadata(id: 'sl', name: 'Salmos', testament: 'Antigo', category: 'Poéticos', totalChapters: 150),
    BibleBookMetadata(id: 'pv', name: 'Provérbios', testament: 'Antigo', category: 'Poéticos', totalChapters: 31),
    BibleBookMetadata(id: 'ec', name: 'Eclesiastes', testament: 'Antigo', category: 'Poéticos', totalChapters: 12),
    BibleBookMetadata(id: 'ct', name: 'Cantares', testament: 'Antigo', category: 'Poéticos', totalChapters: 8),
    BibleBookMetadata(id: 'is', name: 'Isaías', testament: 'Antigo', category: 'Profetas Maiores', totalChapters: 66),
    BibleBookMetadata(id: 'jr', name: 'Jeremias', testament: 'Antigo', category: 'Profetas Maiores', totalChapters: 52),
    BibleBookMetadata(id: 'lm', name: 'Lamentações', testament: 'Antigo', category: 'Profetas Maiores', totalChapters: 5),
    BibleBookMetadata(id: 'ez', name: 'Ezequiel', testament: 'Antigo', category: 'Profetas Maiores', totalChapters: 48),
    BibleBookMetadata(id: 'dn', name: 'Daniel', testament: 'Antigo', category: 'Profetas Maiores', totalChapters: 12),
    BibleBookMetadata(id: 'os', name: 'Oseias', testament: 'Antigo', category: 'Profetas Menores', totalChapters: 14),
    BibleBookMetadata(id: 'jl', name: 'Joel', testament: 'Antigo', category: 'Profetas Menores', totalChapters: 3),
    BibleBookMetadata(id: 'am', name: 'Amós', testament: 'Antigo', category: 'Profetas Menores', totalChapters: 9),
    BibleBookMetadata(id: 'ob', name: 'Obadias', testament: 'Antigo', category: 'Profetas Menores', totalChapters: 1),
    BibleBookMetadata(id: 'jn', name: 'Jonas', testament: 'Antigo', category: 'Profetas Menores', totalChapters: 4),
    BibleBookMetadata(id: 'mq', name: 'Miqueias', testament: 'Antigo', category: 'Profetas Menores', totalChapters: 7),
    BibleBookMetadata(id: 'na', name: 'Naum', testament: 'Antigo', category: 'Profetas Menores', totalChapters: 3),
    BibleBookMetadata(id: 'hc', name: 'Habacuque', testament: 'Antigo', category: 'Profetas Menores', totalChapters: 3),
    BibleBookMetadata(id: 'sf', name: 'Sofonias', testament: 'Antigo', category: 'Profetas Menores', totalChapters: 3),
    BibleBookMetadata(id: 'ag', name: 'Ageu', testament: 'Antigo', category: 'Profetas Menores', totalChapters: 2),
    BibleBookMetadata(id: 'zc', name: 'Zacarias', testament: 'Antigo', category: 'Profetas Menores', totalChapters: 14),
    BibleBookMetadata(id: 'ml', name: 'Malaquias', testament: 'Antigo', category: 'Profetas Menores', totalChapters: 4),

    // --- NOVO TESTAMENTO (27) ---
    BibleBookMetadata(id: 'mt', name: 'Mateus', testament: 'Novo', category: 'Evangelhos', totalChapters: 28),
    BibleBookMetadata(id: 'mc', name: 'Marcos', testament: 'Novo', category: 'Evangelhos', totalChapters: 16),
    BibleBookMetadata(id: 'lc', name: 'Lucas', testament: 'Novo', category: 'Evangelhos', totalChapters: 24),
    BibleBookMetadata(id: 'jo', name: 'João', testament: 'Novo', category: 'Evangelhos', totalChapters: 21),
    BibleBookMetadata(id: 'atos', name: 'Atos', testament: 'Novo', category: 'Histórico', totalChapters: 28),
    BibleBookMetadata(id: 'rm', name: 'Romanos', testament: 'Novo', category: 'Cartas Paulinas', totalChapters: 16),
    BibleBookMetadata(id: '1co', name: '1 Coríntios', testament: 'Novo', category: 'Cartas Paulinas', totalChapters: 16),
    BibleBookMetadata(id: '2co', name: '2 Coríntios', testament: 'Novo', category: 'Cartas Paulinas', totalChapters: 13),
    BibleBookMetadata(id: 'gl', name: 'Gálatas', testament: 'Novo', category: 'Cartas Paulinas', totalChapters: 6),
    BibleBookMetadata(id: 'ef', name: 'Efésios', testament: 'Novo', category: 'Cartas Paulinas', totalChapters: 6),
    BibleBookMetadata(id: 'fp', name: 'Filipenses', testament: 'Novo', category: 'Cartas Paulinas', totalChapters: 4),
    BibleBookMetadata(id: 'cl', name: 'Colossenses', testament: 'Novo', category: 'Cartas Paulinas', totalChapters: 4),
    BibleBookMetadata(id: '1ts', name: '1 Tessalonicenses', testament: 'Novo', category: 'Cartas Paulinas', totalChapters: 5),
    BibleBookMetadata(id: '2ts', name: '2 Tessalonicenses', testament: 'Novo', category: 'Cartas Paulinas', totalChapters: 3),
    BibleBookMetadata(id: '1tm', name: '1 Timóteo', testament: 'Novo', category: 'Cartas Paulinas', totalChapters: 6),
    BibleBookMetadata(id: '2tm', name: '2 Timóteo', testament: 'Novo', category: 'Cartas Paulinas', totalChapters: 4),
    BibleBookMetadata(id: 'tt', name: 'Tito', testament: 'Novo', category: 'Cartas Paulinas', totalChapters: 3),
    BibleBookMetadata(id: 'fm', name: 'Filemom', testament: 'Novo', category: 'Cartas Paulinas', totalChapters: 1),
    BibleBookMetadata(id: 'hb', name: 'Hebreus', testament: 'Novo', category: 'Cartas Gerais', totalChapters: 13),
    BibleBookMetadata(id: 'tg', name: 'Tiago', testament: 'Novo', category: 'Cartas Gerais', totalChapters: 5),
    BibleBookMetadata(id: '1pe', name: '1 Pedro', testament: 'Novo', category: 'Cartas Gerais', totalChapters: 5),
    BibleBookMetadata(id: '2pe', name: '2 Pedro', testament: 'Novo', category: 'Cartas Gerais', totalChapters: 3),
    BibleBookMetadata(id: '1jo', name: '1 João', testament: 'Novo', category: 'Cartas Gerais', totalChapters: 5),
    BibleBookMetadata(id: '2jo', name: '2 João', testament: 'Novo', category: 'Cartas Gerais', totalChapters: 1),
    BibleBookMetadata(id: '3jo', name: '3 João', testament: 'Novo', category: 'Cartas Gerais', totalChapters: 1),
    BibleBookMetadata(id: 'jd', name: 'Judas', testament: 'Novo', category: 'Cartas Gerais', totalChapters: 1),
    BibleBookMetadata(id: 'ap', name: 'Apocalipse', testament: 'Novo', category: 'Profético', totalChapters: 22),
  ];

  static final Map<String, BibleBookMetadata> _bookMap = {
    for (final b in canonicalBooks) b.id: b,
  };

  // Cache em memória: version -> list of parsed books
  final Map<String, List<Map<String, dynamic>>> _rawVersionsCache = {};

  // Bookmarks locais
  static const String _bookmarksPrefKey = 'pregador_pro_bible_bookmarks';
  List<BibleBookmark>? _cachedBookmarks;

  /// Retorna o nome amigável do livro a partir do ID
  static String getBookName(String bookId) {
    return _bookMap[bookId.toLowerCase()]?.name ?? bookId;
  }

  /// Retorna metadados do livro
  static BibleBookMetadata? getBookMetadata(String bookId) {
    return _bookMap[bookId.toLowerCase()];
  }

  /// Carrega versão da Bíblia a partir de assets locais (ARC, NVI, ACF)
  Future<List<Map<String, dynamic>>> _loadVersion(String version) async {
    final v = version.toUpperCase();
    if (_rawVersionsCache.containsKey(v)) {
      return _rawVersionsCache[v]!;
    }

    String assetPath;
    switch (v) {
      case 'NVI':
        assetPath = 'assets/bible/pt_nvi.json';
        break;
      case 'ACF':
        assetPath = 'assets/bible/pt_acf.json';
        break;
      case 'ARC':
      default:
        assetPath = 'assets/bible/pt_arc.json';
        break;
    }

    try {
      final jsonStr = await rootBundle.loadString(assetPath);
      final dynamic decoded = jsonDecode(jsonStr);
      if (decoded is List) {
        final list = decoded.cast<Map<String, dynamic>>();
        _rawVersionsCache[v] = list;
        return list;
      }
    } catch (e) {
      // Se falhar carregar versão específica, tenta fallback para ARC
      if (v != 'ARC') {
        return _loadVersion('ARC');
      }
    }

    return [];
  }

  /// Obtém os versículos de um capítulo específico
  Future<List<BibleVerse>> getChapterVerses({
    required String bookId,
    required int chapter,
    String version = 'ARC',
  }) async {
    final rawBooks = await _loadVersion(version);
    final normalizedId = bookId.toLowerCase();
    final bookData = rawBooks.firstWhere(
      (b) => (b['abbrev'] as String? ?? '').toLowerCase() == normalizedId,
      orElse: () => <String, dynamic>{},
    );

    if (bookData.isEmpty) return [];

    final chapters = bookData['chapters'] as List<dynamic>? ?? [];
    final chapterIndex = chapter - 1;

    if (chapterIndex < 0 || chapterIndex >= chapters.length) return [];

    final rawVerses = chapters[chapterIndex] as List<dynamic>? ?? [];
    final bookName = getBookName(normalizedId);

    return rawVerses.asMap().entries.map((entry) {
      final verseNum = entry.key + 1;
      final text = entry.value.toString();
      return BibleVerse(
        bookId: normalizedId,
        bookName: bookName,
        chapter: chapter,
        verse: verseNum,
        text: text,
        version: version,
      );
    }).toList();
  }

  /// Realiza busca por palavra-chave em toda a Bíblia
  Future<List<BibleVerse>> searchVerses({
    required String query,
    String version = 'ARC',
    int limit = 50,
  }) async {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return [];

    final rawBooks = await _loadVersion(version);
    final results = <BibleVerse>[];

    for (final book in rawBooks) {
      final bookId = (book['abbrev'] as String? ?? '').toLowerCase();
      final bookName = getBookName(bookId);
      final chapters = book['chapters'] as List<dynamic>? ?? [];

      for (var cIdx = 0; cIdx < chapters.length; cIdx++) {
        final chapterNum = cIdx + 1;
        final verses = chapters[cIdx] as List<dynamic>? ?? [];

        for (var vIdx = 0; vIdx < verses.length; vIdx++) {
          final verseNum = vIdx + 1;
          final text = verses[vIdx].toString();

          if (text.toLowerCase().contains(trimmed)) {
            results.add(BibleVerse(
              bookId: bookId,
              bookName: bookName,
              chapter: chapterNum,
              verse: verseNum,
              text: text,
              version: version,
            ));

            if (results.length >= limit) return results;
          }
        }
      }
    }

    return results;
  }

  /// Carrega marcadores/favoritos (Local + Supabase)
  Future<List<BibleBookmark>> getBookmarks() async {
    if (_cachedBookmarks != null) return _cachedBookmarks!;

    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_bookmarksPrefKey) ?? [];

    _cachedBookmarks = jsonList
        .map((str) => BibleBookmark.fromJson(jsonDecode(str) as Map<String, dynamic>))
        .toList();

    // Sincronização remota silenciosa se Supabase conectado
    _trySyncBookmarksWithSupabase();

    return _cachedBookmarks!;
  }

  Future<void> _trySyncBookmarksWithSupabase() async {
    final client = SupabaseConfig.client;
    if (client == null || client.auth.currentUser == null) return;

    try {
      final res = await client
          .from('bible_bookmarks')
          .select()
          .order('created_at', ascending: false)
          .timeout(const Duration(milliseconds: 3000));

      final remoteList = (res as List).map((row) {
        final data = row as Map<String, dynamic>;
        return BibleBookmark(
          id: data['id']?.toString() ?? '',
          bookId: data['book']?.toString() ?? '',
          bookName: getBookName(data['book']?.toString() ?? ''),
          chapter: data['chapter'] as int? ?? 1,
          verse: data['verse'] as int? ?? 1,
          text: data['note']?.toString() ?? '',
          version: data['version']?.toString() ?? 'ARC',
          colorHex: data['color_tag']?.toString() ?? '#D97706',
          note: data['note']?.toString(),
          createdAt: DateTime.tryParse(data['created_at']?.toString() ?? '') ?? DateTime.now(),
        );
      }).toList();

      if (remoteList.isNotEmpty) {
        _cachedBookmarks = remoteList;
      }
    } catch (_) {}
  }

  /// Verifica se um versículo está marcado
  Future<bool> isBookmarked(String bookId, int chapter, int verse) async {
    final bookmarks = await getBookmarks();
    final bId = bookId.toLowerCase();
    return bookmarks.any(
      (b) => b.bookId.toLowerCase() == bId && b.chapter == chapter && b.verse == verse,
    );
  }

  /// Alterna marcador/destaque do versículo
  Future<void> toggleBookmark(
    BibleVerse verse, {
    String colorHex = '#D97706',
    String? note,
  }) async {
    final bookmarks = List<BibleBookmark>.from(await getBookmarks());
    final bId = verse.bookId.toLowerCase();

    final existingIndex = bookmarks.indexWhere(
      (b) => b.bookId.toLowerCase() == bId && b.chapter == verse.chapter && b.verse == verse.verse,
    );

    if (existingIndex >= 0) {
      bookmarks.removeAt(existingIndex);
    } else {
      final newBookmark = BibleBookmark(
        id: '${bId}_${verse.chapter}_${verse.verse}_${DateTime.now().millisecondsSinceEpoch}',
        bookId: bId,
        bookName: verse.bookName,
        chapter: verse.chapter,
        verse: verse.verse,
        text: verse.text,
        version: verse.version,
        colorHex: colorHex,
        note: note,
        createdAt: DateTime.now(),
      );
      bookmarks.insert(0, newBookmark);
    }

    _cachedBookmarks = bookmarks;

    // Salvar localmente
    final prefs = await SharedPreferences.getInstance();
    final jsonList = bookmarks.map((b) => jsonEncode(b.toJson())).toList();
    await prefs.setStringList(_bookmarksPrefKey, jsonList);
  }
}
