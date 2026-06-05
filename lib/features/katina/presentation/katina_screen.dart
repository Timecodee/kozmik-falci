import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/mystic_loader.dart';
import '../../shared/presentation/result_screen.dart';
import 'providers/katina_provider.dart';

class KatinaScreen extends ConsumerStatefulWidget {
  const KatinaScreen({super.key});

  @override
  ConsumerState<KatinaScreen> createState() => _KatinaScreenState();
}

class _KatinaScreenState extends ConsumerState<KatinaScreen> {
  final TextEditingController _questionController = TextEditingController();
  final List<Map<String, dynamic>> _katinaDeck = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initializeKatinaDeck();
  }

  void _initializeKatinaDeck() {
    _katinaDeck.addAll([
      {'name': 'Deste (Kader Kartı)', 'symbol': '✨', 'desc': 'Kader ve büyük değişimlerin fısıltısı.', 'color': AppTheme.gold},
      {'name': 'Valide (Saraylı Kadın)', 'symbol': '👑', 'desc': 'İlişkideki olgun, koruyucu dişil enerji.', 'color': Colors.purpleAccent},
      {'name': 'Zara - Beyaz At (Aşk Kartı)', 'symbol': '🦄', 'desc': 'Saf sevgi, temiz niyet ve kavuşma müjdesi.', 'color': Colors.pinkAccent},
      {'name': 'Turan (Toprak Elementi)', 'symbol': '🌱', 'desc': 'Kökleşme, güven ve ilişkinin sağlam temelleri.', 'color': Colors.greenAccent},
      {'name': 'Selena (Ay Kartı)', 'symbol': '🌙', 'desc': 'Bilinçaltı korkuları, sırlar ve gizemli duygular.', 'color': Colors.lightBlueAccent},
      {'name': 'Mida (Yılan Kartı)', 'symbol': '🐍', 'desc': 'Kıskançlık, arkadan dönen işler veya uyarılar.', 'color': Colors.redAccent},
      {'name': 'Attart (Aşk Tanrıçası)', 'symbol': '🌹', 'desc': 'Yoğun tutku, cazibe ve karşı konulamaz sevgi.', 'color': Colors.pink},
      {'name': 'Ustrina (Güneş Kartı)', 'symbol': '☀️', 'desc': 'Aydınlanma, mutluluk ve tüm karanlığın dağılması.', 'color': Colors.orangeAccent},
      {'name': 'Hakan (Hükümdar Kartı)', 'symbol': '🛡️', 'desc': 'Kararlılık, sahiplenme ve eril gücün koruması.', 'color': Colors.blueAccent},
      {'name': 'Smaragda (Zümrüt Kartı)', 'symbol': '💎', 'desc': 'Sadakat, dürüstlük ve değerli manevi bağlar.', 'color': Colors.tealAccent},
      {'name': 'Süleyman (Bilge Kartı)', 'symbol': '📜', 'desc': 'Akıl, mantık, zamana yayılmış doğru kararlar.', 'color': Colors.amberAccent},
      {'name': 'Elmas (Maddi Güç Kartı)', 'symbol': '💰', 'desc': 'Zenginlik, refah ve ilişkinin maddi konforu.', 'color': Colors.yellowAccent},
      {'name': 'Yakut (Ateş Elementi)', 'symbol': '🔥', 'desc': 'Heyecan, kıvılcım ve anlık büyük değişimler.', 'color': Colors.deepOrangeAccent},
      {'name': 'Safir (Hava Elementi)', 'symbol': '💨', 'desc': 'İletişim, haberleşme ve zihinsel uyuşma.', 'color': Colors.cyanAccent},
      {'name': 'Amiral (Lider Kartı)', 'symbol': '⛵', 'desc': 'İlişkinin yönünü çizen, yol gösteren güçlü figür.', 'color': Colors.indigoAccent},
    ]);
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  void _drawCard() {
    final state = ref.read(katinaProvider);
    if (state.selectedCards.length >= 3) return;

    final availableCards = _katinaDeck
        .where((c) => !state.selectedCards.contains(c['name']))
        .toList();

    if (availableCards.isNotEmpty) {
      final randomCard = availableCards[_random.nextInt(availableCards.length)];
      ref.read(katinaProvider.notifier).toggleCard(randomCard['name']);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(katinaProvider);

    // Navigate to results
    if (state.readingResult != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final result = state.readingResult!;
        ref.read(katinaProvider.notifier).reset();
        _questionController.clear();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              title: "KATINA AŞK FALI YORUMU",
              resultText: result,
            ),
          ),
        );
      });
    }

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text("KATINA AŞK FALI"),
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
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state.errorMessage != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                        ),
                        child: Text(
                          state.errorMessage!,
                          style: GoogleFonts.lora(color: Colors.redAccent, fontSize: 14),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    Text(
                      "Aşk Niyetiniz veya İlişki Sorunuz",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _questionController,
                      style: GoogleFonts.lora(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Sorunu veya niyetini yaz (Aşk hayatım, X kişisi ile geleceğimiz...)",
                        hintStyle: GoogleFonts.lora(color: Colors.white30, fontSize: 14),
                        fillColor: AppTheme.deepNavy,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppTheme.midnightBlue, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppTheme.gold, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    Text(
                      "Katina Deste Kartlarını Çek",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "İlişkinizin geçmişi, şimdisi ve gelecekteki aşk potansiyeli için 3 kart seçin.",
                      style: GoogleFonts.lora(
                        color: AppTheme.goldLight.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Ters Deste
                    Center(
                      child: GestureDetector(
                        onTap: state.selectedCards.length < 3 ? _drawCard : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 130,
                          height: 200,
                          decoration: BoxDecoration(
                            color: state.selectedCards.length < 3
                                ? AppTheme.midnightBlue
                                : AppTheme.deepNavy.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: state.selectedCards.length < 3
                                  ? AppTheme.gold
                                  : AppTheme.midnightBlue,
                              width: 2,
                            ),
                            boxShadow: state.selectedCards.length < 3
                                ? [
                                    BoxShadow(
                                      color: AppTheme.gold.withOpacity(0.15),
                                      blurRadius: 15,
                                      spreadRadius: 2,
                                    )
                                  ]
                                : [],
                          ),
                          child: Center(
                            child: state.selectedCards.length < 3
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.favorite_border,
                                        color: AppTheme.gold,
                                        size: 44,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "AŞK KARTI ÇEK",
                                        style: GoogleFonts.cinzel(
                                          color: AppTheme.gold,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        "(${state.selectedCards.length} / 3)",
                                        style: GoogleFonts.lora(
                                          color: AppTheme.goldLight.withOpacity(0.7),
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  )
                                : Text(
                                    "Aşk Destesi Kilitlendi",
                                    style: GoogleFonts.lora(
                                      color: Colors.white24,
                                      fontSize: 12,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Çekilen Kartların Listesi
                    Text(
                      "Seçilen Aşk Kartları",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(3, (index) {
                        final isDrawn = state.selectedCards.length > index;
                        String cardName = "";
                        Map<String, dynamic>? cardData;

                        if (isDrawn) {
                          cardName = state.selectedCards[index];
                          cardData = _katinaDeck.firstWhere((c) => c['name'] == cardName);
                        }

                        final labels = ["Geçmiş Bağ", "Şimdiki Durum", "Gelecek Potansiyeli"];

                        return Column(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              width: 90,
                              height: 140,
                              decoration: BoxDecoration(
                                color: isDrawn ? AppTheme.deepNavy : AppTheme.spaceDark,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDrawn ? AppTheme.gold : AppTheme.midnightBlue,
                                  width: 1.5,
                                ),
                                boxShadow: isDrawn
                                    ? [
                                        BoxShadow(
                                          color: AppTheme.gold.withOpacity(0.05),
                                          blurRadius: 8,
                                        )
                                      ]
                                    : [],
                              ),
                              child: isDrawn && cardData != null
                                  ? Stack(
                                      children: [
                                        // Büyük Mistik Sembol
                                        Center(
                                          child: Text(
                                            cardData['symbol'],
                                            style: const TextStyle(
                                              fontSize: 36,
                                            ),
                                          ),
                                        ),
                                        // Kart Başlığı (Alt Kısımda)
                                        Positioned(
                                          bottom: 8,
                                          left: 4,
                                          right: 4,
                                          child: Text(
                                            cardData['name'].split(" (")[0],
                                            style: GoogleFonts.cinzel(
                                              color: cardData['color'],
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        // Kartı Temizleme Butonu
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: GestureDetector(
                                            onTap: () {
                                              ref.read(katinaProvider.notifier).toggleCard(cardName);
                                            },
                                            child: const CircleAvatar(
                                              radius: 10,
                                              backgroundColor: Colors.redAccent,
                                              child: Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 10,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Center(
                                      child: Text(
                                        "❤",
                                        style: TextStyle(
                                          color: Colors.pink.withOpacity(0.15),
                                          fontSize: 24,
                                        ),
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              labels[index],
                              style: GoogleFonts.cinzel(
                                color: isDrawn ? AppTheme.gold : Colors.white30,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        );
                      }),
                    ),

                    const SizedBox(height: 48),

                    // Yorumla Butonu
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: state.selectedCards.length == 3
                            ? () {
                                ref.read(katinaProvider.notifier).getReading(
                                      _questionController.text,
                                    );
                              }
                            : null,
                        child: const Text("AŞK KADERİNİ AÇ"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (state.isLoading)
          const MysticLoader(
            message: "Katina destesi sırlanıyor, aşkınızın gelecekteki yolları aydınlanıyor...",
          ),
      ],
    );
  }
}
