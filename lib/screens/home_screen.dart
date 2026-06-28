import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math' as math;
import '../providers/pokemon_provider.dart';
import '../models/pokemon.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';

const _accent = Color(0xFF4FC3F7);
const _bg = Color(0xFF0A0C10);
const _surface = Color(0xFF0D0F14);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.35, initialPage: 8400);
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _glowAnimation = CurvedAnimation(parent: _glowController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'normal': return const Color(0xFFA8A77A);
      case 'fire': return const Color(0xFFEE8130);
      case 'water': return const Color(0xFF6390F0);
      case 'electric': return const Color(0xFFF7D02C);
      case 'grass': return const Color(0xFF7AC74C);
      case 'ice': return const Color(0xFF96D9D6);
      case 'fighting': return const Color(0xFFC22E28);
      case 'poison': return const Color(0xFFA33EA1);
      case 'ground': return const Color(0xFFE2BF65);
      case 'flying': return const Color(0xFFA98FF3);
      case 'psychic': return const Color(0xFFF95587);
      case 'bug': return const Color(0xFFA6B91A);
      case 'rock': return const Color(0xFFB6A136);
      case 'ghost': return const Color(0xFF735797);
      case 'dragon': return const Color(0xFF6F35FC);
      case 'dark': return const Color(0xFF705746);
      case 'steel': return const Color(0xFFB7B7CE);
      case 'fairy': return const Color(0xFFD685AD);
      default: return _accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Consumer<PokemonProvider>(
        builder: (context, provider, child) {
          final primaryColor = provider.featuredTypesPokemon.isNotEmpty 
              ? _getTypeColor(provider.featuredTypesPokemon[provider.focusedFeaturedIndex].types.first)
              : _accent;

          return Stack(
            children: [
              // Background Tech Pattern
              Positioned.fill(
                child: Opacity(
                  opacity: 0.03,
                  child: CustomPaint(painter: _TechGridPainter(color: primaryColor)),
                ),
              ),
              // Glow
              Positioned(
                top: -100,
                right: -50,
                child: AnimatedBuilder(
                  animation: _glowAnimation,
                  builder: (context, _) => Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryColor.withValues(alpha: 0.05),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.05 + _glowAnimation.value * 0.1),
                          blurRadius: 100,
                          spreadRadius: 50,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              
              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0, top: 8.0, bottom: 8.0),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          Image.asset(
                            'assets/images/logobg.png',
                            width: 80,
                            height: 80,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: provider.isLoading && provider.featuredTypesPokemon.isEmpty
                          ? const LoadingWidget()
                          : provider.errorMessage != null && provider.featuredTypesPokemon.isEmpty
                              ? CustomErrorWidget(
                                  errorMessage: provider.errorMessage!,
                                  onRetry: () => provider.refreshHome(),
                                )
                              : RefreshIndicator(
                                  onRefresh: provider.refreshHome,
                                  color: primaryColor,
                                  backgroundColor: _surface,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      const SizedBox(height: 16),
                      
                      // ── Hero Section ──────────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.circle, color: primaryColor, size: 10),
                                const SizedBox(width: 8),
                                Text(
                                  'SYSTEM ONLINE',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: primaryColor.withValues(alpha: 0.8),
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'POKÉWORLD\nDATABASE',
                              style: TextStyle(
                                fontSize: 38,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.0,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            // ── Glowing Search Bar ─────────────────────────────────
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(context, '/search'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                decoration: BoxDecoration(
                                  color: _surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withValues(alpha: 0.05),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    )
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Text('>', style: TextStyle(color: primaryColor, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                                    const SizedBox(width: 12),
                                    Text(
                                      'INITIATE SEARCH...',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.4), 
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(Icons.qr_code_scanner, size: 18, color: primaryColor.withValues(alpha: 0.7)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ── "Featured Types" Header ─────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Row(
                          children: [
                            Text(
                              'FEATURED SCANS',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: Colors.white.withValues(alpha: 0.8),
                                letterSpacing: 2,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.2),
                                border: Border.all(color: primaryColor.withValues(alpha: 0.5)),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'LIVE',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Carousel ──────────────────────────────────────────────
                      SizedBox(
                        height: 350,
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            final length = provider.featuredTypesPokemon.length;
                            if (length > 0) {
                              provider.setFocusedFeaturedIndex(index % length);
                            }
                          },
                          itemBuilder: (context, index) {
                            final length = provider.featuredTypesPokemon.length;
                            if (length == 0) return const SizedBox.shrink();
                            
                            final actualIndex = index % length;
                            final pokemon = provider.featuredTypesPokemon[actualIndex];
                            final isFocused = provider.focusedFeaturedIndex == actualIndex;
                            
                            return AnimatedBuilder(
                              animation: _pageController,
                              builder: (context, child) {
                                double value = 1.0;
                                if (_pageController.position.haveDimensions) {
                                  value = _pageController.page! - index;
                                  value = (1 - (value.abs() * 0.7)).clamp(0.0, 1.0);
                                } else {
                                  value = index == 8400 ? 1.0 : 0.3;
                                }
                                return Center(
                                  child: SizedBox(
                                    height: Curves.easeOut.transform(value) * 350,
                                    width: Curves.easeOut.transform(value) * 300,
                                    child: child,
                                  ),
                                );
                              },
                              child: _FeaturedCarouselCard(pokemon: pokemon, isFocused: isFocused),
                            );
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 16),

                      // ── Live Details HUD ──────────────────────────────────────
                      if (provider.featuredTypesPokemon.isNotEmpty) ...[
                         _buildLiveDetails(provider.featuredTypesPokemon[provider.focusedFeaturedIndex], primaryColor)
                      ],
                      const SizedBox(height: 40),
                                      ],
                                    ),
                                  ),
                                ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildLiveDetails(Pokemon pokemon, Color primaryColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: _surface,
        border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name and ID HUD style
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  _capitalize(pokemon.name),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.15),
                  border: Border.all(color: primaryColor),
                ),
                child: Text(
                  'ID: ${pokemon.id.toString().padLeft(3, '0')}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: primaryColor,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: primaryColor.withValues(alpha: 0.2), height: 1),
          const SizedBox(height: 16),

          // Types
          Wrap(
            spacing: 8,
            children: pokemon.types.map((t) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  border: Border.all(color: _getTypeColor(t).withValues(alpha: 0.8)),
                ),
                child: Text(
                  _capitalize(t).toUpperCase(),
                  style: TextStyle(
                    color: _getTypeColor(t),
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                    letterSpacing: 1,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          
          // Data readout
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatBlock(Icons.height, 'HEIGHT', '${pokemon.height / 10}M', primaryColor),
                _buildStatBlock(Icons.monitor_weight, 'WEIGHT', '${pokemon.weight / 10}KG', primaryColor),
                _buildStatBlock(Icons.bolt, 'EXP', '${pokemon.baseExperience}', primaryColor),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Base Stats Bars
          Text(
            'COMBAT STATS', 
            style: TextStyle(
              color: primaryColor.withValues(alpha: 0.8), 
              fontSize: 12, 
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            )
          ),
          const SizedBox(height: 16),
          ...pokemon.stats.map((stat) {
             final percentage = stat.baseStat / 255.0; 
             return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 80,
                      child: Text(
                        _capitalize(stat.name.replaceAll('-', ' ')).toUpperCase(), 
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5), 
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 35,
                      child: Text(
                        '${stat.baseStat}', 
                        style: const TextStyle(
                          color: Colors.white, 
                          fontWeight: FontWeight.w900, 
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: percentage.clamp(0.0, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: primaryColor,
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withValues(alpha: 0.5),
                                  blurRadius: 4,
                                )
                              ]
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
             );
          }).toList(),
        ],
      ),
    );
  }
  
  Widget _buildStatBlock(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color.withValues(alpha: 0.7), size: 18),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1)),
      ],
    );
  }
}

class _FeaturedCarouselCard extends StatelessWidget {
  final Pokemon pokemon;
  final bool isFocused;
  const _FeaturedCarouselCard({required this.pokemon, this.isFocused = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              if (isFocused)
                Positioned(
                  bottom: 10,
                  child: SizedBox(
                    width: 220,
                    height: 220,
                    child: CustomPaint(
                      painter: _PokeBallPainter(),
                    ),
                  ),
                ),
              Hero(
                tag: 'pokemon_${pokemon.id}',
                child: CachedNetworkImage(
                  imageUrl: pokemon.imageUrl,
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: Colors.white24)),
                  errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white54),
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _PokeBallPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final blackPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.65)
      ..style = PaintingStyle.fill;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      true,
      blackPaint,
    );

    final whitePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      math.pi,
      true,
      whitePaint,
    );

    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(center, radius, borderPaint);

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      linePaint,
    );

    final outerRingPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawCircle(center, 16, outerRingPaint);

    final innerFill = Paint()
      ..color = const Color(0xFF1C1C1C).withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 13, innerFill);

    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center.dx - 3, center.dy - 3), 5, highlightPaint);
  }

  @override
  bool shouldRepaint(_PokeBallPainter oldDelegate) => false;
}

class _TechGridPainter extends CustomPainter {
  final Color color;
  _TechGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0;

    const spacing = 30.0;
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TechGridPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
