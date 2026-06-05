import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/ad_service.dart';
import '../../coffee/presentation/coffee_screen.dart';
import '../../tarot/presentation/tarot_screen.dart';
import '../../eye/presentation/eye_screen.dart';
import '../../palm/presentation/palm_screen.dart';
import '../../iskambil/presentation/iskambil_screen.dart';
import '../../yildizname/presentation/yildizname_screen.dart';
import '../../katina/presentation/katina_screen.dart';
import '../../beans/presentation/beans_screen.dart';
import '../../sphere/presentation/sphere_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 12),
                // Üst Mistik Logo
                Container(
                  padding: const EdgeInsets.all(8),
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
                    size: 36,
                  ),
                ),
                const SizedBox(height: 12),
                // Başlık
                Text(
                  "MİSTİK FALCI",
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 26,
                    letterSpacing: 2.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  "Kaderinizin Sırlarını Keşfedin",
                  style: GoogleFonts.lora(
                    color: AppTheme.goldLight.withOpacity(0.7),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // Grid/Liste Görünümü
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.88,
                          children: [
                            MistikMenuCard(
                              title: "KAHVE FALI",
                              subtitle: "Fincan telvelerinin fısıltısı.",
                              icon: Icons.coffee,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const CoffeeScreen()),
                                );
                              },
                            ),
                            MistikMenuCard(
                              title: "TAROT FALI",
                              subtitle: "Gizemli kartlar ile gelecek.",
                              icon: Icons.style,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const TarotScreen()),
                                );
                              },
                            ),
                            MistikMenuCard(
                              title: "GÖZ FALI",
                              subtitle: "Bakışların saklı enerjisi.",
                              icon: Icons.visibility,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const EyeScreen()),
                                );
                              },
                            ),
                            MistikMenuCard(
                              title: "EL FALI",
                              subtitle: "Avuç içi çizgilerinin anlamı.",
                              icon: Icons.front_hand,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const PalmScreen()),
                                );
                              },
                            ),
                            MistikMenuCard(
                              title: "İSKAMBİL FALI",
                              subtitle: "Oyun kartları ile kehanet.",
                              icon: Icons.view_carousel,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const IskambilScreen()),
                                );
                              },
                            ),
                            MistikMenuCard(
                              title: "YILDIZNAME",
                              subtitle: "Yıldız haritası ve karakter.",
                              icon: Icons.brightness_5,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const YildiznameScreen()),
                                );
                              },
                            ),
                            MistikMenuCard(
                              title: "KATINA FALI",
                              subtitle: "Aşk ve ilişkilerin falı.",
                              icon: Icons.favorite,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const KatinaScreen()),
                                );
                              },
                            ),
                            MistikMenuCard(
                              title: "BAKLA FALI",
                              subtitle: "Geleneksel nohut ve bakla.",
                              icon: Icons.scatter_plot,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const BeansScreen()),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Küre Falı (En Altta Tam Genişlikte Özel Kart)
                        MistikMenuCard(
                          title: "KÜRE FALI",
                          subtitle: "Kristal küreye odaklan ve bilge kehaneti dinle.",
                          icon: Icons.lens_blur,
                          isFullWidth: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SphereScreen()),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "© 2026 Mistik Falcı - Tüm Hakları Saklıdır",
                  style: GoogleFonts.lora(
                    color: Colors.white24,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 4),
                const MistikBannerAdWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MistikMenuCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool isFullWidth;

  const MistikMenuCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.isFullWidth = false,
  });

  @override
  State<MistikMenuCard> createState() => _MistikMenuCardState();
}

class _MistikMenuCardState extends State<MistikMenuCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _isHovered ? AppTheme.gold : AppTheme.midnightBlue;
    final shadowColor = _isHovered ? AppTheme.gold.withOpacity(0.15) : AppTheme.gold.withOpacity(0.04);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.deepNavy,
                  AppTheme.spaceDark.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: borderColor,
                width: _isHovered ? 1.5 : 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: _isHovered ? 15 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: widget.isFullWidth
                ? Row(
                    children: [
                      _buildIconContainer(),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildTitle(),
                            const SizedBox(height: 4),
                            _buildSubtitle(textAlign: TextAlign.start),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: AppTheme.goldLight,
                        size: 20,
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildIconContainer(),
                      const SizedBox(height: 12),
                      _buildTitle(),
                      const SizedBox(height: 6),
                      _buildSubtitle(textAlign: TextAlign.center),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconContainer() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppTheme.midnightBlue,
            AppTheme.spaceDark.withOpacity(0.5),
          ],
        ),
        border: Border.all(
          color: _isHovered ? AppTheme.gold : AppTheme.gold.withOpacity(0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.gold.withOpacity(_isHovered ? 0.2 : 0.08),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(
        widget.icon,
        color: AppTheme.gold,
        size: widget.isFullWidth ? 26 : 28,
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      widget.title,
      style: GoogleFonts.cinzel(
        color: AppTheme.gold,
        fontSize: widget.isFullWidth ? 15 : 13,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.0,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitle({required TextAlign textAlign}) {
    return Text(
      widget.subtitle,
      style: GoogleFonts.lora(
        color: Colors.white70,
        fontSize: 10,
        height: 1.3,
      ),
      textAlign: textAlign,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
