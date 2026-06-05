import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/ai_service.dart';
import '../../../coffee/presentation/providers/coffee_provider.dart';

class YildiznameState {
  final bool isLoading;
  final String? errorMessage;
  final String? readingResult;

  YildiznameState({
    this.isLoading = false,
    this.errorMessage,
    this.readingResult,
  });

  YildiznameState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? readingResult,
  }) {
    return YildiznameState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      readingResult: readingResult ?? this.readingResult,
    );
  }
}

class YildiznameNotifier extends StateNotifier<YildiznameState> {
  final AiService _aiService;

  YildiznameNotifier(this._aiService) : super(YildiznameState());

  void reset() {
    state = YildiznameState();
  }

  Future<void> getReading({
    required String name,
    required String surname,
    required String motherName,
    required String fatherName,
    required String birthDate,
    required String birthPlace,
    required String birthHour,
  }) async {
    if (name.trim().isEmpty ||
        surname.trim().isEmpty ||
        motherName.trim().isEmpty ||
        fatherName.trim().isEmpty ||
        birthDate.trim().isEmpty ||
        birthPlace.trim().isEmpty ||
        birthHour.trim().isEmpty) {
      state = state.copyWith(errorMessage: "Lütfen tüm yıldızname form alanlarını eksiksiz doldurun.");
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null, readingResult: null);

    try {
      final result = await _aiService.interpretYildizname(
        name: name,
        surname: surname,
        motherName: motherName,
        fatherName: fatherName,
        birthDate: birthDate,
        birthPlace: birthPlace,
        birthHour: birthHour,
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

final yildiznameProvider = StateNotifierProvider<YildiznameNotifier, YildiznameState>((ref) {
  final aiService = ref.watch(aiServiceProvider);
  return YildiznameNotifier(aiService);
});
