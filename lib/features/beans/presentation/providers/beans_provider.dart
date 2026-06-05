import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/ai_service.dart';
import '../../../coffee/presentation/providers/coffee_provider.dart';

class BeanPosition {
  final double x; // 0.0 ile 1.0 arası x konumu
  final double y; // 0.0 ile 1.0 arası y konumu
  final double rotation; // Döndürme açısı (radyan)

  BeanPosition({required this.x, required this.y, required this.rotation});
}

class BeansState {
  final bool isLoading;
  final String? errorMessage;
  final String? readingResult;
  final List<BeanPosition> beanPositions;

  BeansState({
    this.isLoading = false,
    this.errorMessage,
    this.readingResult,
    required this.beanPositions,
  });

  BeansState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? readingResult,
    List<BeanPosition>? beanPositions,
  }) {
    return BeansState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      readingResult: readingResult ?? this.readingResult,
      beanPositions: beanPositions ?? this.beanPositions,
    );
  }
}

class BeansNotifier extends StateNotifier<BeansState> {
  final AiService _aiService;
  final Random _random = Random();

  BeansNotifier(this._aiService) : super(BeansState(beanPositions: []));

  void reset() {
    state = BeansState(beanPositions: []);
  }

  // Baklaları saçma fonksiyonu
  void castBeans() {
    final List<BeanPosition> positions = [];
    // 15 adet baklayı rastgele saçalım (merkeze odaklı, hafif dağınık yerleşim)
    for (int i = 0; i < 15; i++) {
      // Merkeze daha yakın yerleşmeleri için gaussian benzeri yerleşim yapıyoruz
      final double angle = _random.nextDouble() * 2 * pi;
      final double distance = 0.1 + _random.nextDouble() * 0.35; // 0.1 ile 0.45 arası yarıçap
      
      final double x = 0.5 + cos(angle) * distance;
      final double y = 0.5 + sin(angle) * distance;
      final double rotation = _random.nextDouble() * 2 * pi;

      positions.add(BeanPosition(
        x: x.clamp(0.05, 0.95),
        y: y.clamp(0.05, 0.95),
        rotation: rotation,
      ));
    }
    state = state.copyWith(beanPositions: positions, errorMessage: null);
  }

  Future<void> getReading(String intention) async {
    if (intention.trim().isEmpty) {
      state = state.copyWith(errorMessage: "Lütfen falınız için bir niyet belirtin.");
      return;
    }

    if (state.beanPositions.isEmpty) {
      state = state.copyWith(errorMessage: "Lütfen önce baklaları dökün.");
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null, readingResult: null);

    // Baklaların konumlarına göre bir yerleşim özeti çıkaralım
    int centerCount = 0;
    int edgeCount = 0;
    int upperCount = 0;
    int lowerCount = 0;

    for (final pos in state.beanPositions) {
      final double distFromCenter = sqrt(pow(pos.x - 0.5, 2) + pow(pos.y - 0.5, 2));
      if (distFromCenter < 0.22) {
        centerCount++;
      } else {
        edgeCount++;
      }

      if (pos.y < 0.5) {
        upperCount++;
      } else {
        lowerCount++;
      }
    }

    final String patternDesc = "Düzleme dökülen 15 baklanın yerleşim şekilleri:\n"
        "- Merkezde yoğunlaşan: $centerCount adet\n"
        "- Çeperlere saçılan: $edgeCount adet\n"
        "- Üst bölgede toplanan: $upperCount adet\n"
        "- Alt bölgede kümelenen: $lowerCount adet";

    try {
      final result = await _aiService.interpretBeans(
        patternDescription: patternDesc,
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

final beansProvider = StateNotifierProvider<BeansNotifier, BeansState>((ref) {
  final aiService = ref.watch(aiServiceProvider);
  return BeansNotifier(aiService);
});
