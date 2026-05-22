import 'dart:async';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import '../models/challenge_config.dart';
import '../models/gacha_item.dart';
import '../models/profile.dart';
import '../models/schedule_window.dart';
import '../services/companion_service.dart';
import '../services/exercise_service.dart';
import '../services/gamification_service.dart';
import '../services/gacha_service.dart';
import '../services/log_service.dart';
import '../services/overlay_service.dart';
import '../services/notification_service.dart';
import '../services/review_service.dart';
import '../services/settings_repository.dart';
import '../state/curtain_state.dart';
import '../theme/app_theme.dart' show ThemeService;

class ScreenTrainerController extends ChangeNotifier {
  ScreenTrainerController({
    required this.settingsRepository,
    required this.themeService,
    required this.gamificationService,
    required this.exerciseService,
    required this.gachaService,
    required this.companionService,
    required this.overlayService,
    required this.notificationService,
    required this.logService,
  });

  final SettingsRepository settingsRepository;
  final ThemeService themeService;
  final GamificationService gamificationService;
  final ExerciseService exerciseService;
  final GachaService gachaService;
  final CompanionService companionService;
  final OverlayService overlayService;
  final NotificationService notificationService;
  final LogService logService;

  CurtainState _curtainState = CurtainState.locked;
  int _currentTab = 0;
  int _completedReps = 0;
  bool _ready = false;
  Timer? _cooldownTimer;
  StreamSubscription<int>? _repSubscription;
  StreamSubscription<OverlayScreenState>? _screenStateSubscription;
  String? _statusMessage;

  CurtainState get curtainState => _curtainState;
  int get currentTab => _currentTab;
  int get completedReps => _completedReps;
  bool get ready => _ready;
  String? get statusMessage => _statusMessage;
  Profile? get activeProfile => settingsRepository.activeProfile;
  List<Profile> get profiles => settingsRepository.profiles;
  ThemeMode get themeMode => themeService.themeMode;
  int get targetReps => activeProfile?.challengeConfig.targetReps ?? ChallengeConfig.defaults.targetReps;
  int get cooldownMinutes => settingsRepository.cooldownMinutes;
  List<ScheduleWindow> get scheduleWindows => settingsRepository.scheduleWindows;
  CameraController? get cameraController => exerciseService.cameraController;
  String? get exerciseStatus => exerciseService.statusMessage;

  Future<void> init() async {
    await settingsRepository.load();
    await notificationService.initialize();
    themeService.setThemeMode(settingsRepository.themeMode);
    if (gachaService.activeTheme != null) {
      themeService.setActiveTheme(gachaService.activeTheme);
    }
    _ready = true;
    if (settingsRepository.activeProfile == null && settingsRepository.profiles.isNotEmpty) {
      await settingsRepository.setActiveProfileId(settingsRepository.profiles.first.id);
    }
    if (settingsRepository.profiles.isEmpty) {
      _statusMessage = 'Create a profile to begin.';
    }
    await _screenStateSubscription?.cancel();
    _screenStateSubscription = overlayService.screenStateStream.listen((state) {
      if (state == OverlayScreenState.screenOn && _curtainState == CurtainState.pendingReveal) {
        unawaited(openScreen());
      }
    });
    notifyListeners();
  }

  void selectTab(int index) {
    if (_currentTab == index) return;
    _currentTab = index;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await settingsRepository.setThemeMode(mode);
    themeService.setThemeMode(mode);
  }

  Future<void> setCooldownMinutes(int minutes) async {
    await settingsRepository.setCooldownMinutes(minutes);
  }

  Future<void> addProfile(Profile profile) async {
    await settingsRepository.upsertProfile(profile);
    if (settingsRepository.activeProfileId == null) {
      await settingsRepository.setActiveProfileId(profile.id);
    }
    notifyListeners();
  }

  Future<void> removeProfile(String id) async {
    await settingsRepository.removeProfile(id);
    notifyListeners();
  }

  Future<void> setActiveProfile(String id) async {
    await settingsRepository.setActiveProfileId(id);
    notifyListeners();
  }

  Future<void> updateProfile(Profile profile) async {
    await settingsRepository.upsertProfile(profile);
    notifyListeners();
  }

  Future<void> addScheduleWindow(ScheduleWindow window) async {
    final windows = List<ScheduleWindow>.from(settingsRepository.scheduleWindows)..add(window);
    await settingsRepository.saveScheduleWindows(windows);
    notifyListeners();
  }

  Future<void> deleteScheduleWindow(int index) async {
    final windows = List<ScheduleWindow>.from(settingsRepository.scheduleWindows)..removeAt(index);
    await settingsRepository.saveScheduleWindows(windows);
    notifyListeners();
  }

  Future<void> startChallenge() async {
    final profile = activeProfile;
    if (profile == null) {
      _statusMessage = 'Create a profile first.';
      notifyListeners();
      return;
    }
    _completedReps = 0;
    _curtainState = CurtainState.unlocking;
    _statusMessage = 'Challenge started.';
    await exerciseService.start(profile.challengeConfig.challengeType);
    await overlayService.showOverlay();
    await _repSubscription?.cancel();
    _repSubscription = exerciseService.repStream.listen((count) {
      _handleRep(count);
    });
    notifyListeners();
  }

  void manualRep() {
    exerciseService.manualRep();
  }

  Future<void> lockScreen() async {
    _curtainState = CurtainState.locked;
    _completedReps = 0;
    _statusMessage = 'Screen locked.';
    await exerciseService.stop();
    await _repSubscription?.cancel();
    _repSubscription = null;
    _cooldownTimer?.cancel();
    await overlayService.showOverlay();
    notifyListeners();
  }

  Future<void> completeChallenge() async {
    _curtainState = CurtainState.pendingReveal;
    _statusMessage = 'Challenge complete. Wake the screen to reveal it.';
    await exerciseService.stop();
    await _repSubscription?.cancel();
    _repSubscription = null;
    final profile = activeProfile;
    if (profile != null) {
      final updated = gamificationService.awardChallenge(profile, completedReps: _completedReps);
      await settingsRepository.upsertProfile(updated.copyWith(streak: profile.streak + 1));
    }
    if (gachaService.repCoins >= 10) {
      _statusMessage = 'You can pull a reward now.';
    }
    _startCooldownTimer();
    notifyListeners();
    await notificationService.show(
      'ScreenTrainer',
      'Challenge complete. Open the screen to collect your reward.',
    );
    await ReviewService.maybePromptReview();
    if (await overlayService.isScreenOn()) {
      await openScreen();
    }
  }

  Future<void> openScreen() async {
    _curtainState = CurtainState.open;
    _statusMessage = 'Screen open.';
    await overlayService.hideOverlay();
    notifyListeners();
  }

  Future<void> setActiveTheme(GachaItem item) async {
    if (item is ThemeItem) {
      gachaService.setActiveTheme(item);
      themeService.setActiveTheme(item);
      notifyListeners();
    }
  }

  Future<void> setActiveCurtain(GachaItem item) async {
    gachaService.setActiveCurtain(item);
    notifyListeners();
  }

  Future<void> pullSingle(GachaTrack track) async {
    final items = await gachaService.pullSingle(track);
    if (items.isEmpty) {
      _statusMessage = 'Not enough coins for a pull.';
      notifyListeners();
      return;
    }
    final item = items.first;
    if (item is ThemeItem) {
      themeService.setActiveTheme(item);
    }
    _statusMessage = 'Pulled ${item.name}.';
    notifyListeners();
    await ReviewService.maybePromptReview();
  }

  Future<void> pullTen(GachaTrack track) async {
    final items = await gachaService.pullTen(track);
    if (items.isEmpty) {
      _statusMessage = 'Not enough coins for a 10-pull.';
      notifyListeners();
      return;
    }
    _statusMessage = 'Pulled ${items.length} items.';
    notifyListeners();
    await ReviewService.maybePromptReview();
  }

  void _handleRep(int count) {
    _completedReps += count;
    final profile = activeProfile;
    if (profile != null) {
      final updatedProfile = gamificationService.awardRep(
        profile,
        multiplier: companionService.activeCompanionCount > 0 ? 10 : 1,
      );
      settingsRepository.upsertProfile(
        updatedProfile.copyWith(streak: profile.streak),
      );
    }
    gachaService.addRepCoins(10 * count);
    _statusMessage = 'Rep $_completedReps of $targetReps.';
    if (_completedReps >= targetReps) {
      completeChallenge();
    } else {
      notifyListeners();
    }
  }

  void _startCooldownTimer() {
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer(Duration(minutes: cooldownMinutes), () {
      _curtainState = CurtainState.cooldown;
      _statusMessage = 'Cooldown finished. The curtain can lock again.';
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _repSubscription?.cancel();
    _screenStateSubscription?.cancel();
    exerciseService.stop();
    super.dispose();
  }
}