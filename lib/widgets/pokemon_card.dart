import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/pokemon_response.dart';
import 'dart:math';

class PokemonCard extends StatelessWidget {
  final PokemonListItem pokemon;
  final VoidCallback onTap;
  final bool isHorizontal; 

  const PokemonCard({super.key, required this.pokemon, required this.onTap, this.isHorizontal = false});

  String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    // Generate a pseudo-random rating based on ID for visual flair
    final random = Random(pokemon.id.hashCode);
    final rating = 3 + random.nextInt(3); // 3 to 5 stars

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isHorizontal ? 160 : null,
        margin: isHorizontal ? const EdgeInsets.only(right: 16) : null,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Color(0xFF2A2D34), Color(0xFF1C1E22)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      color: Colors.white.withOpacity(0.05),
                    ),
                    Hero(
                      tag: 'pokemon_${pokemon.id}',
                      child: CachedNetworkImage(
                        imageUrl: pokemon.imageUrl,
                        placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: Colors.white24)),
                        errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white54),
                        fit: BoxFit.contain,
                        height: isHorizontal ? 100 : 120,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
              child: Column(
                children: [
                  Text(
                    _capitalize(pokemon.name),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '#${pokemon.id.padLeft(3, '0')}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 14,
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
