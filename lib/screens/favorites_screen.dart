import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/favorites_provider.dart';
import '../models/pokemon_response.dart';

const _accent = Color(0xFFF95587); // Pinkish red for favorites
const _bg = Color(0xFF0A0C10);
const _surface = Color(0xFF0D0F14);

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});
  String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // Background Tech Pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.04,
              child: CustomPaint(painter: _TechGridPainter()),
            ),
          ),
          // Static Glow at top right
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _accent.withValues(alpha: 0.05),
                boxShadow: [
                  BoxShadow(
                    color: _accent.withValues(alpha: 0.15),
                    blurRadius: 100,
                    spreadRadius: 50,
                  )
                ],
              ),
            ),
          ),

          SafeArea(
            child: Consumer<FavoritesProvider>(
              builder: (context, favs, _) {
                final list = favs.favoriteList;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header ───────────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.favorite, color: _accent, size: 28),
                              const SizedBox(width: 12),
                              const Text(
                                'FAVORITES',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 4,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(
                                'SAVED DATA',
                                style: TextStyle(
                                  color: _accent.withValues(alpha: 0.8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(width: 12),
                              if (list.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _accent.withValues(alpha: 0.2),
                                    border: Border.all(color: _accent.withValues(alpha: 0.5)),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${list.length} RECORDS',
                                    style: const TextStyle(
                                      color: _accent,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ── Grid ────────────────────────────────────────────────
                    Expanded(
                      child: list.isEmpty
                          ? _buildEmpty()
                          : GridView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 0.65,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: list.length,
                              itemBuilder: (context, i) {
                                final fav = list[i];
                                final name = fav['name'] ?? '';
                                final imageUrl = fav['imageUrl'] ?? '';
                                final id = fav['id'] ?? '';
                                return _buildCard(
                                  context,
                                  favs,
                                  PokemonListItem(name: name, url: 'https://pokeapi.co/api/v2/pokemon/$id/'),
                                  name,
                                  imageUrl,
                                  id,
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: _surface, 
              shape: BoxShape.circle,
              border: Border.all(color: _accent.withValues(alpha: 0.2), width: 2),
              boxShadow: [
                BoxShadow(
                  color: _accent.withValues(alpha: 0.1), 
                  blurRadius: 30, 
                  spreadRadius: 5,
                )
              ],
            ),
            child: Icon(Icons.favorite_border, size: 52, color: _accent.withValues(alpha: 0.4)),
          ),
          const SizedBox(height: 28),
          const Text(
            'NO DATA FOUND', 
            style: TextStyle(
              color: Colors.white, 
              fontSize: 18, 
              fontWeight: FontWeight.w900, 
              letterSpacing: 2,
            )
          ),
          const SizedBox(height: 10),
          Text(
            'TAP ♡ ON A SCAN TO SAVE DATA', 
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5), 
              fontSize: 10, 
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            )
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, FavoritesProvider favs, PokemonListItem item, String name, String imageUrl, String id) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/detail', arguments: item),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF131519),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Stack(
          children: [
            // Top accent line
            Positioned(
              top: 0, left: 0, right: 0,
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.8),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  boxShadow: [BoxShadow(color: _accent, blurRadius: 4)],
                ),
              ),
            ),
            
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 12),
                // Image
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      placeholder: (_, __) => Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _accent.withValues(alpha: 0.3),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Icon(
                        Icons.catching_pokemon,
                        color: _accent.withValues(alpha: 0.1),
                        size: 40,
                      ),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                // Info
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'NO.${id.padLeft(3, '0')}',
                        style: TextStyle(
                          color: _accent.withValues(alpha: 0.7),
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _cap(name),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Remove Favorite Icon
            Positioned(
              top: 8, right: 8,
              child: GestureDetector(
                onTap: () => favs.toggleFavorite(id, name, imageUrl),
                child: const Icon(
                  Icons.favorite,
                  size: 16,
                  color: _accent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TechGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _accent
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
