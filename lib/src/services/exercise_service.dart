import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../models/challenge_config.dart';
import 'pose_detection_service.dart';

abstract class ExerciseStrategy {
  Stream<int> get repStream;
  CameraController? get cameraController => null;
  Future<void> start();
  Future<void> stop();
  void manualRep();
}

class ManualCountStrategy implements ExerciseStrategy {
  final StreamController<int> _repController = StreamController<int>.broadcast();

  @override
  Stream<int> get repStream => _repController.stream;

  @override
  CameraController? get cameraController => null;

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}

  @override
  void manualRep() {
    _repController.add(1);
  }
}

class AccelerometerStrategy implements ExerciseStrategy {
  final StreamController<int> _repController = StreamController<int>.broadcast();
  StreamSubscription<AccelerometerEvent>? _subscription;
  DateTime? _lastRep;
  double _baseline = 9.81;

  @override
  Stream<int> get repStream => _repController.stream;

  @override
  CameraController? get cameraController => null;

  @override
  Future<void> start() async {
    if (kIsWeb) return;
    try {
      _subscription = accelerometerEventStream().listen((event) {
        final magnitude = math.sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
        _baseline = (_baseline * 0.95) + (magnitude * 0.05);
        final now = DateTime.now();
        final gap = _lastRep == null ? const Duration(days: 1) : now.difference(_lastRep!);
        if ((magnitude - _baseline).abs() > 2.1 && gap > const Duration(milliseconds: 750)) {
          _lastRep = now;
          _repController.add(1);
        }
      });
    } catch (_) {
      _subscription = null;
    }
  }

  @override
  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  @override
  void manualRep() {
    _repController.add(1);
  }
}

class ExerciseService extends ChangeNotifier {
  ExerciseService();

  final StreamController<int> _repController = StreamController<int>.broadcast();
  StreamSubscription<int>? _strategySubscription;
  ExerciseStrategy? _strategy;
  ChallengeType _type = ChallengeType.manual;
  String _statusMessage = 'Ready.';

  Stream<int> get repStream => _repController.stream;
  ChallengeType get challengeType => _type;
  CameraController? get cameraController => _strategy?.cameraController;
  String get statusMessage => _statusMessage;

  Future<void> start(ChallengeType type) async {
    await stop();
    _type = type;
    if (type == ChallengeType.manual) {
      _strategy = ManualCountStrategy();
      _statusMessage = 'Manual count ready.';
    } else if (_supportsPoseDetection(type)) {
      final poseStrategy = PoseDetectionStrategy(challengeType: type);
      await poseStrategy.start();
      if (poseStrategy.isReady) {
        _strategy = poseStrategy;
        _statusMessage = poseStrategy.statusMessage;
      } else {
        await poseStrategy.stop();
        _strategy = AccelerometerStrategy();
        _statusMessage = 'Camera unavailable. Using motion sensor.';
      }
    } else {
      _strategy = AccelerometerStrategy();
      _statusMessage = 'Motion sensor active.';
    }
    if (_strategy is! PoseDetectionStrategy) {
      await _strategy!.start();
    }
    await _strategySubscription?.cancel();
    _strategySubscription = _strategy!.repStream.listen(_repController.add);
    notifyListeners();
  }

  Future<void> stop() async {
    await _strategySubscription?.cancel();
    _strategySubscription = null;
    await _strategy?.stop();
    _strategy = null;
    _statusMessage = 'Ready.';
    notifyListeners();
  }

  void manualRep() {
    _strategy?.manualRep();
  }

  bool _supportsPoseDetection(ChallengeType type) {
    return !kIsWeb && (Platform.isAndroid || Platform.isIOS) && (type == ChallengeType.pushups || type == ChallengeType.squats);
  }

  bool get canUseAccelerometer => !kIsWeb && (Platform.isAndroid || Platform.isLinux || Platform.isWindows || Platform.isMacOS);
}