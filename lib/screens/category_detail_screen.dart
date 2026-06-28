import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/pokemon_response.dart';
import '../widgets/pokemon_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';

class CategoryDetailScreen extends StatefulWidget {
  const CategoryDetailScreen({super.key});

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  List<PokemonListItem> _pokemonList = [];
  bool _isLoading = true;
  String? _errorMessage;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _glowAnimation = CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading && _pokemonList.isEmpty) {
      final category = ModalRoute.of(context)!.settings.arguments as String;
      _fetchCategoryData(category);
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _fetchCategoryData(String category) async {
    try {
      final list = await _apiService.getPokemonByCategory(category);
      setState(() {
        _pokemonList = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
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
      default: return const Color(0xFF4FC3F7);
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'fire': return Icons.local_fire_department;
      case 'water': return Icons.water_drop;
      case 'electric': return Icons.bolt;
      case 'grass': return Icons.eco;
      case 'ice': return Icons.ac_unit;
      case 'dragon': return Icons.local_fire_department_outlined;
      default: return Icons.auto_awesome;
    }
  }

  @override
  Widget build(BuildContext context) {
    final category = ModalRoute.of(context)!.settings.arguments as String;
    final primaryColor = _getTypeColor(category);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0C10),
      body: Column(
        children: [
          _buildHeader(category, primaryColor),
          Expanded(
            child: _buildBody(primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String category, Color primaryColor) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0D0F14),
        border: Border(
          bottom: BorderSide(
            color: primaryColor.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
      ),
      child: Stack(
        children: [
          // Background Glow
          Positioned(
            right: -50,
            top: -50,
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, _) => Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withValues(alpha: 0.1),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(
                          alpha: 0.15 + _glowAnimation.value * 0.1),
                      blurRadius: 80 + _glowAnimation.value * 20,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Back button
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: primaryColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.white, size: 18),
                ),
              ),
            ),
          ),

          // Title & Icon
          SafeArea(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getTypeIcon(category),
                          color: primaryColor,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'TYPE DATABASE',
                          style: TextStyle(
                            color: primaryColor.withValues(alpha: 0.8),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _capitalize(category),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(Color primaryColor) {
    if (_isLoading) {
      return const LoadingWidget();
    }

    if (_errorMessage != null) {
      return CustomErrorWidget(
        errorMessage: _errorMessage!,
        onRetry: () {
          setState(() {
            _isLoading = true;
            _errorMessage = null;
          });
          final category = ModalRoute.of(context)!.settings.arguments as String;
          _fetchCategoryData(category);
        },
      );
    }

    if (_pokemonList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber_rounded, size: 60, color: primaryColor.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            const Text(
              'NO DATA FOUND',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _pokemonList.length,
      itemBuilder: (context, index) {
        final pokemon = _pokemonList[index];
        return PokemonCard(
          pokemon: pokemon,
          onTap: () {
            Navigator.pushNamed(context, '/detail', arguments: pokemon);
          },
        );
      },
    );
  }
}
