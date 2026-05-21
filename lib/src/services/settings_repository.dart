import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/challenge_config.dart';
import '../models/profile.dart';
import '../models/schedule_window.dart';

class SettingsRepository extends ChangeNotifier {
  static const _themeModeKey = 'theme_mode';
  static const _cooldownMinutesKey = 'cooldown_minutes';
  static const _profilesKey = 'profiles';
  static const _activeProfileIdKey = 'active_profile_id';
  static const _scheduleKey = 'schedule_windows';

  SharedPreferences? _prefs;

  ThemeMode themeMode = ThemeMode.system;
  int cooldownMinutes = 30;
  final List<Profile> profiles = <Profile>[];
  String? activeProfileId;
  final List<ScheduleWindow> scheduleWindows = <ScheduleWindow>[];

  Future<void> load() async {
    _prefs ??= await SharedPreferences.getInstance();
    final prefs = _prefs!;

    themeMode = ThemeMode.values.byName(prefs.getString(_themeModeKey) ?? 'system');
    cooldownMinutes = prefs.getInt(_cooldownMinutesKey) ?? 30;
    activeProfileId = prefs.getString(_activeProfileIdKey);

    profiles
      ..clear()
      ..addAll(_decodeProfiles(prefs.getStringList(_profilesKey) ?? const <String>[]));
    if (profiles.isEmpty) {
      profiles.add(Profile.createDefault());
      activeProfileId ??= profiles.first.id;
    }

    scheduleWindows
      ..clear()
      ..addAll(_decodeScheduleWindows(prefs.getStringList(_scheduleKey) ?? const <String>[]));

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode = mode;
    await _prefs?.setString(_themeModeKey, mode.name);
    notifyListeners();
  }

  Future<void> setCooldownMinutes(int minutes) async {
    cooldownMinutes = minutes;
    await _prefs?.setInt(_cooldownMinutesKey, minutes);
    notifyListeners();
  }

  Future<void> saveProfiles(List<Profile> nextProfiles) async {
    profiles
      ..clear()
      ..addAll(nextProfiles);
    await _prefs?.setStringList(
      _profilesKey,
      nextProfiles.map((profile) => jsonEncode(profile.toJson())).toList(),
    );
    notifyListeners();
  }

  Future<void> setActiveProfileId(String id) async {
    activeProfileId = id;
    await _prefs?.setString(_activeProfileIdKey, id);
    notifyListeners();
  }

  Future<void> saveScheduleWindows(List<ScheduleWindow> nextWindows) async {
    scheduleWindows
      ..clear()
      ..addAll(nextWindows);
    await _prefs?.setStringList(
      _scheduleKey,
      nextWindows.map((window) => jsonEncode(window.toJson())).toList(),
    );
    notifyListeners();
  }

  List<Profile> _decodeProfiles(List<String> raw) {
    return raw.map((entry) => Profile.fromJson(Map<String, Object?>.from(jsonDecode(entry) as Map))).toList();
  }

  List<ScheduleWindow> _decodeScheduleWindows(List<String> raw) {
    return raw.map((entry) => ScheduleWindow.fromJson(Map<String, Object?>.from(jsonDecode(entry) as Map))).toList();
  }

  Profile? get activeProfile {
    final id = activeProfileId;
    if (id == null) return profiles.isEmpty ? null : profiles.first;
    for (final profile in profiles) {
      if (profile.id == id) return profile;
    }
    return profiles.isEmpty ? null : profiles.first;
  }

  Future<void> upsertProfile(Profile profile) async {
    final index = profiles.indexWhere((entry) => entry.id == profile.id);
    if (index >= 0) {
      profiles[index] = profile;
    } else {
      profiles.add(profile);
    }
    await saveProfiles(List<Profile>.from(profiles));
  }

  Future<void> removeProfile(String id) async {
    profiles.removeWhere((profile) => profile.id == id);
    if (activeProfileId == id) {
      activeProfileId = profiles.isEmpty ? null : profiles.first.id;
      if (activeProfileId != null) {
        await _prefs?.setString(_activeProfileIdKey, activeProfileId!);
      }
    }
    await saveProfiles(List<Profile>.from(profiles));
  }

  Profile createProfileTemplate({required String name, bool isChild = false}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return Profile(
      id: '$name-$now',
      name: name,
      challengeConfig: const ChallengeConfig(
        challengeType: ChallengeType.manual,
        targetReps: 10,
        cooldownMinutes: 30,
      ),
      isChild: isChild,
      streak: 0,
      xp: 0,
      totalReps: 0,
      badgeIds: const <String>[],
    );
  }
}