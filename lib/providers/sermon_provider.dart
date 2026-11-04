import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sermon_model.dart';
import '../repositories/sermon_repository.dart';

final sermonRepositoryProvider = Provider<SermonRepository>((ref) {
  final repo = SermonRepository();
  repo.init();
  return repo;
});

class SermonListState {
  final List<Sermon> allSermons;
  final List<Sermon> sermons;
  final bool isLoading;
  final String? errorMessage;
  final String selectedCategory;
  final String searchQuery;
  final String selectedStatus;
  final bool onlyFavorites;
  final bool onlyPreached;
  final String? activeFilterLabel;
  final String? selectedSermonIdForMasterDetail;

  const SermonListState({
    this.allSermons = const [],
    this.sermons = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedCategory = 'Todas',
    this.searchQuery = '',
    this.selectedStatus = '',
    this.onlyFavorites = false,
    this.onlyPreached = false,
    this.activeFilterLabel,
    this.selectedSermonIdForMasterDetail,
  });

  SermonListState copyWith({
    List<Sermon>? allSermons,
    List<Sermon>? sermons,
    bool? isLoading,
    String? errorMessage,
    String? selectedCategory,
    String? searchQuery,
    String? selectedStatus,
    bool? onlyFavorites,
    bool? onlyPreached,
    String? activeFilterLabel,
    bool clearFilterLabel = false,
    String? selectedSermonIdForMasterDetail,
  }) {
    return SermonListState(
      allSermons: allSermons ?? this.allSermons,
      sermons: sermons ?? this.sermons,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      onlyFavorites: onlyFavorites ?? this.onlyFavorites,
      onlyPreached: onlyPreached ?? this.onlyPreached,
      activeFilterLabel: clearFilterLabel ? null : (activeFilterLabel ?? this.activeFilterLabel),
      selectedSermonIdForMasterDetail:
          selectedSermonIdForMasterDetail ?? this.selectedSermonIdForMasterDetail,
    );
  }

  Sermon? get selectedSermon {
    if (selectedSermonIdForMasterDetail == null) {
      return sermons.isNotEmpty ? sermons.first : null;
    }
    try {
      return sermons.firstWhere((s) => s.id == selectedSermonIdForMasterDetail);
    } catch (_) {
      return sermons.isNotEmpty ? sermons.first : null;
    }
  }

  // Estatísticas Reais para o Dashboard (baseadas em allSermons para precisão matemática total)
  int get totalSermons => allSermons.length;
  int get readySermons => allSermons.where((s) => s.status == 'ready').length;
  int get draftSermons => allSermons.where((s) => s.status == 'draft').length;
  int get totalPreachCount => allSermons.fold(0, (acc, s) => acc + s.preachCount);
  int get preachedSermonsCount => allSermons.where((s) => s.preachCount > 0).length;
  List<Sermon> get favoriteSermons => allSermons.where((s) => s.isFavorite).toList();
  List<Sermon> get recentSermons => allSermons.take(5).toList();

  // Categorias que possuem sermões reais (elimina categorias vazias da interface e ordena alfabeticamente)
  Map<String, int> get activeCategoriesWithCounts {
    final Map<String, int> counts = {};
    for (final s in allSermons) {
      final cat = s.category.trim();
      if (cat.isNotEmpty && cat.toLowerCase() != 'todas') {
        counts[cat] = (counts[cat] ?? 0) + 1;
      }
    }
    final sortedKeys = counts.keys.toList()..sort((a, b) => a.compareTo(b));
    return {for (final k in sortedKeys) k: counts[k]!};
  }

  bool get isAnyFilterActive =>
      selectedCategory != 'Todas' ||
      selectedStatus.isNotEmpty ||
      onlyFavorites ||
      onlyPreached ||
      searchQuery.isNotEmpty ||
      activeFilterLabel != null;
}

class SermonListNotifier extends StateNotifier<SermonListState> {
  final SermonRepository _repository;

  SermonListNotifier(this._repository) : super(const SermonListState()) {
    loadSermons();
  }

  Future<void> loadSermons() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final all = await _repository.getAllSermons();
      final filtered = await _repository.getSermons(
        category: state.selectedCategory,
        searchQuery: state.searchQuery,
        status: state.selectedStatus,
        onlyFavorites: state.onlyFavorites,
        onlyPreached: state.onlyPreached,
      );
      final currentId = state.selectedSermonIdForMasterDetail;
      final stillExists = filtered.any((s) => s.id == currentId);

      if (!mounted) return;
      state = state.copyWith(
        allSermons: all,
        sermons: filtered,
        isLoading: false,
        selectedSermonIdForMasterDetail: stillExists
            ? currentId
            : (filtered.isNotEmpty ? filtered.first.id : null),
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setCategory(String category) {
    state = state.copyWith(
      selectedCategory: category,
      onlyFavorites: false,
      onlyPreached: false,
      clearFilterLabel: true,
      selectedSermonIdForMasterDetail: null,
    );
    loadSermons();
  }

  void setSearchQuery(String query) {
    state = state.copyWith(
      searchQuery: query,
      selectedSermonIdForMasterDetail: null,
    );
    loadSermons();
  }

  void setStatus(String status) {
    state = state.copyWith(
      selectedStatus: status,
      clearFilterLabel: true,
      selectedSermonIdForMasterDetail: null,
    );
    loadSermons();
  }

  void toggleOnlyFavorites() {
    final next = !state.onlyFavorites;
    state = state.copyWith(
      onlyFavorites: next,
      activeFilterLabel: next ? 'Favoritos' : null,
      clearFilterLabel: !next,
      selectedSermonIdForMasterDetail: null,
    );
    loadSermons();
  }

  void toggleOnlyPreached() {
    final next = !state.onlyPreached;
    state = state.copyWith(
      onlyPreached: next,
      activeFilterLabel: next ? 'Ministrados / Histórico' : null,
      clearFilterLabel: !next,
      selectedSermonIdForMasterDetail: null,
    );
    loadSermons();
  }

  void filterByStatus(String status, {String? label}) {
    state = state.copyWith(
      selectedStatus: status,
      selectedCategory: 'Todas',
      onlyFavorites: false,
      onlyPreached: false,
      searchQuery: '',
      activeFilterLabel: label ?? (status == 'ready' ? 'Prontos para Ministrar' : status),
      selectedSermonIdForMasterDetail: null,
    );
    loadSermons();
  }

  void filterByFavorites() {
    state = state.copyWith(
      onlyFavorites: true,
      selectedStatus: '',
      selectedCategory: 'Todas',
      onlyPreached: false,
      searchQuery: '',
      activeFilterLabel: 'Favoritos',
      selectedSermonIdForMasterDetail: null,
    );
    loadSermons();
  }

  void filterByPreached() {
    state = state.copyWith(
      onlyPreached: true,
      selectedStatus: '',
      selectedCategory: 'Todas',
      onlyFavorites: false,
      searchQuery: '',
      activeFilterLabel: 'Ministrados / Histórico',
      selectedSermonIdForMasterDetail: null,
    );
    loadSermons();
  }

  void resetFilters() {
    state = state.copyWith(
      selectedCategory: 'Todas',
      searchQuery: '',
      selectedStatus: '',
      onlyFavorites: false,
      onlyPreached: false,
      clearFilterLabel: true,
    );
    loadSermons();
  }

  void selectSermonForDetail(String sermonId) {
    state = state.copyWith(selectedSermonIdForMasterDetail: sermonId);
  }

  Future<void> toggleFavorite(String id) async {
    await _repository.toggleFavorite(id);
    await loadSermons();
  }

  Future<void> deleteSermon(String id) async {
    await _repository.deleteSermon(id);
    await loadSermons();
  }

  Future<void> recordPreached(String id) async {
    await _repository.recordPreached(id);
    await loadSermons();
  }

  Future<void> saveOrUpdateSermon(Sermon sermon) async {
    await _repository.saveSermon(sermon);
    await loadSermons();
  }
}

final sermonListProvider =
    StateNotifierProvider<SermonListNotifier, SermonListState>((ref) {
  final repo = ref.watch(sermonRepositoryProvider);
  return SermonListNotifier(repo);
});
