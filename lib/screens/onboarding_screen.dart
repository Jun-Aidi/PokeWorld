import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Welcome to Poke World',
      'description': 'Explore over 1300 Pokémon from every generation.',
      'icon': Icons.catching_pokemon,
      'color': const Color(0xFF4FC3F7),
    },
    {
      'title': 'Discover by Type',
      'description': 'Browse Pokémon by Grass, Fire, Water, Electric, Dragon, and many more.',
      'icon': Icons.auto_awesome_mosaic,
      'color': const Color(0xFF7AC74C), // Grass green
    },
    {
      'title': 'Search & Learn',
      'description': 'Search Pokémon instantly and view detailed information including stats, abilities, and evolutions.',
      'icon': Icons.screen_search_desktop,
      'color': const Color(0xFFF7D02C), // Electric yellow
    },
    {
      'title': 'Ready to Explore?',
      'description': 'Start your Pokémon journey today.',
      'icon': Icons.rocket_launch_outlined,
      'color': const Color(0xFFF95587), // Psychic pink
    },
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildDot(int index) {
    bool isActive = _currentPage == index;
    final activeColor = _pages[_currentPage]['color'] as Color;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? activeColor : Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: activeColor.withValues(alpha: 0.5),
                  blurRadius: 8,
                  spreadRadius: 1,
                )
              ]
            : [],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = _pages[_currentPage]['color'] as Color;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0C10),
      body: Stack(
        children: [
          // Subtle background glow based on current page
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            top: -100,
            right: _currentPage.isEven ? -100 : null,
            left: _currentPage.isOdd ? -100 : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: activeColor.withValues(alpha: 0.1),
                boxShadow: [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.1),
                    blurRadius: 100,
                    spreadRadius: 50,
                  )
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Top skip button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: AnimatedOpacity(
                      opacity: _currentPage == _pages.length - 1 ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: TextButton(
                        onPressed: _currentPage == _pages.length - 1
                            ? null
                            : _completeOnboarding,
                        child: Text(
                          'SKIP',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Page View
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      final page = _pages[index];
                      return Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Hologram style icon
                            Container(
                              padding: const EdgeInsets.all(40),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: page['color'].withValues(alpha: 0.05),
                                border: Border.all(
                                  color: page['color'].withValues(alpha: 0.2),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: page['color'].withValues(alpha: 0.1),
                                    blurRadius: 40,
                                    spreadRadius: 10,
                                  )
                                ],
                              ),
                              child: Icon(
                                page['icon'],
                                size: 100,
                                color: page['color'],
                              ),
                            ),
                            const SizedBox(height: 60),
                            Text(
                              page['title'],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              page['description'],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Bottom Controls
                Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Dots
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          _pages.length,
                          (index) => _buildDot(index),
                        ),
                      ),

                      // Next / Start Button
                      GestureDetector(
                        onTap: () {
                          if (_currentPage == _pages.length - 1) {
                            _completeOnboarding();
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                          decoration: BoxDecoration(
                            color: activeColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: activeColor,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: activeColor.withValues(alpha: 0.3),
                                blurRadius: 12,
                                spreadRadius: 2,
                              )
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _currentPage == _pages.length - 1
                                    ? 'GET STARTED'
                                    : 'NEXT',
                                style: TextStyle(
                                  color: activeColor,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                _currentPage == _pages.length - 1
                                    ? Icons.rocket_launch
                                    : Icons.arrow_forward_ios,
                                size: 16,
                                color: activeColor,
                              ),
                            ],
                          ),
                        ),
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
}
