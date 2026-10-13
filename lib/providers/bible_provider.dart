import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bible_model.dart';
import '../repositories/bible_repository.dart';

final bibleRepositoryProvider = Provider<BibleRepository>((ref) {
  return BibleRepository();
});

class BibleState {
  final String selectedBookId;
  final int selectedChapter;
  final String selectedVersion;
  final double fontSize;
  final String searchQuery;
  final List<BibleVerse> searchResults;
  final bool isSearching;
  final List<BibleBookmark> bookmarks;

  const BibleState({
    this.selectedBookId = 'jo', // Inicia em João
    this.selectedChapter = 3,  // Capítulo 3
    this.selectedVersion = 'ARC',
    this.fontSize = 18.0,
    this.searchQuery = '',
    this.searchResults = const [],
    this.isSearching = false,
    this.bookmarks = const [],
  });

  BibleBookMetadata? get currentBook =>
      BibleRepository.getBookMetadata(selectedBookId);

  String get currentReference =>
      '${BibleRepository.getBookName(selectedBookId)} $selectedChapter';

  bool get hasPreviousChapter => selectedChapter > 1;
  bool get hasNextChapter {
    final b = currentBook;
    return b != null && selectedChapter < b.totalChapters;
  }

  BibleState copyWith({
    String? selectedBookId,
    int? selectedChapter,
    String? selectedVersion,
    double? fontSize,
    String? searchQuery,
    List<BibleVerse>? searchResults,
    bool? isSearching,
    List<BibleBookmark>? bookmarks,
  }) {
    return BibleState(
      selectedBookId: selectedBookId ?? this.selectedBookId,
      selectedChapter: selectedChapter ?? this.selectedChapter,
      selectedVersion: selectedVersion ?? this.selectedVersion,
      fontSize: fontSize ?? this.fontSize,
      searchQuery: searchQuery ?? this.searchQuery,
      searchResults: searchResults ?? this.searchResults,
      isSearching: isSearching ?? this.isSearching,
      bookmarks: bookmarks ?? this.bookmarks,
    );
  }
}

class BibleStateNotifier extends StateNotifier<BibleState> {
  final BibleRepository _repository;

  BibleStateNotifier(this._repository) : super(const BibleState()) {
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final b = await _repository.getBookmarks();
    state = state.copyWith(bookmarks: b);
  }

  void selectBook(String bookId) {
    state = state.copyWith(
      selectedBookId: bookId,
      selectedChapter: 1, // Reseta para capítulo 1 ao trocar de livro
      searchQuery: '',
      searchResults: [],
    );
  }

  void selectChapter(int chapter) {
    state = state.copyWith(
      selectedChapter: chapter,
      searchQuery: '',
      searchResults: [],
    );
  }

  void nextChapter() {
    if (state.hasNextChapter) {
      state = state.copyWith(selectedChapter: state.selectedChapter + 1);
    }
  }

  void previousChapter() {
    if (state.hasPreviousChapter) {
      state = state.copyWith(selectedChapter: state.selectedChapter - 1);
    }
  }

  void setVersion(String version) {
    state = state.copyWith(selectedVersion: version.toUpperCase());
  }

  void setFontSize(double size) {
    state = state.copyWith(fontSize: size.clamp(14.0, 30.0));
  }

  Future<void> search(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      clearSearch();
      return;
    }

    state = state.copyWith(searchQuery: q, isSearching: true);
    final results = await _repository.searchVerses(
      query: q,
      version: state.selectedVersion,
    );
    state = state.copyWith(searchResults: results, isSearching: false);
  }

  void clearSearch() {
    state = state.copyWith(
      searchQuery: '',
      searchResults: [],
      isSearching: false,
    );
  }

  Future<void> toggleBookmark(BibleVerse verse) async {
    await _repository.toggleBookmark(verse);
    final updated = await _repository.getBookmarks();
    state = state.copyWith(bookmarks: updated);
  }
}

final bibleStateProvider =
    StateNotifierProvider<BibleStateNotifier, BibleState>((ref) {
  final repo = ref.watch(bibleRepositoryProvider);
  return BibleStateNotifier(repo);
});

final currentChapterVersesProvider = FutureProvider<List<BibleVerse>>((ref) async {
  final repo = ref.watch(bibleRepositoryProvider);
  final state = ref.watch(bibleStateProvider);

  return repo.getChapterVerses(
    bookId: state.selectedBookId,
    chapter: state.selectedChapter,
    version: state.selectedVersion,
  );
});
