import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  
  double _loadingProgress = 0.0;
  Timer? _progressTimer;

  @override
  void initState() {
    super.initState();

    // Pulse animation
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _glowAnimation = CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    );

    // Simulate loading progress
    _progressTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        if (_loadingProgress < 1.0) {
          _loadingProgress += 0.02; // Finishes in ~2.5 seconds
        } else {
          timer.cancel();
        }
      });
    });

    // Navigate to next screen after 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), () async {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
      
      if (mounted) {
        if (hasSeenOnboarding) {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
        }
      }
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    _progressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF4FC3F7); // Cyan neon
    
    return Scaffold(
      backgroundColor: const Color(0xFF0A0C10),
      body: Stack(
        children: [
          // Background subtle grid/lines (simulated with a dark pattern)
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: CustomPaint(
                painter: _GridPainter(color: primaryColor),
              ),
            ),
          ),
          
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Glowing Pokeball Icon
                AnimatedBuilder(
                  animation: _glowAnimation,
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer glow aura
                        Container(
                          width: 140 + _glowAnimation.value * 30,
                          height: 140 + _glowAnimation.value * 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withValues(
                                    alpha: 0.2 + _glowAnimation.value * 0.2),
                                blurRadius: 40 + _glowAnimation.value * 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                        ),
                        // Inner circle border
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: primaryColor.withValues(
                                  alpha: 0.3 + _glowAnimation.value * 0.5),
                              width: 2,
                            ),
                            color: const Color(0xFF131519),
                          ),
                        ),
                        // Pokeball Icon
                        Icon(
                          Icons.catching_pokemon,
                          size: 70,
                          color: primaryColor.withValues(
                              alpha: 0.8 + _glowAnimation.value * 0.2),
                        ),
                      ],
                    );
                  },
                ),
                
                const SizedBox(height: 50),
                
                // Title
                const Text(
                  'POKÉWORLD OS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // System Status
                Text(
                  'INITIALIZING SYSTEM...',
                  style: TextStyle(
                    color: primaryColor.withValues(alpha: 0.8),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 3,
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Progress Bar
                Container(
                  width: 200,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 50),
                        width: 200 * _loadingProgress,
                        height: 4,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.6),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Percentage Text
                Text(
                  '${(_loadingProgress * 100).toInt()}%',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Courier',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Simple grid painter for background tech pattern
class _GridPainter extends CustomPainter {
  final Color color;
  _GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0;

    const spacing = 40.0;
    
    // Draw vertical lines
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    
    // Draw horizontal lines
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
