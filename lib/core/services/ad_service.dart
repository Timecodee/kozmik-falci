import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class AdService {
  static const String bannerUnitId = 'ca-app-pub-9911718263708562/2574148863';
  static const String rewardedUnitId = 'ca-app-pub-9911718263708562/4601016174';

  static bool _isInitialized = false;

  static Future<void> init() async {
    if (kIsWeb) return;
    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      debugPrint("AdMob Mobile Ads SDK Initialized.");
    } catch (e) {
      debugPrint("Error initializing Mobile Ads SDK: $e");
    }
  }

  // Shows rewarded ad. If on Web or ad fails, falls back to a simulated ad.
  static void showRewardedAd({
    required BuildContext context,
    required VoidCallback onRewardEarned,
  }) {
    if (kIsWeb) {
      _showSimulatedRewardedAd(context, onRewardEarned);
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppTheme.gold),
      ),
    );

    RewardedAd.load(
      adUnitId: rewardedUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          Navigator.pop(context); // remove loading dialog
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _showSimulatedRewardedAd(context, onRewardEarned);
            },
          );
          ad.show(
            onUserEarnedReward: (adWithoutReward, reward) {
              onRewardEarned();
            },
          );
        },
        onAdFailedToLoad: (err) {
          Navigator.pop(context); // remove loading dialog
          debugPrint("Rewarded ad failed to load: ${err.message}. Showing simulated ad fallback.");
          _showSimulatedRewardedAd(context, onRewardEarned);
        },
      ),
    );
  }

  // Simulated ad countdown dialog for Web or AdMob error fallback
  static void _showSimulatedRewardedAd(BuildContext context, VoidCallback onComplete) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _SimulatedAdDialog(onComplete: onComplete),
    );
  }
}

class _SimulatedAdDialog extends StatefulWidget {
  final VoidCallback onComplete;
  const _SimulatedAdDialog({required this.onComplete});

  @override
  State<_SimulatedAdDialog> createState() => _SimulatedAdDialogState();
}

class _SimulatedAdDialogState extends State<_SimulatedAdDialog> {
  int _secondsLeft = 5;
  double _progress = 1.0;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        _secondsLeft--;
        _progress = _secondsLeft / 5.0;
      });
      if (_secondsLeft <= 0) {
        Navigator.pop(context); // Close dialog
        widget.onComplete();
        return false;
      }
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Non-dismissible
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.deepNavy,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.gold, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppTheme.gold.withOpacity(0.15),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.auto_awesome,
                color: AppTheme.gold,
                size: 50,
              ),
              const SizedBox(height: 16),
              Text(
                "MİSTİK SPONSORLU İÇERİK",
                style: GoogleFonts.cinzel(
                  color: AppTheme.gold,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Falınız hazırlanırken bilge falcıya destek olmak için lütfen bu kısa yayını izleyin.",
                style: GoogleFonts.lora(
                  color: Colors.white70,
                  fontSize: 12,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Progress Bar
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 8,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _progress,
                        backgroundColor: AppTheme.midnightBlue,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.gold),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                "Kehanetin kapıları açılıyor: $_secondsLeft sn.",
                style: GoogleFonts.lora(
                  color: AppTheme.goldLight,
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Banner Widget that displays AdMob Banner or Simulated Ad Container
class MistikBannerAdWidget extends StatefulWidget {
  const MistikBannerAdWidget({super.key});

  @override
  State<MistikBannerAdWidget> createState() => _MistikBannerAdWidgetState();
}

class _MistikBannerAdWidgetState extends State<MistikBannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _loadBanner();
    }
  }

  void _loadBanner() {
    _bannerAd = BannerAd(
      adUnitId: AdService.bannerUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint("Banner ad failed to load: ${error.message}");
          ad.dispose();
        },
      ),
    );
    _bannerAd!.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return _buildMockBanner();
    }

    if (_isLoaded && _bannerAd != null) {
      return SafeArea(
        child: Container(
          alignment: Alignment.center,
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          color: AppTheme.spaceDark,
          child: AdWidget(ad: _bannerAd!),
        ),
      );
    }

    // Default container during loading or failure
    return _buildMockBanner();
  }

  Widget _buildMockBanner() {
    return Container(
      width: double.infinity,
      height: 50,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: AppTheme.deepNavy,
        border: Border(
          top: BorderSide(color: AppTheme.midnightBlue, width: 1.2),
          bottom: BorderSide(color: AppTheme.midnightBlue, width: 1.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.auto_awesome,
            color: AppTheme.gold,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            "MİSTİK SPONSORLU REKLAM",
            style: GoogleFonts.cinzel(
              color: AppTheme.gold,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.auto_awesome,
            color: AppTheme.gold,
            size: 16,
          ),
        ],
      ),
    );
  }
}
