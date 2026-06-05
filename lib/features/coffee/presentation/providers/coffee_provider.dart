import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/ai_service.dart';

// Kahve Falı Durum Modeli
class CoffeeState {
  final bool isLoading;
  final String? errorMessage;
  final String? readingResult;
  final XFile? selectedImage;

  CoffeeState({
    this.isLoading = false,
    this.errorMessage,
    this.readingResult,
    this.selectedImage,
  });

  CoffeeState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? readingResult,
    XFile? selectedImage,
  }) {
    return CoffeeState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage, // Her zaman sıfırlanabilmesi için direkt atanıyor
      readingResult: readingResult ?? this.readingResult,
      selectedImage: selectedImage ?? this.selectedImage,
    );
  }
}

// StateNotifier Sınıfı
class CoffeeNotifier extends StateNotifier<CoffeeState> {
  final AiService _aiService;

  CoffeeNotifier(this._aiService) : super(CoffeeState());

  void selectImage(XFile image) {
    state = state.copyWith(selectedImage: image, errorMessage: null);
  }

  void clearImage() {
    state = CoffeeState(); // Her şeyi sıfırla
  }

  Future<void> getReading(String intention) async {
    if (intention.isEmpty) {
      state = state.copyWith(errorMessage: "Lütfen falınız için bir niyet belirtin.");
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null, readingResult: null);

    try {
      String? base64Str;
      if (state.selectedImage != null) {
        final bytes = await state.selectedImage!.readAsBytes();
        base64Str = base64Encode(bytes);
      }

      final result = await _aiService.interpretCoffee(
        base64Image: base64Str,
        userIntention: intention,
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

// Riverpod Providers
final aiServiceProvider = Provider<AiService>((ref) => AiService());

final coffeeProvider = StateNotifierProvider<CoffeeNotifier, CoffeeState>((ref) {
  final aiService = ref.watch(aiServiceProvider);
  return CoffeeNotifier(aiService);
});
