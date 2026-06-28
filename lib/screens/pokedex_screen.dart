import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/api_service.dart';
import '../models/pokemon_response.dart';
import '../widgets/loading_widget.dart';
import '../providers/favorites_provider.dart';

const _bg = Color(0xFF0A0C10);
const _surface = Color(0xFF0D0F14);

class PokedexScreen extends StatefulWidget {
  const PokedexScreen({super.key});
  @override
  State<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends State<PokedexScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  List<PokemonListItem> _allPokemon = [];
  List<PokemonListItem> _filteredPokemon = [];
  List<String> _categories = [];
  String _selectedCategory = 'All';
  bool _isLoading = true;
  int _currentPage = 0;
  final int _pageSize = 20;

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _glowAnimation = CurvedAnimation(parent: _glowController, curve: Curves.easeInOut);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _apiService.fetchAllPokemon(),
        _apiService.getCategories(),
      ]);
      setState(() {
        _allPokemon = results[0] as List<PokemonListItem>;
        _categories = ['All', ...results[1] as List<String>];
        _filteredPokemon = _allPokemon;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String q) =>
      _applyFilters(query: q, category: _selectedCategory);

  void _selectCategory(String cat) {
    setState(() => _selectedCategory = cat);
    _applyFilters(query: _searchController.text, category: cat);
  }

  void _applyFilters({required String query, required String category}) async {
    List<PokemonListItem> base = _allPokemon;
    if (category != 'All') {
      setState(() => _isLoading = true);
      try {
        base = await _apiService.getPokemonByCategory(category);
      } catch (_) {}
    }
    final filtered = query.isEmpty
        ? base
        : base.where((p) => p.name.toLowerCase().contains(query.toLowerCase())).toList();
    setState(() {
      _filteredPokemon = filtered;
      _currentPage = 0;
      _isLoading = false;
    });
  }

  List<PokemonListItem> get _currentPageItems {
    final start = _currentPage * _pageSize;
    final end = (start + _pageSize).clamp(0, _filteredPokemon.length);
    return _filteredPokemon.sublist(start, end);
  }

  int get _totalPages => (_filteredPokemon.length / _pageSize).ceil();
  String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

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
      default: return const Color(0xFF4FC3F7);
    }
  }

  Color get _currentAccent => _selectedCategory == 'All' 
      ? const Color(0xFF4FC3F7) 
      : _getTypeColor(_selectedCategory);

  @override
  void dispose() {
    _searchController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = _currentAccent;
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // Background Tech Pattern & Glow
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: CustomPaint(painter: _TechGridPainter(color: accent)),
            ),
          ),
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
                  color: accent.withValues(alpha: 0.1),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.1 + _glowAnimation.value * 0.1),
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
                // ── Header ────────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.radar, color: accent, size: 28),
                          const SizedBox(width: 12),
                          const Text(
                            'POKÉDEX',
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
                            'GLOBAL DATABASE',
                            style: TextStyle(
                              color: accent.withValues(alpha: 0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.2),
                              border: Border.all(color: accent.withValues(alpha: 0.5)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${_filteredPokemon.length} SCANS',
                              style: TextStyle(
                                color: accent,
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
                
                // ── Search Bar ────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: accent.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Text('>', style: TextStyle(color: accent, fontWeight: FontWeight.w900)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: _onSearchChanged,
                            style: const TextStyle(
                              color: Colors.white, 
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                            decoration: InputDecoration(
                              hintText: 'ENTER POKÉMON NAME...',
                              hintStyle: TextStyle(
                                color: Colors.white.withValues(alpha: 0.3),
                                fontSize: 12,
                                letterSpacing: 2,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                            child: Icon(Icons.close, color: accent.withValues(alpha: 0.7), size: 18),
                          )
                        else
                          Icon(Icons.search, color: accent.withValues(alpha: 0.7), size: 18),
                      ],
                    ),
                  ),
                ),

                // ── Category Filters ──────────────────────────────────────────
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _categories.length,
                    itemBuilder: (context, i) {
                      final cat = _categories[i];
                      final isSel = cat == _selectedCategory;
                      final catColor = cat == 'All' ? const Color(0xFF4FC3F7) : _getTypeColor(cat);
                      return GestureDetector(
                        onTap: () => _selectCategory(cat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(right: 12, top: 12, bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSel ? catColor.withValues(alpha: 0.15) : _surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSel ? catColor : Colors.white.withValues(alpha: 0.1),
                              width: isSel ? 1.5 : 1,
                            ),
                            boxShadow: isSel
                                ? [BoxShadow(color: catColor.withValues(alpha: 0.2), blurRadius: 8)]
                                : [],
                          ),
                          child: Text(
                            _cap(cat).toUpperCase(),
                            style: TextStyle(
                              color: isSel ? catColor : Colors.white54,
                              fontSize: 11,
                              fontWeight: isSel ? FontWeight.w900 : FontWeight.w600,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // ── Main Content Grid ─────────────────────────────────────────
                Expanded(
                  child: _isLoading
                      ? const LoadingWidget()
                      : _filteredPokemon.isEmpty
                          ? Center(
                              child: Text(
                                'NO RESULTS FOUND',
                                style: TextStyle(
                                  color: accent.withValues(alpha: 0.5),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2,
                                ),
                              ),
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 0.75,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                              ),
                              itemCount: _currentPageItems.length,
                              itemBuilder: (context, i) {
                                return _buildCard(context, _currentPageItems[i], accent);
                              },
                            ),
                ),

                // ── Pagination HUD ────────────────────────────────────────────
                if (!_isLoading && _filteredPokemon.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: _bg,
                      border: Border(
                        top: BorderSide(color: accent.withValues(alpha: 0.2)),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'PAGE ${_currentPage + 1} / ${_totalPages == 0 ? 1 : _totalPages}',
                          style: TextStyle(
                            color: accent.withValues(alpha: 0.7),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                          ),
                        ),
                        Row(
                          children: [
                            _NavBtn(
                              icon: Icons.keyboard_double_arrow_left,
                              enabled: _currentPage > 0,
                              onTap: () => setState(() => _currentPage = 0),
                              color: accent,
                            ),
                            const SizedBox(width: 8),
                            _NavBtn(
                              icon: Icons.chevron_left,
                              enabled: _currentPage > 0,
                              onTap: () => setState(() => _currentPage--),
                              color: accent,
                            ),
                            const SizedBox(width: 8),
                            _NavBtn(
                              icon: Icons.chevron_right,
                              enabled: _currentPage < _totalPages - 1,
                              onTap: () => setState(() => _currentPage++),
                              color: accent,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, PokemonListItem p, Color accent) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/detail', arguments: p),
      child: Consumer<FavoritesProvider>(
        builder: (context, favs, _) {
          final isFav = favs.isFavorite(p.id);
          return Container(
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
                      color: accent.withValues(alpha: 0.8),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      boxShadow: [BoxShadow(color: accent, blurRadius: 4)],
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
                        child: Hero(
                          tag: 'pokemon_${p.id}',
                          child: CachedNetworkImage(
                            imageUrl: p.imageUrl,
                            placeholder: (_, __) => Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: accent.withValues(alpha: 0.3),
                              ),
                            ),
                            errorWidget: (_, __, ___) => Icon(
                              Icons.catching_pokemon,
                              color: accent.withValues(alpha: 0.1),
                              size: 40,
                            ),
                            fit: BoxFit.contain,
                          ),
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
                            'NO.${p.id.padLeft(3, '0')}',
                            style: TextStyle(
                              color: accent.withValues(alpha: 0.7),
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _cap(p.name),
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
                // Favorite Icon
                Positioned(
                  top: 8, right: 8,
                  child: GestureDetector(
                    onTap: () => favs.toggleFavorite(p.id, p.name, p.imageUrl),
                    child: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      size: 16,
                      color: isFav ? const Color(0xFFF95587) : Colors.white30,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  final Color color;
  const _NavBtn({required this.icon, required this.enabled, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: enabled ? _surface : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: enabled ? color.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.05),
            width: 1.5,
          ),
          boxShadow: enabled
              ? [BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 4)]
              : [],
        ),
        child: Icon(
          icon,
          color: enabled ? color : Colors.white24,
          size: 20,
        ),
      ),
    );
  }
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
