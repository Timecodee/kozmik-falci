import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/mystic_loader.dart';
import '../../shared/presentation/result_screen.dart';
import 'providers/beans_provider.dart';

class BeansScreen extends ConsumerStatefulWidget {
  const BeansScreen({super.key});

  @override
  ConsumerState<BeansScreen> createState() => _BeansScreenState();
}

class _BeansScreenState extends ConsumerState<BeansScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _intentionController = TextEditingController();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _intentionController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleCastBeans() {
    ref.read(beansProvider.notifier).castBeans();
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(beansProvider);

    // Navigate to results
    if (state.readingResult != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final result = state.readingResult!;
        ref.read(beansProvider.notifier).reset();
        _intentionController.clear();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              title: "BAKLA VE NOHUT FALI YORUMU",
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
            title: const Text("BAKLA FALI"),
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
                      "Fal Niyeti",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _intentionController,
                      maxLines: 3,
                      style: GoogleFonts.lora(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Zihnini boşalt, niyetini buraya yaz ve kader baklalarını savur...",
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
                      "Kader Düzlemi",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Baklaları döktüğünüzde, düzlemdeki saçılış şekilleri niyetinizi belirleyecektir.",
                      style: GoogleFonts.lora(
                        color: AppTheme.goldLight.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Bakla Saçılma Board'u
                    Center(
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          color: AppTheme.deepNavy.withOpacity(0.6),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.gold.withOpacity(0.4),
                            width: 2.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.gold.withOpacity(0.04),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Stack(
                            children: [
                              // Mistik Kadran Çizgileri
                              Center(
                                child: Container(
                                  width: 280,
                                  height: 280,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppTheme.midnightBlue.withOpacity(0.4),
                                      width: 1.0,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Center(
                                child: Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppTheme.midnightBlue.withOpacity(0.3),
                                      width: 1.0,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),

                              // Baklaların Yerleşimi
                              if (state.beanPositions.isNotEmpty)
                                ...state.beanPositions.map((pos) {
                                  return AnimatedBuilder(
                                    animation: _animationController,
                                    builder: (context, child) {
                                      // Merkezden (0.5, 0.5) başlayıp rastgele konuma doğru kayma animasyonu
                                      final double t = CurvedAnimation(
                                        parent: _animationController,
                                        curve: Curves.easeOutBack,
                                      ).value;

                                      final double currentX = 0.5 + (pos.x - 0.5) * t;
                                      final double currentY = 0.5 + (pos.y - 0.5) * t;

                                      return Positioned(
                                        left: currentX * 280 + 10 - 10, // 280px genişlik + margin ayarlamaları
                                        top: currentY * 280 + 10 - 10,
                                        child: Transform.rotate(
                                          angle: pos.rotation * t,
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: 20,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFC29B38),
                                        borderRadius: BorderRadius.circular(6),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.5),
                                            blurRadius: 2,
                                            offset: const Offset(1, 2),
                                          )
                                        ],
                                        border: Border.all(
                                          color: const Color(0xFF85651B),
                                          width: 1.0,
                                        ),
                                      ),
                                      child: Center(
                                        child: Container(
                                          width: 12,
                                          height: 2,
                                          color: const Color(0xFFE5C158).withOpacity(0.4),
                                        ),
                                      ),
                                    ),
                                  );
                                }),

                              if (state.beanPositions.isEmpty)
                                Center(
                                  child: Text(
                                    "Kader Düzlemi Boş\n\nBaklaları Saçmak İçin\nButona Dokunun",
                                    style: GoogleFonts.cinzel(
                                      color: AppTheme.goldLight.withOpacity(0.3),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Baklaları Dök Butonu
                    Center(
                      child: SizedBox(
                        width: 180,
                        height: 48,
                        child: OutlinedButton(
                          onPressed: _handleCastBeans,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.gold),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Text(
                            state.beanPositions.isEmpty ? "BAKLALARI DÖK" : "YENİDEN SAVUR",
                            style: GoogleFonts.cinzel(
                              color: AppTheme.gold,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Yorumla Butonu
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: state.beanPositions.isNotEmpty
                            ? () {
                                ref.read(beansProvider.notifier).getReading(
                                      _intentionController.text,
                                    );
                              }
                            : null,
                        child: const Text("BAKLALARI YORUMLA"),
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
            message: "Savrulan baklalar okunuyor, yerin ve göğün fısıltısı niyetinizle birleşiyor...",
          ),
      ],
    );
  }
}
