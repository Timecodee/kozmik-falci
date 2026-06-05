import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/services/ai_service.dart';
import 'core/services/ad_service.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // AdMob'u başlat
  await AdService.init();

  // .env dosyasını yükle
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Hata: .env dosyası yüklenemedi: $e");
  }
  
  // API Anahtarlarını Uzaktan Yükle
  AiService.initApiKeys();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mistik Falcı',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child,

            // Yükleme Ekranı (API Anahtarları Alınırken)
            ValueListenableBuilder<bool>(
              valueListenable: AiService.isLoadingKeys,
              builder: (context, isLoading, _) {
                if (!isLoading) return const SizedBox.shrink();
                return Material(
                  color: AppTheme.spaceDark,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.gold.withOpacity(0.2),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: AppTheme.gold,
                            size: 48,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.gold),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Mistik güçler uyandırılıyor...",
                          style: GoogleFonts.lora(
                            color: AppTheme.goldLight,
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Blocker Overlay (Tüm API Anahtarları Tükendiğinde)
            ValueListenableBuilder<bool>(
              valueListenable: AiService.allKeysExhausted,
              builder: (context, isExhausted, _) {
                if (!isExhausted) return const SizedBox.shrink();
                return WillPopScope(
                  onWillPop: () async => false, // Geri tuşuyla çıkışı engelle
                  child: Material(
                    color: Colors.black.withOpacity(0.96),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.redAccent.withOpacity(0.15),
                                border: Border.all(color: Colors.redAccent.withOpacity(0.5), width: 1.5),
                              ),
                              child: const Icon(
                                Icons.error_outline,
                                color: Colors.redAccent,
                                size: 56,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              "Üzgünüz",
                              style: GoogleFonts.cinzel(
                                color: AppTheme.gold,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Bütün falcılar şu an dolu.\nLütfen daha sonra tekrar deneyiniz.",
                              style: GoogleFonts.lora(
                                color: Colors.white70,
                                fontSize: 15,
                                fontStyle: FontStyle.italic,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
