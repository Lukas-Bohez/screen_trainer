import 'package:flutter/material.dart';

ThemeData applyTvTheme(ThemeData baseTheme) {
  final textTheme = baseTheme.textTheme.apply(fontSizeFactor: 1.15);
  return baseTheme.copyWith(
    textTheme: textTheme,
    navigationRailTheme: baseTheme.navigationRailTheme.copyWith(
      minWidth: 92,
      minExtendedWidth: 280,
    ),
  );
}