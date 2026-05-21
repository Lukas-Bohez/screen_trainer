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
    final seed = _activeTheme?.color ?? const Color(0xFF00ACC1);
    final base = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    );
    final accent = _activeTheme?.colorScheme.secondary ?? const Color(0xFFFFB300);
    final colorScheme = base.copyWith(secondary: accent);
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colorScheme.surface,
        selectedIconTheme: IconThemeData(color: accent),
        selectedLabelTextStyle: TextStyle(color: accent, fontWeight: FontWeight.w700),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: accent.withValues(alpha: 0.18),
      ),
      textTheme: Typography.material2021().black.apply(
            bodyColor: colorScheme.onSurface,
            displayColor: colorScheme.onSurface,
          ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerHighest,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}

class AppTheme {
  static const tealSeed = Color(0xFF00ACC1);
  static const goldAccent = Color(0xFFFFB300);
}