import 'dart:async';
import 'dart:isolate';
import 'dart:math' as math;

import '../models/imu_frame.dart';
import '../models/rep_event.dart';

class MovementAnalysisResult {
  const MovementAnalysisResult({required this.repDetected, required this.intensity});

  final bool repDetected;
  final double intensity;
}

class MovementAnalyser {
  MovementAnalyser();

  final List<ImuFrame> _window = <ImuFrame>[];
  bool _running = false;
  final StreamController<RepEvent> _repController = StreamController<RepEvent>.broadcast();
  final StreamController<double> _intensityController = StreamController<double>.broadcast();

  Stream<RepEvent> get repStream => _repController.stream;
  Stream<double> get intensityStream => _intensityController.stream;

  Future<void> ingestFrame(ImuFrame frame) async {
    _window.add(frame);
    if (_window.length > 40) {
      _window.removeAt(0);
    }
    if (_running) return;
    _running = true;
    final snapshot = List<ImuFrame>.from(_window);
    final result = await Isolate.run(() => _analyse(snapshot));
    _intensityController.add(result.intensity);
    if (result.repDetected) {
      _repController.add(RepEvent(
        count: 1,
        intensity: result.intensity,
        timestamp: DateTime.now(),
      ));
    }
    _running = false;
  }

  void reset() {
    _window.clear();
  }

  static MovementAnalysisResult _analyse(List<ImuFrame> frames) {
    if (frames.isEmpty) {
      return const MovementAnalysisResult(repDetected: false, intensity: 0);
    }
    double total = 0;
    double peak = 0;
    for (final frame in frames) {
      final magnitude = math.sqrt(
        frame.ax * frame.ax +
            frame.ay * frame.ay +
            frame.az * frame.az,
      );
      final intensity = (magnitude - 9.81).abs();
      total += intensity;
      if (intensity > peak) peak = intensity;
    }
    final average = total / frames.length;
    final repDetected = peak > 2.5 && average > 0.6;
    return MovementAnalysisResult(repDetected: repDetected, intensity: (average / 4).clamp(0, 1));
  }
}