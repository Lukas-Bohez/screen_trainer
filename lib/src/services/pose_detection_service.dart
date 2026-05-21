import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show Size;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/challenge_config.dart';
import 'exercise_service.dart';

class PoseDetectionStrategy implements ExerciseStrategy {
  PoseDetectionStrategy({required this.challengeType});

  final ChallengeType challengeType;

  final StreamController<int> _repController = StreamController<int>.broadcast();
  CameraController? _cameraController;
  PoseDetector? _poseDetector;
  bool _busy = false;
  bool _isDown = false;
  DateTime? _lastRep;
  String _statusMessage = 'Preparing camera...';

  @override
  Stream<int> get repStream => _repController.stream;

  @override
  CameraController? get cameraController => _cameraController;

  String get statusMessage => _statusMessage;

  bool get isReady => _cameraController != null;

  @override
  Future<void> start() async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      _statusMessage = 'Camera pose detection is unavailable on this platform.';
      return;
    }

    final permission = await Permission.camera.request();
    if (!permission.isGranted) {
      _statusMessage = 'Camera permission denied.';
      return;
    }

    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      _statusMessage = 'No camera found.';
      return;
    }

    final selectedCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      selectedCamera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    await _cameraController!.initialize();
    _poseDetector = PoseDetector(options: PoseDetectorOptions(mode: PoseDetectionMode.stream));
    await _cameraController!.startImageStream(_processCameraImage);
    _statusMessage = challengeType == ChallengeType.pushups
        ? 'Pose detection active for push-ups.'
        : 'Pose detection active for squats.';
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_busy || _poseDetector == null || _cameraController == null) return;
    _busy = true;
    try {
      final inputImage = _toInputImage(image, _cameraController!.description);
      final poses = await _poseDetector!.processImage(inputImage);
      if (poses.isNotEmpty) {
        _analyzePose(poses.first);
      }
    } catch (_) {
      // Ignore frame-level failures and continue streaming.
    } finally {
      _busy = false;
    }
  }

  void _analyzePose(Pose pose) {
    final now = DateTime.now();
    final gap = _lastRep == null ? const Duration(days: 1) : now.difference(_lastRep!);
    if (gap < const Duration(milliseconds: 700)) {
      return;
    }

    final metric = challengeType == ChallengeType.pushups
        ? _elbowMetric(pose)
        : _kneeMetric(pose);

    if (metric == null) {
      return;
    }

    if (metric < 100) {
      _isDown = true;
    } else if (_isDown && metric > 155) {
      _isDown = false;
      _lastRep = now;
      _repController.add(1);
    }
  }

  double? _elbowMetric(Pose pose) {
    final left = _angleForTriplet(
      pose.landmarks[PoseLandmarkType.leftShoulder],
      pose.landmarks[PoseLandmarkType.leftElbow],
      pose.landmarks[PoseLandmarkType.leftWrist],
    );
    final right = _angleForTriplet(
      pose.landmarks[PoseLandmarkType.rightShoulder],
      pose.landmarks[PoseLandmarkType.rightElbow],
      pose.landmarks[PoseLandmarkType.rightWrist],
    );
    if (left == null && right == null) return null;
    if (left == null) return right;
    if (right == null) return left;
    return (left + right) / 2;
  }

  double? _kneeMetric(Pose pose) {
    final left = _angleForTriplet(
      pose.landmarks[PoseLandmarkType.leftHip],
      pose.landmarks[PoseLandmarkType.leftKnee],
      pose.landmarks[PoseLandmarkType.leftAnkle],
    );
    final right = _angleForTriplet(
      pose.landmarks[PoseLandmarkType.rightHip],
      pose.landmarks[PoseLandmarkType.rightKnee],
      pose.landmarks[PoseLandmarkType.rightAnkle],
    );
    if (left == null && right == null) return null;
    if (left == null) return right;
    if (right == null) return left;
    return (left + right) / 2;
  }

  double? _angleForTriplet(PoseLandmark? a, PoseLandmark? b, PoseLandmark? c) {
    if (a == null || b == null || c == null) {
      return null;
    }
    final ab = _vector(a, b);
    final cb = _vector(c, b);
    final dot = (ab.$1 * cb.$1) + (ab.$2 * cb.$2);
    final magnitude = math.sqrt((ab.$1 * ab.$1) + (ab.$2 * ab.$2)) * math.sqrt((cb.$1 * cb.$1) + (cb.$2 * cb.$2));
    if (magnitude == 0) {
      return null;
    }
    final cosine = (dot / magnitude).clamp(-1.0, 1.0);
    return math.acos(cosine) * 180 / math.pi;
  }

  (double, double) _vector(PoseLandmark from, PoseLandmark to) {
    return (from.x - to.x, from.y - to.y);
  }

  InputImage _toInputImage(CameraImage image, CameraDescription description) {
    final bytesBuilder = BytesBuilder();
    for (final plane in image.planes) {
      bytesBuilder.add(plane.bytes);
    }
    final bytes = bytesBuilder.toBytes();
    final inputImageData = InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: InputImageRotationValue.fromRawValue(description.sensorOrientation) ?? InputImageRotation.rotation0deg,
      format: InputImageFormatValue.fromRawValue(image.format.raw) ?? InputImageFormat.nv21,
      bytesPerRow: image.planes.first.bytesPerRow,
    );
    return InputImage.fromBytes(bytes: bytes, metadata: inputImageData);
  }

  @override
  Future<void> stop() async {
    await _cameraController?.stopImageStream();
    await _cameraController?.dispose();
    _cameraController = null;
    await _poseDetector?.close();
    _poseDetector = null;
    _busy = false;
    _isDown = false;
  }

  @override
  void manualRep() {
    _repController.add(1);
  }
}