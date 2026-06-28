import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';


const _accentAbout = Color(0xFF7AC74C);

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _accentAbout,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                            color: _accentAbout.withValues(alpha: 0.6),
                            blurRadius: 8)
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('ABOUT',
                      style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2)),
                ],
              ),
              const SizedBox(height: 32),

              // ── App logo ───────────────────────────────────────────────
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: c.surface2,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: _accentAbout.withValues(alpha: 0.4),
                            width: 2),
                        boxShadow: [
                          BoxShadow(
                              color: _accentAbout.withValues(alpha: 0.2),
                              blurRadius: 30,
                              spreadRadius: 5)
                        ],
                      ),
                      child: Icon(Icons.catching_pokemon,
                          size: 58,
                          color: _accentAbout.withValues(alpha: 0.85)),
                    ),
                    const SizedBox(height: 20),
                    Text('PokéWorld',
                        style: TextStyle(
                            color: c.textPrimary,
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1)),
                    const SizedBox(height: 6),
                    Text('DISCOVER & EXPLORE ALL POKÉMON',
                        style: TextStyle(
                            color: _accentAbout.withValues(alpha: 0.7),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2)),
                  ],
                ),
              ),
              const SizedBox(height: 32),


              // ── Cards ─────────────────────────────────────────────────
              _buildCard(c, 'APP INFO', Icons.info_outline, [
                _RowData(Icons.apps, 'App Name', 'PokéWorld'),
                _RowData(Icons.tag, 'Version', '1.0.0'),
                _RowData(Icons.code, 'Built with', 'Flutter & Dart'),
                _RowData(Icons.palette, 'Design', 'Game RPG Theme'),
              ]),
              const SizedBox(height: 16),

              _buildCard(c, 'DATA SOURCE', Icons.cloud_outlined, [
                _RowData(Icons.api, 'API', 'PokéAPI'),
                _RowData(Icons.link, 'URL', 'pokeapi.co/api/v2'),
                _RowData(Icons.data_object, 'Data', 'Pokémon, Types, Stats'),
                _RowData(Icons.lock_open, 'License', 'Free & Open Source'),
              ]),
              const SizedBox(height: 16),

              _buildCard(c, 'FEATURES', Icons.auto_awesome, [
                _RowData(Icons.home_outlined, 'Home', 'Carousel & Featured Types'),
                _RowData(Icons.catching_pokemon, 'Pokédex', 'Full list with search & filter'),
                _RowData(Icons.favorite_border, 'Favorites', 'Save Pokémon locally'),
                _RowData(Icons.search, 'Search', 'Fast global search by name'),
              ]),
              const SizedBox(height: 16),

              _buildCard(c, 'CREDITS', Icons.people_outline, [
                _RowData(Icons.people_outline, 'PokéAPI Team', 'API & Data'),
                _RowData(Icons.photo_outlined, 'PokeAPI Sprites', 'Artwork & Images'),
              ]),

              const SizedBox(height: 32),
              Center(
                child: Text(
                  '© 2024 PokéWorld — Made with ❤️',
                  style: TextStyle(
                      color: c.textMuted, fontSize: 12, letterSpacing: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildCard(AppColors c, String title, IconData icon,
      List<_RowData> rows) {
    return Container(
      decoration: BoxDecoration(
        color: c.surface2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
            child: Row(
              children: [
                Icon(icon, color: _accentAbout, size: 16),
                const SizedBox(width: 8),
                Text(title,
                    style: TextStyle(
                        color: _accentAbout,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2)),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        _accentAbout.withValues(alpha: 0.3),
                        Colors.transparent
                      ]),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...rows.map((r) => _buildRow(c, r)),
        ],
      ),
    );
  }

  Widget _buildRow(AppColors c, _RowData r) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Row(
            children: [
              Icon(r.icon, color: c.textSecondary, size: 18),
              const SizedBox(width: 12),
              Text(r.label,
                  style: TextStyle(
                      color: c.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              const Spacer(),
              Text(r.value,
                  style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Divider(height: 1, color: c.divider),
        ),
      ],
    );
  }
}

class _RowData {
  final IconData icon;
  final String label;
  final String value;
  const _RowData(this.icon, this.label, this.value);
}
