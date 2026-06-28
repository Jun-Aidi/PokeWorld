import 'package:flutter/material.dart';
import '../core/app_colors.dart';

// ─── Custom Shape Painter ─────────────────────────────────────────────────────
class _NavBarPainter extends CustomPainter {
  final double indicatorX;
  final Color bgColor;

  _NavBarPainter({required this.indicatorX, required this.bgColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.fill;

    const bumpRadius = 36.0;
    const bumpHeight = 28.0;
    final path = Path();

    path.moveTo(0, 12);
    path.quadraticBezierTo(0, 0, 12, 0);

    final bumpLeft = indicatorX - bumpRadius - 18;
    final bumpRight = indicatorX + bumpRadius + 18;

    path.lineTo(bumpLeft, 0);
    path.cubicTo(
      bumpLeft + 18, 0,
      indicatorX - bumpRadius, -bumpHeight,
      indicatorX - bumpRadius, -bumpHeight,
    );
    path.arcToPoint(
      Offset(indicatorX + bumpRadius, -bumpHeight),
      radius: const Radius.circular(bumpRadius),
      clockwise: false,
    );
    path.cubicTo(
      indicatorX + bumpRadius, -bumpHeight,
      bumpRight - 18, 0,
      bumpRight, 0,
    );

    path.lineTo(size.width - 12, 0);
    path.quadraticBezierTo(size.width, 0, size.width, 12);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_NavBarPainter old) =>
      old.indicatorX != indicatorX || old.bgColor != bgColor;
}

// ─── Custom Bottom Nav Bar ────────────────────────────────────────────────────
class CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _targetX = 0;
  double _currentX = 0;

  final List<_NavItem> _items = const [
    _NavItem(icon: Icons.home_outlined, label: 'Home'),
    _NavItem(icon: Icons.catching_pokemon, label: 'Pokédex'),
    _NavItem(icon: Icons.favorite_border, label: 'Favorites'),
    _NavItem(icon: Icons.info_outline, label: 'About'),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _animation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic);
    _animation.addListener(() {
      setState(() {
        _currentX = _lerp(_currentX, _targetX, _animation.value);
      });
    });
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  void _animateTo(double x) {
    _targetX = x;
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    const barHeight = 70.0;
    const bubbleSize = 60.0;
    const totalHeight = barHeight + 30.0;

    return SizedBox(
      height: totalHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / _items.length;

          if (_currentX == 0 && _targetX == 0) {
            _currentX = itemWidth * widget.currentIndex + itemWidth / 2;
            _targetX = _currentX;
          }

          return Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              // Bar with custom bump shape
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _NavBarPainter(
                        indicatorX: _currentX,
                        bgColor: c.navBg,
                      ),
                      child: SizedBox(
                        height: barHeight,
                        child: Row(
                          children: List.generate(_items.length, (index) {
                            final isActive = widget.currentIndex == index;
                            final itemCenterX =
                                itemWidth * index + itemWidth / 2;

                            return GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                _animateTo(itemCenterX);
                                widget.onTap(index);
                              },
                              child: SizedBox(
                                width: itemWidth,
                                height: barHeight,
                                child: isActive
                                    ? const SizedBox()
                                    : Icon(
                                        _items[index].icon,
                                        color: c.navInactive,
                                        size: 26,
                                      ),
                              ),
                            );
                          }),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Floating active bubble
              AnimatedBuilder(
                animation: _animation,
                builder: (context, _) {
                  return Positioned(
                    bottom: barHeight - bubbleSize / 2 - 2,
                    left: _currentX - bubbleSize / 2,
                    child: Container(
                      width: bubbleSize,
                      height: bubbleSize,
                      decoration: BoxDecoration(
                        color: c.navBubble,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: c.navBubble.withValues(alpha: 0.4),
                            blurRadius: 20,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: Icon(
                        _items[widget.currentIndex].icon,
                        color: c.navBubbleIcon,
                        size: 28,
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
