import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/ai_service.dart';
import '../../../coffee/presentation/providers/coffee_provider.dart';

class KatinaState {
  final bool isLoading;
  final String? errorMessage;
  final String? readingResult;
  final List<String> selectedCards;

  KatinaState({
    this.isLoading = false,
    this.errorMessage,
    this.readingResult,
    required this.selectedCards,
  });

  KatinaState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? readingResult,
    List<String>? selectedCards,
  }) {
    return KatinaState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      readingResult: readingResult ?? this.readingResult,
      selectedCards: selectedCards ?? this.selectedCards,
    );
  }
}

class KatinaNotifier extends StateNotifier<KatinaState> {
  final AiService _aiService;

  KatinaNotifier(this._aiService) : super(KatinaState(selectedCards: []));

  bool toggleCard(String cardName) {
    final currentCards = List<String>.from(state.selectedCards);
    
    if (currentCards.contains(cardName)) {
      currentCards.remove(cardName);
      state = state.copyWith(selectedCards: currentCards, errorMessage: null);
      return false;
    } else {
      if (currentCards.length >= 3) {
        state = state.copyWith(errorMessage: "Zaten 3 kart seçtiniz. Devam etmek için falınızı başlatın.");
        return false;
      }
      currentCards.add(cardName);
      state = state.copyWith(selectedCards: currentCards, errorMessage: null);
      return true;
    }
  }

  void reset() {
    state = KatinaState(selectedCards: []);
  }

  Future<void> getReading(String question) async {
    if (state.selectedCards.length < 3) {
      state = state.copyWith(errorMessage: "Lütfen falınız için 3 adet kart seçin.");
      return;
    }
    
    final niyet = question.isEmpty ? "Genel Katina Falı" : question;
    state = state.copyWith(isLoading: true, errorMessage: null, readingResult: null);

    try {
      final result = await _aiService.interpretKatina(
        selectedCards: state.selectedCards,
        userQuestion: niyet,
      );

      state = state.copyWith(isLoading: false, readingResult: result);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll("Exception: ", ""),
      );
    }
  }
}

final katinaProvider = StateNotifierProvider<KatinaNotifier, KatinaState>((ref) {
  final aiService = ref.watch(aiServiceProvider);
  return KatinaNotifier(aiService);
});
