import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class MysticLoader extends StatelessWidget {
  final String message;

  const MysticLoader({
    super.key,
    this.message = "Yıldızlar hizalanıyor, kaderin fısıltısı hazırlanıyor...",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.spaceDark.withOpacity(0.95),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mistik parıldayan SpinKit animasyonu
            Stack(
              alignment: Alignment.center,
              children: [
                SpinKitDoubleBounce(
                  color: AppTheme.gold.withOpacity(0.3),
                  size: 140,
                ),
                SpinKitRipple(
                  color: AppTheme.gold,
                  size: 100,
                ),
                Icon(
                  Icons.auto_awesome,
                  color: AppTheme.goldLight,
                  size: 40,
                ),
              ],
            ),
            const SizedBox(height: 40),
            // Mistik Mesaj
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Text(
                message,
                textAlign: Center,
                style: GoogleFonts.cinzel(
                  color: AppTheme.goldLight,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.2,
                  height: 1.6,
                  shadows: [
                    Shadow(
                      color: AppTheme.gold.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Lütfen ayrılmayın...",
              style: GoogleFonts.lora(
                color: Colors.white38,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
