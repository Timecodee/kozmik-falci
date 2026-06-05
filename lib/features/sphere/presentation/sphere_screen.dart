import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/mystic_loader.dart';
import '../../shared/presentation/result_screen.dart';
import 'providers/sphere_provider.dart';

class SphereScreen extends ConsumerStatefulWidget {
  const SphereScreen({super.key});

  @override
  ConsumerState<SphereScreen> createState() => _SphereScreenState();
}

class _SphereScreenState extends ConsumerState<SphereScreen> with TickerProviderStateMixin {
  final TextEditingController _questionController = TextEditingController();
  final List<SphereParticle> _particles = [];
  final Random _random = Random();
  
  Timer? _tickTimer;
  double _holdProgress = 0.0; // 0.0 to 1.0 (7 seconds total)
  bool _isHolding = false;
  bool _isCompleted = false;
  
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _questionController.dispose();
    _tickTimer?.cancel();
    _glowController.dispose();
    super.dispose();
  }

  void _startHolding() {
    if (_isCompleted) return;
    setState(() {
      _isHolding = true;
    });

    _tickTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      setState(() {
        // Increment progress
        _holdProgress += 30 / 7000; // 7000ms total
        if (_holdProgress >= 1.0) {
          _holdProgress = 1.0;
          _isCompleted = true;
          _isHolding = false;
          _tickTimer?.cancel();
        }

        // Add particles
        if (_isHolding) {
          for (int i = 0; i < 3; i++) {
            final double angle = _random.nextDouble() * 2 * pi;
            final double speed = 1.0 + _random.nextDouble() * 3.0;
            _particles.add(SphereParticle(
              x: 0,
              y: 0,
              vx: cos(angle) * speed,
              vy: sin(angle) * speed,
              size: 2.0 + _random.nextDouble() * 5.0,
              alpha: 1.0,
              color: _random.nextBool() ? AppTheme.gold : Colors.purpleAccent,
            ));
          }
        }

        // Update existing particles
        for (int i = _particles.length - 1; i >= 0; i--) {
          final p = _particles[i];
          p.x += p.vx;
          p.y += p.vy;
          p.alpha -= 0.025;
          if (p.alpha <= 0) {
            _particles.removeAt(i);
          }
        }
      });
    });
  }

  void _stopHolding() {
    if (_isCompleted) return;
    _tickTimer?.cancel();
    setState(() {
      _isHolding = false;
      _holdProgress = 0.0;
      _particles.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sphereProvider);

    // Navigate to results
    if (state.readingResult != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final result = state.readingResult!;
        ref.read(sphereProvider.notifier).reset();
        _questionController.clear();
        setState(() {
          _isCompleted = false;
          _holdProgress = 0.0;
          _particles.clear();
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              title: "🔮 KRİSTAL KÜRE YORUMU",
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
            title: const Text("KÜRE FALI"),
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
                      "Kristal Küre Odaklanması",
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Sorunuzu küreye aktarmak için parmağınızı 7 saniye boyunca kürenin üzerinde tutun. Sisler dağılana kadar bırakmayın.",
                      style: GoogleFonts.lora(
                        color: AppTheme.goldLight.withOpacity(0.6),
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // Küre ve Particle Alanı
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Particles Canvas
                          if (_particles.isNotEmpty)
                            CustomPaint(
                              size: const Size(300, 300),
                              painter: SphereParticlePainter(particles: _particles),
                            ),

                          // Kürenin Dış Glow Efekti
                          AnimatedBuilder(
                            animation: _glowController,
                            builder: (context, child) {
                              double glowFactor = _glowController.value * 15;
                              if (_isHolding) glowFactor += _holdProgress * 25;
                              return Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: _isCompleted 
                                          ? AppTheme.gold.withOpacity(0.6) 
                                          : Colors.purpleAccent.withOpacity(0.4),
                                      blurRadius: 20 + glowFactor,
                                      spreadRadius: 2 + (_holdProgress * 8),
                                    )
                                  ],
                                ),
                              );
                            },
                          ),

                          // Küre Basma Alanı
                          GestureDetector(
                            onTapDown: (_) => _startHolding(),
                            onTapUp: (_) => _stopHolding(),
                            onTapCancel: () => _stopHolding(),
                            child: Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _isCompleted ? AppTheme.gold : AppTheme.midnightBlue,
                                  width: 2.0,
                                ),
                                gradient: RadialGradient(
                                  center: const Alignment(-0.3, -0.3),
                                  colors: _isCompleted
                                      ? [
                                          Colors.white,
                                          const Color(0xFFF7D070),
                                          const Color(0xFF85651B),
                                          const Color(0xFF2B1C05),
                                        ]
                                      : [
                                          const Color(0xFFD3A4FF),
                                          const Color(0xFF9B51E0),
                                          const Color(0xFF4A0E80),
                                          const Color(0xFF130026),
                                        ],
                                  stops: const [0.0, 0.3, 0.75, 1.0],
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  _isCompleted ? "✦" : "🔮",
                                  style: TextStyle(
                                    fontSize: 48,
                                    color: _isCompleted ? AppTheme.gold : Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Sayaç Göstergesi
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppTheme.deepNavy,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.midnightBlue),
                        ),
                        child: Text(
                          _isCompleted
                              ? "Odaklanma Tamamlandı!"
                              : _isHolding
                                  ? "Odaklanılıyor: ${((7000 - (_holdProgress * 7000)) / 1000).toStringAsFixed(1)}s"
                                  : "7 Saniye Basılı Tutun",
                          style: GoogleFonts.cinzel(
                            color: _isCompleted ? AppTheme.gold : AppTheme.goldLight,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Sorunun Girileceği Form Alanı (Sadece 7 sn tamamlandıysa açılır)
                    AnimatedOpacity(
                      opacity: _isCompleted ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: _isCompleted
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Küreye Sorunu Fısılda",
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _questionController,
                                  maxLines: 3,
                                  style: GoogleFonts.lora(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: "Merak ettiğin, cevabını aradığın kader sorusunu buraya yaz...",
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
                                const SizedBox(height: 30),
                                SizedBox(
                                  width: double.infinity,
                                  height: 54,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      ref.read(sphereProvider.notifier).getReading(
                                            _questionController.text,
                                          );
                                    },
                                    child: const Text("KÜREDEN CEVAP AL"),
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (state.isLoading)
          const MysticLoader(
            message: "Kürenin sisleri dağılıyor, kaderin cevabı şekilleniyor...",
          ),
      ],
    );
  }
}

// Particle Modeli
class SphereParticle {
  double x, y;
  double vx, vy;
  double size;
  double alpha;
  Color color;

  SphereParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.alpha,
    required this.color,
  });
}

// Particle Painter
class SphereParticlePainter extends CustomPainter {
  final List<SphereParticle> particles;

  SphereParticlePainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    for (final p in particles) {
      final paint = Paint()
        ..color = p.color.withOpacity(p.alpha)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(center.dx + p.x, center.dy + p.y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
