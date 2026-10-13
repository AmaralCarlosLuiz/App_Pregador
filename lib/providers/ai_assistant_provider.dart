import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/ai_homiletics_service.dart';

class AiAssistantState {
  final bool isLoading;
  final String? errorMessage;
  final GeneratedOutlineResult? generatedOutline;
  final List<String> suggestedIllustrations;
  final List<GreekHebrewInsight> lexicalInsights;

  const AiAssistantState({
    this.isLoading = false,
    this.errorMessage,
    this.generatedOutline,
    this.suggestedIllustrations = const [],
    this.lexicalInsights = const [],
  });

  AiAssistantState copyWith({
    bool? isLoading,
    String? errorMessage,
    GeneratedOutlineResult? generatedOutline,
    List<String>? suggestedIllustrations,
    List<GreekHebrewInsight>? lexicalInsights,
  }) {
    return AiAssistantState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      generatedOutline: generatedOutline ?? this.generatedOutline,
      suggestedIllustrations: suggestedIllustrations ?? this.suggestedIllustrations,
      lexicalInsights: lexicalInsights ?? this.lexicalInsights,
    );
  }
}

class AiAssistantNotifier extends StateNotifier<AiAssistantState> {
  AiAssistantNotifier() : super(const AiAssistantState());

  Future<void> generateOutline({
    required String theme,
    required String biblicalReference,
    required String sermonType,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await AiHomileticsService.generateOutline(
        theme: theme,
        biblicalReference: biblicalReference,
        sermonType: sermonType,
      );
      state = state.copyWith(
        isLoading: false,
        generatedOutline: result,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> requestIllustrations({
    required String theme,
    required String pointContext,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await AiHomileticsService.generateIllustrations(
        sermonTheme: theme,
        pointContext: pointContext,
      );
      state = state.copyWith(
        isLoading: false,
        suggestedIllustrations: list,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> lookupLexicalInsights(String passage) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await AiHomileticsService.getLexicalInsights(
        biblicalPassage: passage,
      );
      state = state.copyWith(
        isLoading: false,
        lexicalInsights: list,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void clearOutline() {
    state = state.copyWith(generatedOutline: null);
  }
}

final aiAssistantProvider =
    StateNotifierProvider<AiAssistantNotifier, AiAssistantState>((ref) {
  return AiAssistantNotifier();
});
