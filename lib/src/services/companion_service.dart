import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/imu_frame.dart';

enum DeviceRole { primary, companion }

class DiscoveredDevice {
  const DiscoveredDevice({required this.name, required this.host, required this.port});

  final String name;
  final String host;
  final int port;
}

class SessionConfig {
  const SessionConfig({required this.exercise, required this.targetReps, required this.sessionId});

  final String exercise;
  final int targetReps;
  final String sessionId;

  Map<String, Object?> toJson() => <String, Object?>{
        'exercise': exercise,
        'targetReps': targetReps,
        'sessionId': sessionId,
      };
}

class CompanionService extends ChangeNotifier {
  CompanionService();

  DeviceRole role = DeviceRole.primary;
  final List<DiscoveredDevice> nearbyPrimaries = <DiscoveredDevice>[];
  final List<DiscoveredDevice> connectedCompanions = <DiscoveredDevice>[];
  final StreamController<ImuFrame> _mergedImuController = StreamController<ImuFrame>.broadcast();
  HttpServer? _server;
  WebSocketChannel? _channel;
  Timer? _pingTimer;
  int _reconnectAttempts = 0;
  SessionConfig? _sessionConfig;
  String? _localHost;

  Stream<ImuFrame> get mergedImuStream => _mergedImuController.stream;
  int get activeCompanionCount => connectedCompanions.length;

  String get pairingQrData {
    if (_server == null || _localHost == null || _sessionConfig == null) return '';
    return 'screentrainer://pair?host=$_localHost&port=${_server!.port}&session=${_sessionConfig!.sessionId}';
  }

  Future<void> startAdvertising(SessionConfig config) async {
    await stopAdvertising();
    role = DeviceRole.primary;
    _sessionConfig = config;
    _server = await HttpServer.bind(InternetAddress.anyIPv4, 0, shared: true);
    _localHost = InternetAddress.loopbackIPv4.address;
    _server!.listen((request) async {
      if (!WebSocketTransformer.isUpgradeRequest(request)) {
        request.response
          ..statusCode = HttpStatus.badRequest
          ..write('WebSocket required')
          ..close();
        return;
      }
      final socket = await WebSocketTransformer.upgrade(request);
      connectedCompanions.add(DiscoveredDevice(
        name: 'Companion',
        host: request.connectionInfo?.remoteAddress.address ?? 'local',
        port: _server!.port,
      ));
      notifyListeners();
      socket.listen((message) {
        try {
          final decoded = jsonDecode(message as String) as Map<String, Object?>;
          if (decoded['type'] == 'IMU_FRAME') {
            _mergedImuController.add(ImuFrame.fromJson(decoded));
          }
        } catch (_) {}
      }, onDone: () {
        connectedCompanions.removeWhere((device) => device.port == _server!.port);
        notifyListeners();
      });
    });
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      _channel?.sink.add(jsonEncode(<String, Object?>{'type': 'PING'}));
    });
    notifyListeners();
  }

  Future<void> stopAdvertising() async {
    _pingTimer?.cancel();
    _pingTimer = null;
    await _channel?.sink.close();
    _channel = null;
    await _server?.close(force: true);
    _server = null;
    _sessionConfig = null;
    connectedCompanions.clear();
    notifyListeners();
  }

  Future<void> connectTo(DiscoveredDevice device) async {
    await _connect(Uri.parse('ws://${device.host}:${device.port}'));
  }

  Future<void> connectToManualIp(String host, int port) async {
    await _connect(Uri.parse('ws://$host:$port'));
  }

  Future<void> _connect(Uri uri) async {
    role = DeviceRole.companion;
    _reconnectAttempts = 0;
    _channel = IOWebSocketChannel.connect(uri);
    _channel!.stream.listen((message) {
      try {
        final decoded = jsonDecode(message as String) as Map<String, Object?>;
        if (decoded['type'] == 'SESSION_CONFIG') {
          _sessionConfig = SessionConfig(
            exercise: decoded['exercise'] as String? ?? 'manual',
            targetReps: (decoded['targetReps'] as int?) ?? 10,
            sessionId: decoded['sessionId'] as String? ?? '',
          );
        }
      } catch (_) {}
    }, onDone: _scheduleReconnect, onError: (_) => _scheduleReconnect());
    notifyListeners();
  }

  void _scheduleReconnect() {
    if (role != DeviceRole.companion) return;
    _reconnectAttempts += 1;
    final delay = Duration(seconds: _reconnectAttempts.clamp(1, 5));
    Future.delayed(delay, () {
      if (_channel == null) return;
    });
  }

  Future<void> startStreaming() async {
    if (role != DeviceRole.companion) return;
    _channel?.sink.add(jsonEncode(<String, Object?>{
      'type': 'HELLO',
      'deviceName': Platform.localHostname,
      'capabilities': <String>['accel', 'gyro'],
    }));
  }

  Future<void> sendFrame(ImuFrame frame) async {
    _channel?.sink.add(jsonEncode(<String, Object?>{
      'type': 'IMU_FRAME',
      ...frame.toJson(),
    }));
  }

  Future<void> disconnect() async {
    _pingTimer?.cancel();
    await _channel?.sink.close();
    _channel = null;
    role = DeviceRole.primary;
    notifyListeners();
  }
}