import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/pokemon_response.dart';
import '../models/pokemon.dart';
import '../models/pokemon_evolution.dart';
import '../services/api_service.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen>
    with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  Pokemon? _pokemonDetail;
  EvolutionNode? _evolutionTree;
  String? _errorMessage;
  bool _isLoading = true;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlayingCry = false;

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late AnimationController _entryController;
  late Animation<double> _entryAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _glowAnimation =
        CurvedAnimation(parent: _glowController, curve: Curves.easeInOut);

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _entryAnimation =
        CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading && _pokemonDetail == null) {
      final args =
          ModalRoute.of(context)!.settings.arguments as PokemonListItem;
      _fetchDetail(args.url);
    }
  }

  Future<void> _fetchDetail(String url) async {
    try {
      final detail = await _apiService.getPokemonDetail(url);
      setState(() {
        _pokemonDetail = detail;
        _isLoading = false;
      });
      _entryController.forward();

      // Load evolution asynchronously
      _apiService.getEvolutionChain(detail.id).then((evo) {
        if (mounted) {
          setState(() {
            _evolutionTree = evo;
          });
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _glowController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  void _playCry() async {
    if (_pokemonDetail?.cryUrl != null &&
        _pokemonDetail!.cryUrl.isNotEmpty &&
        !_isPlayingCry) {
      setState(() => _isPlayingCry = true);
      HapticFeedback.mediumImpact();
      await _audioPlayer.play(UrlSource(_pokemonDetail!.cryUrl));
      setState(() => _isPlayingCry = false);
    }
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
      default: return Colors.blueGrey;
    }
  }

  String _getStatLabel(String name) {
    switch (name.toLowerCase()) {
      case 'hp': return 'HP';
      case 'attack': return 'ATK';
      case 'defense': return 'DEF';
      case 'special-attack': return 'SP.ATK';
      case 'special-defense': return 'SP.DEF';
      case 'speed': return 'SPD';
      default: return name.toUpperCase().replaceAll('-', '.');
    }
  }

  Color _getStatColor(double percentage) {
    if (percentage >= 0.75) return const Color(0xFF00E5A0);
    if (percentage >= 0.5) return const Color(0xFF4FC3F7);
    if (percentage >= 0.3) return const Color(0xFFFFB74D);
    return const Color(0xFFEF5350);
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as PokemonListItem;
    final primaryColor = _pokemonDetail != null && _pokemonDetail!.types.isNotEmpty
        ? _getTypeColor(_pokemonDetail!.types.first)
        : const Color(0xFF6390F0);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0C10),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 18),
          ),
        ),
        actions: [
          if (_pokemonDetail != null && _pokemonDetail!.cryUrl.isNotEmpty)
            GestureDetector(
              onTap: _playCry,
              child: AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, _) => Container(
                  margin: const EdgeInsets.all(8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _isPlayingCry
                        ? primaryColor.withValues(alpha: 0.4)
                        : Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isPlayingCry
                          ? primaryColor
                          : primaryColor.withValues(
                              alpha: 0.3 + _glowAnimation.value * 0.4),
                      width: 1.5,
                    ),
                    boxShadow: _isPlayingCry
                        ? [
                            BoxShadow(
                                color: primaryColor.withValues(alpha: 0.5),
                                blurRadius: 12)
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isPlayingCry
                            ? Icons.graphic_eq
                            : Icons.volume_up,
                        color: primaryColor,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isPlayingCry ? 'CRY...' : 'CRY',
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(args, primaryColor),
    );
  }

  Widget _buildBody(PokemonListItem args, Color primaryColor) {
    return Column(
      children: [
        _buildHeader(args, primaryColor),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0D0F14),
              border: Border(
                top: BorderSide(
                    color: primaryColor.withValues(alpha: 0.3), width: 1),
              ),
            ),
            child: _isLoading
                ? const LoadingWidget()
                : _errorMessage != null
                    ? CustomErrorWidget(
                        errorMessage: _errorMessage!,
                        onRetry: () {
                          setState(() {
                            _isLoading = true;
                            _errorMessage = null;
                          });
                          _fetchDetail(args.url);
                        },
                      )
                    : _buildTabs(primaryColor),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(PokemonListItem args, Color primaryColor) {
    return Container(
      height: 440, // Increased for bigger image
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            primaryColor.withValues(alpha: 0.35),
            primaryColor.withValues(alpha: 0.15),
            const Color(0xFF0D0F14),
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Scanlines
          Positioned.fill(
            child: CustomPaint(painter: _ScanlinesPainter()),
          ),
          // Glow ring & Rotating Elements
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, _) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Giant background pokeball rotating back and forth
                    Transform.rotate(
                      angle: (_glowController.value - 0.5) * 0.5, // Subtle pendulum rotation
                      child: Icon(
                        Icons.catching_pokemon,
                        size: 340,
                        color: primaryColor.withValues(alpha: 0.07),
                      ),
                    ),
                    // Outer static ring
                    Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: primaryColor.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                    ),
                    // Inner pulsing aura
                    Container(
                      width: 220 + _glowAnimation.value * 40,
                      height: 220 + _glowAnimation.value * 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(
                                alpha: 0.2 + _glowAnimation.value * 0.15),
                            blurRadius: 80 + _glowAnimation.value * 40,
                            spreadRadius: 10,
                          ),
                        ],
                        border: Border.all(
                          color: primaryColor.withValues(
                              alpha: 0.3 + _glowAnimation.value * 0.3),
                          width: 2 + _glowAnimation.value * 2,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          // Sprite
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(top: 80), // Adjusted padding for bigger image
              child: Hero(
                tag: 'pokemon_${args.id}',
                child: FadeTransition(
                  opacity: _entryAnimation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.15),
                      end: Offset.zero,
                    ).animate(_entryAnimation),
                    child: SlideTransition( // FLOATING ANIMATION
                      position: Tween<Offset>(
                        begin: const Offset(0, -0.04),
                        end: const Offset(0, 0.04),
                      ).animate(_glowAnimation),
                      child: CachedNetworkImage(
                        imageUrl: args.imageUrl,
                        height: 320, // ENLARGED IMAGE EVEN MORE
                        fit: BoxFit.contain,
                        placeholder: (context, url) => SizedBox(
                          height: 320,
                          child: Center(
                            child: CircularProgressIndicator(
                                color: primaryColor, strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error, color: Colors.white54),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Name & type overlay
          Positioned(
            bottom: 16,
            left: 20,
            right: 20,
            child: FadeTransition(
              opacity: _entryAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '#${args.id.padLeft(3, '0')}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: primaryColor,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    _capitalize(args.name),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                      height: 1.1,
                    ),
                  ),
                  if (_pokemonDetail != null) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _pokemonDetail!.types.map((t) {
                        final c = _getTypeColor(t);
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: c.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: c.withValues(alpha: 0.6), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                  color: c.withValues(alpha: 0.25),
                                  blurRadius: 8)
                            ],
                          ),
                          child: Text(
                            _capitalize(t).toUpperCase(),
                            style: TextStyle(
                              color: c,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(Color primaryColor) {
    return DefaultTabController(
      length: 5,
      child: Column(
        children: [
          Container(
            color: const Color(0xFF0D0F14),
            child: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: primaryColor,
              indicatorWeight: 2,
              labelColor: primaryColor,
              unselectedLabelColor: Colors.white38,
              labelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
              dividerColor: Colors.white.withValues(alpha: 0.06),
              tabs: const [
                Tab(text: 'ABOUT'),
                Tab(text: 'STATS'),
                Tab(text: 'MOVES'),
                Tab(text: 'EVOLUTION'),
                Tab(text: 'SHINY'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildAboutTab(primaryColor),
                _buildStatsTab(primaryColor),
                _buildMovesTab(primaryColor),
                _buildEvolutionTab(primaryColor),
                _buildMediaTab(primaryColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutTab(Color primaryColor) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            _buildStatCard(Icons.height, 'HEIGHT',
                '${_pokemonDetail!.height / 10}m', primaryColor),
            const SizedBox(width: 12),
            _buildStatCard(Icons.monitor_weight_outlined, 'WEIGHT',
                '${_pokemonDetail!.weight / 10}kg', primaryColor),
            const SizedBox(width: 12),
            _buildStatCard(Icons.local_fire_department_outlined, 'BASE EXP',
                '${_pokemonDetail!.baseExperience}', primaryColor),
          ],
        ),
        const SizedBox(height: 20),
        _buildSectionHeader('ABILITIES', Icons.auto_awesome, primaryColor),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _pokemonDetail!.abilities.map((a) {
            return Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF161820),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: primaryColor.withValues(alpha: 0.3), width: 1),
                boxShadow: [
                  BoxShadow(
                      color: primaryColor.withValues(alpha: 0.08),
                      blurRadius: 10)
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryColor,
                      boxShadow: [
                        BoxShadow(
                            color: primaryColor.withValues(alpha: 0.8),
                            blurRadius: 6)
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _capitalize(a.replaceAll('-', ' ')),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        _buildSectionHeader('TYPES', Icons.category_outlined, primaryColor),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _pokemonDetail!.types.map((t) {
            final c = _getTypeColor(t);
            return Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    c.withValues(alpha: 0.2),
                    c.withValues(alpha: 0.08)
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: c.withValues(alpha: 0.5), width: 1.5),
                boxShadow: [
                  BoxShadow(color: c.withValues(alpha: 0.2), blurRadius: 12)
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.catching_pokemon, size: 14, color: c),
                  const SizedBox(width: 6),
                  Text(
                    _capitalize(t).toUpperCase(),
                    style: TextStyle(
                      color: c,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildStatCard(
      IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF161820),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Text(title,
            style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 2)),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withValues(alpha: 0.4), Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsTab(Color primaryColor) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionHeader('BASE STATS', Icons.bar_chart, primaryColor),
        const SizedBox(height: 20),
        ..._pokemonDetail!.stats.map((stat) {
          final percentage = (stat.baseStat / 255.0).clamp(0.0, 1.0);
          final statColor = _getStatColor(percentage);
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              children: [
                SizedBox(
                  width: 72,
                  child: Text(
                    _getStatLabel(stat.name),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                SizedBox(
                  width: 44,
                  child: Text(
                    '${stat.baseStat}',
                    style: TextStyle(
                        color: statColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w900),
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _entryAnimation,
                        builder: (context, _) => FractionallySizedBox(
                          widthFactor: percentage * _entryAnimation.value,
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                statColor.withValues(alpha: 0.7),
                                statColor,
                              ]),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                    color: statColor.withValues(alpha: 0.5),
                                    blurRadius: 8)
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 36,
                  child: Text(
                    '${(percentage * 100).round()}%',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3),
                        fontSize: 10,
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          );
        }),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF161820),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: primaryColor.withValues(alpha: 0.2), width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TOTAL',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2)),
              Text(
                '${_pokemonDetail!.stats.fold<int>(0, (s, e) => s + e.baseStat)}',
                style: TextStyle(
                    color: primaryColor,
                    fontSize: 24,
                    fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMovesTab(Color primaryColor) {
    if (_pokemonDetail!.moves.isEmpty) {
      return Center(
        child: Text('NO MOVES FOUND',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
                letterSpacing: 2,
                fontWeight: FontWeight.w700)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      itemCount: _pokemonDetail!.moves.length,
      itemBuilder: (context, index) {
        final move = _pokemonDetail!.moves[index];
        final highlight = index % 5 == 0;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF131519),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: highlight
                  ? primaryColor.withValues(alpha: 0.25)
                  : Colors.white.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 36,
                child: Text(
                  '${(index + 1).toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: highlight
                        ? primaryColor.withValues(alpha: 0.8)
                        : Colors.white.withValues(alpha: 0.2),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Container(
                  width: 1,
                  height: 14,
                  color: Colors.white.withValues(alpha: 0.1),
                  margin: const EdgeInsets.only(right: 14)),
              Expanded(
                child: Text(
                  _capitalize(move.replaceAll('-', ' ')),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3),
                ),
              ),
              Icon(Icons.chevron_right,
                  color: Colors.white.withValues(alpha: 0.15), size: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMediaTab(Color primaryColor) {
    if (_pokemonDetail!.shinyImageUrl.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome,
                color: Colors.white.withValues(alpha: 0.2), size: 48),
            const SizedBox(height: 16),
            Text('NO SHINY FORM AVAILABLE',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    letterSpacing: 2,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      );
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_awesome,
                  color: Color(0xFFFFD700), size: 16),
              const SizedBox(width: 8),
              const Text('SHINY FORM',
                  style: TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.5)),
              const SizedBox(width: 8),
              const Icon(Icons.auto_awesome,
                  color: Color(0xFFFFD700), size: 16),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF161820),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                  width: 2),
              boxShadow: [
                BoxShadow(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                    blurRadius: 40,
                    spreadRadius: 5)
              ],
            ),
            child: CachedNetworkImage(
              imageUrl: _pokemonDetail!.shinyImageUrl,
              height: 180,
              placeholder: (context, url) => const SizedBox(
                  height: 180,
                  width: 180,
                  child: Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFFFFD700), strokeWidth: 2))),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.error, color: Colors.white54),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color:
                  const Color(0xFFFFD700).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.3)),
            ),
            child: const Text('✦  RARE VARIANT  ✦',
                style: TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2)),
          ),
        ],
      ),
    );
  }

  Widget _buildEvolutionTab(Color primaryColor) {
    if (_evolutionTree == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: primaryColor),
            const SizedBox(height: 16),
            Text('SCANNING EVOLUTION DATA...', 
              style: TextStyle(color: primaryColor, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 2)
            ),
          ],
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildSectionHeader('EVOLUTION CHAIN', Icons.timeline, primaryColor),
        const SizedBox(height: 32),
        _buildEvolutionNode(_evolutionTree!, primaryColor),
      ],
    );
  }

  Widget _buildEvolutionNode(EvolutionNode node, Color primaryColor) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF161820),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: primaryColor.withValues(alpha: 0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.1),
                blurRadius: 15,
                spreadRadius: 2,
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                  border: Border.all(color: primaryColor.withValues(alpha: 0.5)),
                ),
                child: CachedNetworkImage(
                  imageUrl: node.imageUrl,
                  placeholder: (context, url) => CircularProgressIndicator(color: primaryColor, strokeWidth: 2),
                  errorWidget: (context, url, error) => const Icon(Icons.catching_pokemon, color: Colors.white24),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${node.id.padLeft(3, '0')}',
                      style: TextStyle(
                        color: primaryColor.withValues(alpha: 0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _capitalize(node.name),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        if (node.evolvesTo.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Icon(Icons.keyboard_double_arrow_down, color: primaryColor.withValues(alpha: 0.6), size: 28),
          ),
          ...node.evolvesTo.map((child) => _buildEvolutionNode(child, primaryColor)),
        ],
      ],
    );
  }
}

// ─── Scanlines Painter ────────────────────────────────────────────────────────
class _ScanlinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.025)
      ..strokeWidth = 1;
    const spacing = 6.0;
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_ScanlinesPainter old) => false;
}
