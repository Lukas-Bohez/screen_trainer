import 'package:flutter/material.dart';

enum BadgeRarity { common, rare, epic, legendary }

class Badge {
  const Badge({
    required this.id,
    required this.title,
    required this.description,
    required this.rarity,
    required this.color,
  });

  final String id;
  final String title;
  final String description;
  final BadgeRarity rarity;
  final Color color;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'title': title,
        'description': description,
        'rarity': rarity.name,
      'color': color.toARGB32(),
      };

  factory Badge.fromJson(Map<String, Object?> json) {
    return Badge(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      rarity: BadgeRarity.values.byName(json['rarity'] as String? ?? 'common'),
      color: Color((json['color'] as int?) ?? 0xFF00ACC1),
    );
  }
}