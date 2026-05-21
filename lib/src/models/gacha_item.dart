import 'package:flutter/material.dart';

enum GachaRarity { common, rare, epic, legendary }
enum GachaTrack { curtain, theme }

class GachaItem {
  const GachaItem({
    required this.id,
    required this.name,
    required this.rarity,
    required this.track,
    required this.assetPath,
    required this.isAnimated,
    required this.color,
  });

  final String id;
  final String name;
  final GachaRarity rarity;
  final GachaTrack track;
  final String assetPath;
  final bool isAnimated;
  final Color color;
}

class ThemeItem extends GachaItem {
  const ThemeItem({
    required super.id,
    required super.name,
    required super.rarity,
    required super.track,
    required super.assetPath,
    required super.isAnimated,
    required super.color,
    required this.colorScheme,
  });

  final ColorScheme colorScheme;
}