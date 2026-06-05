import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/ai_service.dart';
import 'coffee_provider.dart'; // aiServiceProvider'ı yeniden kullanmak için

// Tarot Falı Durum Modeli
class TarotState {
  final bool isLoading;
  final String? errorMessage;
  final String? readingResult;
  final List<String> selectedCards;

  TarotState({
    this.isLoading = false,
    this.errorMessage,
    this.readingResult,
    required this.selectedCards,
  });

  TarotState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? readingResult,
    List<String>? selectedCards,
  }) {
    return TarotState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      readingResult: readingResult ?? this.readingResult,
      selectedCards: selectedCards ?? this.selectedCards,
    );
  }
}

// StateNotifier Sınıfı
class TarotNotifier extends StateNotifier<TarotState> {
  final AiService _aiService;

  TarotNotifier(this._aiService) : super(TarotState(selectedCards: []));

  // Kart seçimi (Maksimum 3 kart seçilebilir)
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
    state = TarotState(selectedCards: []);
  }

  Future<void> getReading(String question) async {
    if (state.selectedCards.length < 3) {
      state = state.copyWith(errorMessage: "Lütfen falınız için 3 adet kart seçin.");
      return;
    }
    
    final niyet = question.isEmpty ? "Genel Tarot Falı" : question;
    state = state.copyWith(isLoading: true, errorMessage: null, readingResult: null);

    try {
      final result = await _aiService.interpretTarot(
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

// Tarot Provider
final tarotProvider = StateNotifierProvider<TarotNotifier, TarotState>((ref) {
  final aiService = ref.watch(aiServiceProvider);
  return TarotNotifier(aiService);
});
