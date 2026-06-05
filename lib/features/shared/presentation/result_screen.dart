import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/ad_service.dart';

class ResultScreen extends StatefulWidget {
  final String title;
  final String resultText;
  final Widget? topWidget;

  const ResultScreen({
    super.key,
    required this.title,
    required this.resultText,
    this.topWidget,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _isUnlocked = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkUnlockStatus();
  }

  Future<void> _checkUnlockStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final count = prefs.getInt('fortunes_looked_count') ?? 0;
      
      if (count < 3) {
        // Free fortune! Increment count and unlock.
        await prefs.setInt('fortunes_looked_count', count + 1);
        setState(() {
          _isUnlocked = true;
          _isLoading = false;
        });
      } else {
        // Exceeded free limit, must watch ad.
        setState(() {
          _isUnlocked = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Fallback on error
      setState(() {
        _isUnlocked = true;
        _isLoading = false;
      });
    }
  }

  void _watchAdToUnlock() {
    AdService.showRewardedAd(
      context: context,
      onRewardEarned: () async {
        try {
          final prefs = await SharedPreferences.getInstance();
          final count = prefs.getInt('fortunes_looked_count') ?? 3;
          await prefs.setInt('fortunes_looked_count', count + 1);
        } catch (_) {}
        
        setState(() {
          _isUnlocked = true;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                if (widget.topWidget != null) ...[
                  widget.topWidget!,
                  const SizedBox(height: 20),
                ],
                // Mistik Sonuç Kartı
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: AppTheme.deepNavy.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppTheme.gold.withOpacity(0.5), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.gold.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(color: AppTheme.gold),
                          )
                        : _isUnlocked
                            ? _buildUnlockedContent()
                            : _buildLockedOverlay(),
                  ),
                ),
                const SizedBox(height: 24),
                // Geri Dön Butonu
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("KADERİNE GERİ DÖN"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUnlockedContent() {
    return Column(
      children: [
        // Süsleme İkonu
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star, color: AppTheme.gold, size: 12),
            SizedBox(width: 8),
            Icon(Icons.brightness_3, color: AppTheme.gold, size: 18),
            SizedBox(width: 8),
            Icon(Icons.star, color: AppTheme.gold, size: 12),
          ],
        ),
        const SizedBox(height: 16),
        // Kaydırılabilir Fal Metni
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                widget.resultText,
                style: GoogleFonts.lora(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.7,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Alt Süsleme Çizgisi
        Container(
          height: 1,
          width: 100,
          color: AppTheme.gold.withOpacity(0.3),
        ),
      ],
    );
  }

  Widget _buildLockedOverlay() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.gold.withOpacity(0.1),
            border: Border.all(color: AppTheme.gold.withOpacity(0.3), width: 1.5),
          ),
          child: const Icon(
            Icons.lock_outline,
            color: AppTheme.gold,
            size: 48,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          "KADERİNİZİN SIRLARI KİLİTLİ",
          style: GoogleFonts.cinzel(
            color: AppTheme.gold,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          "Kaderinizin fısıltılarını dinlemek için bilge falcıya destek olun (reklam izleyin) ve kehaneti kilidini açın.",
          style: GoogleFonts.lora(
            color: Colors.white70,
            fontSize: 13,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: 200,
          height: 50,
          child: ElevatedButton(
            onPressed: _watchAdToUnlock,
            style: ElevatedButton.styleFrom(
              side: const BorderSide(color: AppTheme.gold, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.play_circle_fill, color: AppTheme.gold, size: 20),
                SizedBox(width: 8),
                Text("REKLAM İZLE"),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
