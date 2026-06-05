import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/ai_service.dart';
import '../../../coffee/presentation/providers/coffee_provider.dart'; // aiServiceProvider kullanımı için

class EyeState {
  final bool isLoading;
  final String? errorMessage;
  final String? readingResult;
  final XFile? selectedImage;

  EyeState({
    this.isLoading = false,
    this.errorMessage,
    this.readingResult,
    this.selectedImage,
  });

  EyeState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? readingResult,
    XFile? selectedImage,
  }) {
    return EyeState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      readingResult: readingResult ?? this.readingResult,
      selectedImage: selectedImage ?? this.selectedImage,
    );
  }
}

class EyeNotifier extends StateNotifier<EyeState> {
  final AiService _aiService;

  EyeNotifier(this._aiService) : super(EyeState());

  void selectImage(XFile image) {
    state = state.copyWith(selectedImage: image, errorMessage: null);
  }

  void clearImage() {
    state = EyeState();
  }

  Future<void> getReading(String intention) async {
    if (intention.isEmpty) {
      state = state.copyWith(errorMessage: "Lütfen falınız için bir niyet veya soru belirtin.");
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null, readingResult: null);

    try {
      String? base64Str;
      if (state.selectedImage != null) {
        final bytes = await state.selectedImage!.readAsBytes();
        base64Str = base64Encode(bytes);
      }

      final result = await _aiService.interpretEye(
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

final eyeProvider = StateNotifierProvider<EyeNotifier, EyeState>((ref) {
  final aiService = ref.watch(aiServiceProvider);
  return EyeNotifier(aiService);
});
