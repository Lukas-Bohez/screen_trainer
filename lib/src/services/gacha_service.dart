import 'dart:math';

import 'package:flutter/material.dart';

import '../models/gacha_item.dart';
import 'settings_repository.dart';

class GachaService extends ChangeNotifier {
  GachaService(this.settingsRepository) {
    _seedPools();
  }

  final SettingsRepository settingsRepository;
  final Random _random = Random();
  final Map<GachaTrack, int> _pity = <GachaTrack, int>{
    GachaTrack.curtain: 0,
    GachaTrack.theme: 0,
  };
  final Set<String> _ownedIds = <String>{};
  final List<GachaItem> _inventory = <GachaItem>[];
  List<GachaItem> _curtainPool = <GachaItem>[];
  List<ThemeItem> _themePool = <ThemeItem>[];
  GachaItem? _activeCurtain;
  ThemeItem? _activeTheme;
  int _repCoins = 120;
  int _fabricScraps = 0;
  int _dyeVials = 0;

  int get repCoins => _repCoins;
  int get fabricScraps => _fabricScraps;
  int get dyeVials => _dyeVials;
  GachaItem? get activeCurtain => _activeCurtain;
  ThemeItem? get activeTheme => _activeTheme;
  List<GachaItem> get ownedItems => List<GachaItem>.unmodifiable(_inventory);
  int pityCounter(GachaTrack track) => _pity[track] ?? 0;

  void _seedPools() {
    _curtainPool = <GachaItem>[
      const GachaItem(id: 'curtain-common-teal', name: 'Teal Drape', rarity: GachaRarity.common, track: GachaTrack.curtain, assetPath: '', isAnimated: false, color: Color(0xFF00ACC1)),
      const GachaItem(id: 'curtain-rare-stripe', name: 'Stripe Curtain', rarity: GachaRarity.rare, track: GachaTrack.curtain, assetPath: '', isAnimated: false, color: Color(0xFF00796B)),
      const GachaItem(id: 'curtain-epic-rain', name: 'Rain Curtain', rarity: GachaRarity.epic, track: GachaTrack.curtain, assetPath: '', isAnimated: true, color: Color(0xFF0097A7)),
      const GachaItem(id: 'curtain-legendary-foil', name: 'Foil Curtain', rarity: GachaRarity.legendary, track: GachaTrack.curtain, assetPath: '', isAnimated: true, color: Color(0xFFFFD54F)),
    ];
    _themePool = <ThemeItem>[
      ThemeItem(id: 'theme-common-ocean', name: 'Ocean', rarity: GachaRarity.common, track: GachaTrack.theme, assetPath: '', isAnimated: false, color: const Color(0xFF0277BD), colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0277BD))),
      ThemeItem(id: 'theme-rare-dusk', name: 'Dusk', rarity: GachaRarity.rare, track: GachaTrack.theme, assetPath: '', isAnimated: false, color: const Color(0xFF37474F), colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF37474F))),
      ThemeItem(id: 'theme-epic-aurora', name: 'Aurora', rarity: GachaRarity.epic, track: GachaTrack.theme, assetPath: '', isAnimated: true, color: const Color(0xFF00838F), colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00838F))),
      ThemeItem(id: 'theme-legendary-neon', name: 'Neon Tokyo', rarity: GachaRarity.legendary, track: GachaTrack.theme, assetPath: '', isAnimated: true, color: const Color(0xFF8E24AA), colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8E24AA))),
    ];
    _activeCurtain = _curtainPool.first;
    _activeTheme = _themePool.first;
    _ownedIds
      ..add(_activeCurtain!.id)
      ..add(_activeTheme!.id);
    _inventory
      ..add(_activeCurtain!)
      ..add(_activeTheme!);
  }

  void addRepCoins(int amount) {
    _repCoins += amount;
    notifyListeners();
  }

  bool spendCoins(int amount) {
    if (_repCoins < amount) return false;
    _repCoins -= amount;
    notifyListeners();
    return true;
  }

  int convertDuplicate(GachaItem item) {
    final scrapValue = switch (item.rarity) {
      GachaRarity.common => 1,
      GachaRarity.rare => 2,
      GachaRarity.epic => 5,
      GachaRarity.legendary => 10,
    };
    if (item.track == GachaTrack.curtain) {
      _fabricScraps += scrapValue;
    } else {
      _dyeVials += scrapValue;
    }
    return scrapValue;
  }

  Future<List<GachaItem>> pullSingle(GachaTrack track) async {
    if (!spendCoins(10)) return <GachaItem>[];
    final item = _roll(track);
    _awardItem(item);
    return <GachaItem>[item];
  }

  Future<List<GachaItem>> pullTen(GachaTrack track) async {
    if (!spendCoins(90)) return <GachaItem>[];
    final items = <GachaItem>[];
    for (var index = 0; index < 10; index += 1) {
      final item = index == 9 ? _roll(track, guaranteeLegendary: true) : _roll(track);
      _awardItem(item);
      items.add(item);
    }
    return items;
  }

  void _awardItem(GachaItem item) {
    _pity[item.track] = 0;
    final duplicate = _ownedIds.contains(item.id);
    if (duplicate) {
      convertDuplicate(item);
    } else {
      _ownedIds.add(item.id);
      _inventory.add(item);
    }
    if (item.track == GachaTrack.curtain) {
      _activeCurtain = item;
    } else if (item is ThemeItem) {
      _activeTheme = item;
    }
    notifyListeners();
  }

  GachaItem _roll(GachaTrack track, {bool guaranteeLegendary = false}) {
    final pool = track == GachaTrack.curtain ? _curtainPool : _themePool;
    final pity = _pity[track] ?? 0;
    _pity[track] = pity + 1;

    if (guaranteeLegendary || pity >= 80) {
      return pool.firstWhere((item) => item.rarity == GachaRarity.legendary);
    }

    final roll = _random.nextDouble();
    final pityBonus = pity >= 65 ? ((pity - 64) * 0.01).clamp(0, 0.20) : 0.0;
    final legendaryChance = 0.03 + pityBonus;
    final epicChance = 0.12;
    final rareChance = 0.25;
    if (roll < legendaryChance) {
      return pool.firstWhere((item) => item.rarity == GachaRarity.legendary);
    }
    if (roll < legendaryChance + epicChance) {
      return pool.firstWhere((item) => item.rarity == GachaRarity.epic);
    }
    if (roll < legendaryChance + epicChance + rareChance) {
      return pool.firstWhere((item) => item.rarity == GachaRarity.rare);
    }
    return pool.firstWhere((item) => item.rarity == GachaRarity.common);
  }

  void setActiveCurtain(GachaItem item) {
    _activeCurtain = item;
    if (!_ownedIds.contains(item.id)) {
      _ownedIds.add(item.id);
      _inventory.add(item);
    }
    notifyListeners();
  }

  void setActiveTheme(ThemeItem item) {
    _activeTheme = item;
    if (!_ownedIds.contains(item.id)) {
      _ownedIds.add(item.id);
      _inventory.add(item);
    }
    notifyListeners();
  }
}