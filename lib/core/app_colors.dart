import 'package:flutter/material.dart';

/// Centralized color tokens for dark and light mode.
/// Access via: AppColors.of(context)
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.isDark,
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.cardBorder,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.navBg,
    required this.navBubble,
    required this.navBubbleIcon,
    required this.navInactive,
    required this.scanline,
    required this.divider,
  });

  final bool isDark;
  final Color bg;
  final Color surface;
  final Color surface2;
  final Color cardBorder;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color navBg;
  final Color navBubble;
  final Color navBubbleIcon;
  final Color navInactive;
  final Color scanline;
  final Color divider;

  // ── Dark (game RPG scanner) ────────────────────────────────────────────
  static const AppColors dark = AppColors(
    isDark: true,
    bg: Color(0xFF0A0C10),
    surface: Color(0xFF131519),
    surface2: Color(0xFF161820),
    cardBorder: Color(0x10FFFFFF),
    textPrimary: Colors.white,
    textSecondary: Color(0x80FFFFFF),
    textMuted: Color(0x40FFFFFF),
    navBg: Color(0xFF1C1E22),
    navBubble: Colors.white,
    navBubbleIcon: Colors.black,
    navInactive: Color(0x80FFFFFF),
    scanline: Color(0x07FFFFFF),
    divider: Color(0x10FFFFFF),
  );



  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>() ?? dark;

  @override
  AppColors copyWith({
    bool? isDark,
    Color? bg,
    Color? surface,
    Color? surface2,
    Color? cardBorder,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? navBg,
    Color? navBubble,
    Color? navBubbleIcon,
    Color? navInactive,
    Color? scanline,
    Color? divider,
  }) =>
      AppColors(
        isDark: isDark ?? this.isDark,
        bg: bg ?? this.bg,
        surface: surface ?? this.surface,
        surface2: surface2 ?? this.surface2,
        cardBorder: cardBorder ?? this.cardBorder,
        textPrimary: textPrimary ?? this.textPrimary,
        textSecondary: textSecondary ?? this.textSecondary,
        textMuted: textMuted ?? this.textMuted,
        navBg: navBg ?? this.navBg,
        navBubble: navBubble ?? this.navBubble,
        navBubbleIcon: navBubbleIcon ?? this.navBubbleIcon,
        navInactive: navInactive ?? this.navInactive,
        scanline: scanline ?? this.scanline,
        divider: divider ?? this.divider,
      );

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      isDark: t < 0.5 ? isDark : other.isDark,
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surface2: Color.lerp(surface2, other.surface2, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      navBg: Color.lerp(navBg, other.navBg, t)!,
      navBubble: Color.lerp(navBubble, other.navBubble, t)!,
      navBubbleIcon: Color.lerp(navBubbleIcon, other.navBubbleIcon, t)!,
      navInactive: Color.lerp(navInactive, other.navInactive, t)!,
      scanline: Color.lerp(scanline, other.scanline, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
    );
  }
}
