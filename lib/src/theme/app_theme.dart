import 'package:flutter/material.dart';

import '../models/gacha_item.dart';

class ThemeService extends ChangeNotifier {
  ThemeService();

  ThemeMode _themeMode = ThemeMode.system;
  ThemeItem? _activeTheme;

  ThemeMode get themeMode => _themeMode;
  ThemeItem? get activeTheme => _activeTheme;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
  }

  void setActiveTheme(ThemeItem? theme) {
    if (_activeTheme?.id == theme?.id) return;
    _activeTheme = theme;
    notifyListeners();
  }

  ThemeData buildTheme(Brightness brightness) {
    final seed = _activeTheme?.color ?? AppTheme.tealSeed;
    final accent = _activeTheme?.colorScheme.secondary ?? AppTheme.goldAccent;
    final isDark = brightness == Brightness.dark;
    final base = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
    final background = isDark ? const Color(0xFF07191F) : const Color(0xFFF6FCFD);
    final surface = isDark ? const Color(0xFF0E222A) : const Color(0xFFFFFFFF);
    final surfaceVariant = isDark ? const Color(0xFF15303A) : const Color(0xFFE6F4F7);
    final elevatedSurface = isDark ? const Color(0xFF122B35) : const Color(0xFFF1FAFC);
    final colorScheme = base.copyWith(
      primary: seed,
      secondary: accent,
      tertiary: const Color(0xFFEC6F6A),
      surface: surface,
      surfaceDim: surfaceVariant,
      surfaceBright: elevatedSurface,
      surfaceContainerLowest: background,
      surfaceContainerLow: isDark ? const Color(0xFF11262E) : const Color(0xFFF0F7F9),
      surfaceContainer: surfaceVariant,
      surfaceContainerHigh: isDark ? const Color(0xFF173541) : const Color(0xFFE0F0F4),
      surfaceContainerHighest: elevatedSurface,
      surfaceTint: accent,
      outline: isDark ? const Color(0xFF355160) : const Color(0xFF8DB8C6),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: Color.alphaBlend(accent.withValues(alpha: 0.08), colorScheme.surface),
        selectedIconTheme: IconThemeData(color: accent),
        unselectedIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
        selectedLabelTextStyle: TextStyle(color: accent, fontWeight: FontWeight.w700),
        unselectedLabelTextStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Color.alphaBlend(accent.withValues(alpha: 0.06), colorScheme.surface),
        indicatorColor: accent.withValues(alpha: 0.22),
      ),
      textTheme: Typography.material2021().black.apply(
            bodyColor: colorScheme.onSurface,
            displayColor: colorScheme.onSurface,
          ),
      cardTheme: CardThemeData(
        color: Color.alphaBlend(accent.withValues(alpha: 0.03), colorScheme.surfaceContainerHighest),
        elevation: 0,
        surfaceTintColor: accent.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      dividerTheme: DividerThemeData(color: colorScheme.outlineVariant.withValues(alpha: 0.45)),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          side: BorderSide(color: colorScheme.outline),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color.alphaBlend(accent.withValues(alpha: 0.04), colorScheme.surface),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: accent, width: 1.6),
        ),
      ),
      listTileTheme: ListTileThemeData(
        tileColor: Color.alphaBlend(accent.withValues(alpha: 0.02), colorScheme.surfaceContainerLow),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        iconColor: colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class AppTheme {
  static const tealSeed = Color(0xFF00ACC1);
  static const goldAccent = Color(0xFFFFB300);
}