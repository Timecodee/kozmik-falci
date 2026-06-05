import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/mystic_loader.dart';
import '../../shared/presentation/result_screen.dart';
import 'providers/iskambil_provider.dart';

class IskambilScreen extends ConsumerStatefulWidget {
  const IskambilScreen({super.key});

  @override
  ConsumerState<IskambilScreen> createState() => _IskambilScreenState();
}

class _IskambilScreenState extends ConsumerState<IskambilScreen> {
  final TextEditingController _questionController = TextEditingController();
  final List<Map<String, dynamic>> _deck = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initializeDeck();
  }

  void _initializeDeck() {
    final suits = [
      {'name': 'Kupa', 'symbol': '♥', 'color': Colors.redAccent},
      {'name': 'Karo', 'symbol': '♦', 'color': Colors.redAccent},
      {'name': 'Sinek', 'symbol': '♣', 'color': Colors.amber},
      {'name': 'Maça', 'symbol': '♠', 'color': Colors.blueGrey},
    ];
    final values = [
      'As', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'Vale', 'Kız', 'Papaz'
    ];

    for (final suit in suits) {
      for (final val in values) {
        _deck.add({
          'name': '${suit['name']} $val',
          'symbol': suit['symbol'],
          'color': suit['color'],
          'suitName': suit['name'],
          'value': val,
        });
      }
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  void _drawCard() {
    final state = ref.read(iskambilProvider);
    if (state.selectedCards.length >= 3) return;

    // Kalan kartlardan rastgele bir tane çekelim
    final availableCards = _deck
        .where((c) => !state.selectedCards.contains(c['name']))
        .toList();

    if (availableCards.isNotEmpty) {
      final randomCard = availableCards[_random.nextInt(availableCards.length)];
      ref.read(iskambilProvider.notifier).toggleCard(randomCard['name']);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(iskambilProvider);

    // Sonuç ekranına yönlendirme
    if (state.readingResult != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final result = state.readingResult!;
        ref.read(iskambilProvider.notifier).reset();
        _questionController.clear();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              title: "İSKAMBİL FALI YORUMU",
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
            title: const Text("İSKAMBİL FALI"),
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
                      "Niyetiniz veya Sorunuz",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _questionController,
                      style: GoogleFonts.lora(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Sorunu veya niyetini yaz (Aşk, İş, Sağlık...)",
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
                      "Kader Kartlarını Çek",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Geçmiş, Şimdi ve Gelecek konumları için 3 adet kart seçin.",
                      style: GoogleFonts.lora(
                        color: AppTheme.goldLight.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Kart Çekme Alanı (Ters Deste)
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
                                        Icons.style,
                                        color: AppTheme.gold,
                                        size: 44,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "KART ÇEK",
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
                                    "Deste Kilitlendi",
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
                      "Seçilen Kartlar",
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
                          cardData = _deck.firstWhere((c) => c['name'] == cardName);
                        }

                        final labels = ["Geçmiş", "Şimdi", "Gelecek"];

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
                                        // Kart Sembolü
                                        Center(
                                          child: Text(
                                            cardData['symbol'],
                                            style: TextStyle(
                                              color: cardData['color'].withOpacity(0.15),
                                              fontSize: 64,
                                            ),
                                          ),
                                        ),
                                        // Sol Üst Değer
                                        Positioned(
                                          top: 8,
                                          left: 8,
                                          child: Column(
                                            children: [
                                              Text(
                                                cardData['value'],
                                                style: GoogleFonts.cinzel(
                                                  color: cardData['color'],
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                cardData['symbol'],
                                                style: TextStyle(
                                                  color: cardData['color'],
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Sağ Alt Değer
                                        Positioned(
                                          bottom: 8,
                                          right: 8,
                                          child: RotatedBox(
                                            quarterTurns: 2,
                                            child: Column(
                                              children: [
                                                Text(
                                                  cardData['value'],
                                                  style: GoogleFonts.cinzel(
                                                    color: cardData['color'],
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  cardData['symbol'],
                                                  style: TextStyle(
                                                    color: cardData['color'],
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        // Kartı Temizleme Butonu
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: GestureDetector(
                                            onTap: () {
                                              ref.read(iskambilProvider.notifier).toggleCard(cardName);
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
                                        "✦",
                                        style: TextStyle(
                                          color: AppTheme.gold.withOpacity(0.2),
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
                                fontSize: 11,
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
                                ref.read(iskambilProvider.notifier).getReading(
                                      _questionController.text,
                                    );
                              }
                            : null,
                        child: const Text("KADER KARTLARINI AÇ"),
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
            message: "Kartlar karıştırılıyor, İskambil ilmiyle kader kapıları aralanıyor...",
          ),
      ],
    );
  }
}
