import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sermon_model.dart';
import '../repositories/sermon_repository.dart';

final sermonRepositoryProvider = Provider<SermonRepository>((ref) {
  final repo = SermonRepository();
  repo.init();
  return repo;
});

class SermonListState {
  final List<Sermon> sermons;
  final bool isLoading;
  final String? errorMessage;
  final String selectedCategory;
  final String searchQuery;
  final String selectedStatus;
  final String? selectedSermonIdForMasterDetail;

  const SermonListState({
    this.sermons = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedCategory = 'Todas',
    this.searchQuery = '',
    this.selectedStatus = '',
    this.selectedSermonIdForMasterDetail,
  });

  SermonListState copyWith({
    List<Sermon>? sermons,
    bool? isLoading,
    String? errorMessage,
    String? selectedCategory,
    String? searchQuery,
    String? selectedStatus,
    String? selectedSermonIdForMasterDetail,
  }) {
    return SermonListState(
      sermons: sermons ?? this.sermons,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedStatus: selectedStatus ?? this.selectedStatus,
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

  // Estatísticas para o Dashboard
  int get totalSermons => sermons.length;
  int get readySermons => sermons.where((s) => s.status == 'ready').length;
  int get draftSermons => sermons.where((s) => s.status == 'draft').length;
  int get totalPreachCount => sermons.fold(0, (acc, s) => acc + s.preachCount);
  List<Sermon> get favoriteSermons => sermons.where((s) => s.isFavorite).toList();
  List<Sermon> get recentSermons => sermons.take(5).toList();
}

class SermonListNotifier extends StateNotifier<SermonListState> {
  final SermonRepository _repository;

  SermonListNotifier(this._repository) : super(const SermonListState()) {
    loadSermons();
  }

  Future<void> loadSermons() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _repository.getSermons(
        category: state.selectedCategory,
        searchQuery: state.searchQuery,
        status: state.selectedStatus,
      );
      state = state.copyWith(
        sermons: list,
        isLoading: false,
        selectedSermonIdForMasterDetail: state.selectedSermonIdForMasterDetail ??
            (list.isNotEmpty ? list.first.id : null),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setCategory(String category) {
    state = state.copyWith(selectedCategory: category);
    loadSermons();
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    loadSermons();
  }

  void setStatus(String status) {
    state = state.copyWith(selectedStatus: status);
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
