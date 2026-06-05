import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/ai_service.dart';
import '../../../../features/coffee/presentation/providers/coffee_provider.dart';

class SphereState {
  final bool isLoading;
  final String? errorMessage;
  final String? readingResult;

  SphereState({
    this.isLoading = false,
    this.errorMessage,
    this.readingResult,
  });

  SphereState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? readingResult,
  }) {
    return SphereState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      readingResult: readingResult ?? this.readingResult,
    );
  }
}

class SphereNotifier extends StateNotifier<SphereState> {
  final AiService _aiService;

  SphereNotifier(this._aiService) : super(SphereState());

  void reset() {
    state = SphereState();
  }

  Future<void> getReading(String question) async {
    if (question.trim().isEmpty) {
      state = state.copyWith(errorMessage: "Lütfen küreye sormak istediğiniz soruyu belirtin.");
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null, readingResult: null);

    try {
      final result = await _aiService.interpretSphere(userQuestion: question);
      state = state.copyWith(isLoading: false, readingResult: result);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll("Exception: ", ""),
      );
    }
  }
}

final sphereProvider = StateNotifierProvider<SphereNotifier, SphereState>((ref) {
  final aiService = ref.watch(aiServiceProvider);
  return SphereNotifier(aiService);
});
