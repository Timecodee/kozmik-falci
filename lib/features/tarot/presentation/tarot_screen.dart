import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/mystic_loader.dart';
import '../../shared/presentation/result_screen.dart';
import 'providers/tarot_provider.dart';

class TarotScreen extends ConsumerStatefulWidget {
  const TarotScreen({super.key});

  @override
  ConsumerState<TarotScreen> createState() => _TarotScreenState();
}

class _TarotScreenState extends ConsumerState<TarotScreen> {
  final TextEditingController _questionController = TextEditingController();

  // 22 Büyük Arkana Tarot Kartı Listesi (Gerçek Wikipedia Commons Resimleri)
  final List<Map<String, dynamic>> _tarotDeck = [
    {
      "name": "Deli (The Fool)",
      "symbol": "🃏",
      "image": "https://upload.wikimedia.org/wikipedia/commons/9/90/RWS_Tarot_00_Fool.jpg"
    },
    {
      "name": "Büyücü (The Magician)",
      "symbol": "🧙‍♂️",
      "image": "https://upload.wikimedia.org/wikipedia/commons/d/de/RWS_Tarot_01_Magician.jpg"
    },
    {
      "name": "Azize (The High Priestess)",
      "symbol": "🌙",
      "image": "https://upload.wikimedia.org/wikipedia/commons/8/88/RWS_Tarot_02_High_Priestess.jpg"
    },
    {
      "name": "İmparatoriçe (The Empress)",
      "symbol": "👑",
      "image": "https://upload.wikimedia.org/wikipedia/commons/d/d2/RWS_Tarot_03_Empress.jpg"
    },
    {
      "name": "İmparator (The Emperor)",
      "symbol": "🏛️",
      "image": "https://upload.wikimedia.org/wikipedia/commons/c/c3/RWS_Tarot_04_Emperor.jpg"
    },
    {
      "name": "Aziz (The Hierophant)",
      "symbol": "📜",
      "image": "https://upload.wikimedia.org/wikipedia/commons/8/8d/RWS_Tarot_05_Hierophant.jpg"
    },
    {
      "name": "Aşıklar (The Lovers)",
      "symbol": "💖",
      "image": "https://upload.wikimedia.org/wikipedia/commons/3/3a/RWS_Tarot_06_Lovers.jpg"
    },
    {
      "name": "Araba (The Chariot)",
      "symbol": "🛡️",
      "image": "https://upload.wikimedia.org/wikipedia/commons/9/9b/RWS_Tarot_07_Chariot.jpg"
    },
    {
      "name": "Güç (Strength)",
      "symbol": "🦁",
      "image": "https://upload.wikimedia.org/wikipedia/commons/f/f5/RWS_Tarot_08_Strength.jpg"
    },
    {
      "name": "Ermiş (The Hermit)",
      "symbol": "⏳",
      "image": "https://upload.wikimedia.org/wikipedia/commons/4/4d/RWS_Tarot_09_Hermit.jpg"
    },
    {
      "name": "Kader Çarkı (Wheel of Fortune)",
      "symbol": "🌀",
      "image": "https://upload.wikimedia.org/wikipedia/commons/3/3c/RWS_Tarot_10_Wheel_of_Fortune.jpg"
    },
    {
      "name": "Adalet (Justice)",
      "symbol": "⚖️",
      "image": "https://upload.wikimedia.org/wikipedia/commons/e/e0/RWS_Tarot_11_Justice.jpg"
    },
    {
      "name": "Asılan Adam (The Hanged Man)",
      "symbol": "🙃",
      "image": "https://upload.wikimedia.org/wikipedia/commons/2/2b/RWS_Tarot_12_Hanged_Man.jpg"
    },
    {
      "name": "Ölüm (Death)",
      "symbol": "💀",
      "image": "https://upload.wikimedia.org/wikipedia/commons/d/d7/RWS_Tarot_13_Death.jpg"
    },
    {
      "name": "Denge (Temperance)",
      "symbol": "🏺",
      "image": "https://upload.wikimedia.org/wikipedia/commons/f/f8/RWS_Tarot_14_Temperance.jpg"
    },
    {
      "name": "Şeytan (The Devil)",
      "symbol": "🔥",
      "image": "https://upload.wikimedia.org/wikipedia/commons/5/55/RWS_Tarot_15_Devil.jpg"
    },
    {
      "name": "Yıkılan Kule (The Tower)",
      "symbol": "⚡",
      "image": "https://upload.wikimedia.org/wikipedia/commons/5/53/RWS_Tarot_16_Tower.jpg"
    },
    {
      "name": "Yıldız (The Star)",
      "symbol": "✨",
      "image": "https://upload.wikimedia.org/wikipedia/commons/d/db/RWS_Tarot_17_Star.jpg"
    },
    {
      "name": "Ay (The Moon)",
      "symbol": "🌕",
      "image": "https://upload.wikimedia.org/wikipedia/commons/7/7f/RWS_Tarot_18_Moon.jpg"
    },
    {
      "name": "Güneş (The Sun)",
      "symbol": "☀️",
      "image": "https://upload.wikimedia.org/wikipedia/commons/1/17/RWS_Tarot_19_Sun.jpg"
    },
    {
      "name": "Mahkeme (Judgement)",
      "symbol": "🎺",
      "image": "https://upload.wikimedia.org/wikipedia/commons/d/dd/RWS_Tarot_20_Judgement.jpg"
    },
    {
      "name": "Dünya (The World)",
      "symbol": "🌍",
      "image": "https://upload.wikimedia.org/wikipedia/commons/f/ff/RWS_Tarot_21_World.jpg"
    },
  ];

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tarotProvider);

    // Fal başarılı olduysa sonuç ekranını aç
    if (state.readingResult != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final result = state.readingResult!;
        final selectedCards = List<String>.from(state.selectedCards);
        
        // Provider'ı sıfırla
        ref.read(tarotProvider.notifier).reset();
        _questionController.clear();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              title: "TAROT FALI YORUMU",
              resultText: result,
              topWidget: _buildResultCardsHeader(selectedCards),
            ),
          ),
        );
      });
    }

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text("TAROT FALI"),
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.spaceDark,
                  AppTheme.deepNavy,
                  AppTheme.spaceDark,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Hata mesajı varsa üstte göster
                  if (state.errorMessage != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                        ),
                        child: Text(
                          state.errorMessage!,
                          style: GoogleFonts.lora(color: Colors.redAccent, fontSize: 13),
                          textAlign: Center,
                        ),
                      ),
                    ),
                  ],

                  // Niyet ve Kart Seçim Durumu Alanı
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Zihnini Odakla",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _questionController,
                          style: GoogleFonts.lora(color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: "Sorunu veya niyetini yaz (Aşk, İş, Sağlık...)",
                            hintStyle: GoogleFonts.lora(color: Colors.white30, fontSize: 13),
                            fillColor: AppTheme.deepNavy,
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppTheme.midnightBlue),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppTheme.gold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "3 Kart Seçin:",
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              "${state.selectedCards.length} / 3 Kart Seçildi",
                              style: GoogleFonts.cinzel(
                                color: state.selectedCards.length == 3 ? AppTheme.gold : AppTheme.goldLight.withOpacity(0.6),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Dijital Deste Alanı (Izgara Görünümü)
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.62, // Gerçek kart en-boy oranına yakın
                      ),
                      itemCount: _tarotDeck.length,
                      itemBuilder: (context, index) {
                        final card = _tarotDeck[index];
                        final cardName = card["name"] as String;
                        final cardImage = card["image"] as String;
                        final isSelected = state.selectedCards.contains(cardName);
                        final selectedIndex = state.selectedCards.indexOf(cardName);

                        return GestureDetector(
                          onTap: () {
                            ref.read(tarotProvider.notifier).toggleCard(cardName);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            decoration: BoxDecoration(
                              color: AppTheme.midnightBlue,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? AppTheme.gold : AppTheme.gold.withOpacity(0.15),
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppTheme.gold.withOpacity(0.4),
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                      )
                                    ]
                                  : [],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Kartın arka yüz deseni (Seçilmediyse gizemli desen)
                                  if (!isSelected) ...[
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.all_inclusive,
                                          color: AppTheme.gold.withOpacity(0.3),
                                          size: 28,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "KADER",
                                          style: GoogleFonts.cinzel(
                                            color: AppTheme.gold.withOpacity(0.2),
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ] else ...[
                                    // Seçilen Kart (Gerçek Rider-Waite Resmi)
                                    Image.network(
                                      cardImage,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            color: AppTheme.gold,
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded /
                                                    loadingProgress.expectedTotalBytes!
                                                : null,
                                          ),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        // Hata durumunda fallback
                                        return Container(
                                          color: AppTheme.deepNavy,
                                          padding: const EdgeInsets.all(8),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                card["symbol"] as String,
                                                style: const TextStyle(fontSize: 24),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                cardName.split(" (")[0],
                                                textAlign: Center,
                                                style: GoogleFonts.cinzel(
                                                  color: AppTheme.goldLight,
                                                  fontSize: 8,
                                               ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                    // Üstüne hafif koyu overlay ve yazı
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.black.withOpacity(0.0),
                                              Colors.black.withOpacity(0.85),
                                            ],
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              cardName.split(" (")[0],
                                              textAlign: Center,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.cinzel(
                                                color: AppTheme.goldLight,
                                                fontSize: 8,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              _getPositionLabel(selectedIndex),
                                              style: GoogleFonts.lora(
                                                color: AppTheme.gold,
                                                fontSize: 7,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                  // Sağ üstteki seçim sırası rozeti
                                  if (isSelected)
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: CircleAvatar(
                                        radius: 9,
                                        backgroundColor: AppTheme.gold,
                                        child: Text(
                                          "${selectedIndex + 1}",
                                          style: GoogleFonts.cinzel(
                                            color: AppTheme.spaceDark,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Alt Buton
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: state.selectedCards.length < 3
                            ? null
                            : () {
                                ref.read(tarotProvider.notifier).getReading(
                                      _questionController.text,
                                    );
                              },
                        child: const Text("KADER KARTLARINI AÇ"),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Yükleme Animasyonu Overlay
        if (state.isLoading)
          const MysticLoader(
            message: "Kartlar kutsanıyor, kaderin üç düzlemi (geçmiş, şimdiki zaman ve gelecek) yorumlanıyor...",
          ),
      ],
    );
  }

  // Seçim sırasına göre kartların anlamı (Geçmiş, Şimdiki Zaman, Gelecek)
  String _getPositionLabel(int index) {
    switch (index) {
      case 0:
        return "Geçmiş";
      case 1:
        return "Şimdiki Zaman";
      case 2:
        return "Gelecek";
      default:
        return "";
    }
  }

  // Sonuç ekranı üzerinde seçilen 3 kartı gösteren başlık widget'ı
  Widget _buildResultCardsHeader(List<String> selectedCards) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.deepNavy.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.midnightBlue, width: 1),
      ),
      child: Column(
        children: [
          Text(
            "SEÇTİĞİNİZ KADER KARTLARI",
            style: GoogleFonts.cinzel(
              color: AppTheme.gold,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: selectedCards.map((cardName) {
              final cardInfo = _tarotDeck.firstWhere((element) => element["name"] == cardName);
              final index = selectedCards.indexOf(cardName);
              return Container(
                width: 90,
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                decoration: BoxDecoration(
                  color: AppTheme.midnightBlue,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.gold.withOpacity(0.3), width: 1),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        cardInfo["image"] as String,
                        height: 90,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Text(
                          cardInfo["symbol"] as String,
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      cardName.split(" (")[0],
                      textAlign: Center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cinzel(
                        color: AppTheme.goldLight,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getPositionLabel(index),
                      style: GoogleFonts.lora(
                        color: AppTheme.gold.withOpacity(0.6),
                        fontSize: 8,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
