import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/app_colors.dart';
import '../services/api_service.dart';
import '../models/pokemon_response.dart';
import '../widgets/loading_widget.dart';

const _accent = Color(0xFF4FC3F7);

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  List<PokemonListItem> _allPokemon = [];
  List<PokemonListItem> _filteredPokemon = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllPokemon();
  }

  Future<void> _loadAllPokemon() async {
    try {
      final list = await _apiService.fetchAllPokemon();
      setState(() { _allPokemon = list; _isLoading = false; });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) { setState(() => _filteredPokemon = []); return; }
    final q = query.toLowerCase();
    setState(() { _filteredPokemon = _allPokemon.where((p) => p.name.toLowerCase().contains(q)).toList(); });
  }

  String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  @override
  void dispose() { _searchController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.bg,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: c.cardBorder)),
            child: Icon(Icons.arrow_back_ios_new, color: c.textPrimary, size: 16),
          ),
        ),
        title: Container(
          decoration: BoxDecoration(
            color: c.surface, borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _accent.withValues(alpha: 0.3)),
            boxShadow: [BoxShadow(color: _accent.withValues(alpha: 0.1), blurRadius: 12)],
          ),
          child: TextField(
            controller: _searchController, autofocus: true,
            style: TextStyle(color: c.textPrimary, fontSize: 14, letterSpacing: 0.5),
            decoration: InputDecoration(
              hintText: 'SEARCH POKÉMON...',
              hintStyle: TextStyle(color: c.textMuted, fontSize: 13, letterSpacing: 1, fontWeight: FontWeight.w600),
              prefixIcon: Icon(Icons.search, color: _accent.withValues(alpha: 0.7), size: 18),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onChanged: _onSearchChanged,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () { _searchController.clear(); _onSearchChanged(''); },
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: c.cardBorder)),
              child: Text('CLEAR', style: TextStyle(color: c.textMuted, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
            ),
          ),
        ],
      ),
      body: _isLoading ? const LoadingWidget() : _buildBody(c),
    );
  }

  Widget _buildBody(AppColors c) {
    final query = _searchController.text;

    if (query.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.search, size: 60, color: _accent.withValues(alpha: 0.15)),
        const SizedBox(height: 16),
        Text('TYPE TO SEARCH', style: TextStyle(color: c.textMuted, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 3)),
        const SizedBox(height: 6),
        Text('${_allPokemon.length} Pokémon available', style: TextStyle(color: c.textMuted, fontSize: 12, letterSpacing: 0.5)),
      ]));
    }

    if (_filteredPokemon.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.sentiment_dissatisfied, size: 52, color: c.textMuted),
        const SizedBox(height: 16),
        Text('NO RESULTS', style: TextStyle(color: c.textMuted, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 3)),
        const SizedBox(height: 6),
        Text('Try a different name', style: TextStyle(color: c.textMuted, fontSize: 12)),
      ]));
    }

    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Row(children: [
          Text('${_filteredPokemon.length} RESULTS', style: TextStyle(color: _accent.withValues(alpha: 0.7), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 2)),
        ]),
      ),
      Expanded(child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, childAspectRatio: 0.75, crossAxisSpacing: 14, mainAxisSpacing: 14,
        ),
        itemCount: _filteredPokemon.length,
        itemBuilder: (context, i) {
          final p = _filteredPokemon[i];
          return GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/detail', arguments: p),
            child: Container(
              decoration: BoxDecoration(color: c.surface2, borderRadius: BorderRadius.circular(18), border: Border.all(color: c.cardBorder)),
              child: Stack(children: [
                Positioned(top: 0, right: 0,
                  child: Container(width: 50, height: 50,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(colors: [_accent.withValues(alpha: 0.08), Colors.transparent]),
                      borderRadius: const BorderRadius.only(topRight: Radius.circular(18)),
                    ),
                  ),
                ),
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Expanded(child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 14, 10, 6),
                    child: CachedNetworkImage(
                      imageUrl: p.imageUrl,
                      placeholder: (_, __) => Center(child: CircularProgressIndicator(strokeWidth: 1.5, color: _accent.withValues(alpha: 0.4))),
                      errorWidget: (_, __, ___) => Icon(Icons.catching_pokemon, color: _accent.withValues(alpha: 0.2), size: 50),
                      fit: BoxFit.contain,
                    ),
                  )),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 14),
                    child: Column(children: [
                      Text('#${p.id.padLeft(3, '0')}', style: TextStyle(color: _accent.withValues(alpha: 0.5), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
                      const SizedBox(height: 3),
                      Text(_cap(p.name), style: TextStyle(color: c.textPrimary, fontSize: 13, fontWeight: FontWeight.w700),
                        maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                    ]),
                  ),
                ]),
              ]),
            ),
          );
        },
      )),
    ]);
  }
}
