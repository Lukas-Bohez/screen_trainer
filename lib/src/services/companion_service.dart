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
  final List<WebSocket> _sockets = <WebSocket>[];
  final Map<String, Completer<bool>> _pendingConfirms = <String, Completer<bool>>{};
  final List<Map<String, Object?>> _pendingRequests = <Map<String, Object?>>[];
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
      _sockets.add(socket);
      connectedCompanions.add(DiscoveredDevice(
        name: 'Companion',
        host: request.connectionInfo?.remoteAddress.address ?? 'local',
        port: _server!.port,
      ));
      notifyListeners();
      socket.listen((message) {
        try {
          final decoded = jsonDecode(message as String) as Map<String, Object?>;
          final type = decoded['type'] as String?;
          if (type == 'IMU_FRAME') {
            _mergedImuController.add(ImuFrame.fromJson(decoded));
          } else if (type == 'REMOTE_CONFIRM_RESPONSE') {
            final requestId = decoded['requestId'] as String?;
            final granted = decoded['granted'] as bool? ?? false;
            if (requestId != null && _pendingConfirms.containsKey(requestId)) {
              _pendingConfirms.remove(requestId)?.complete(granted);
            }
          } else if (decoded['type'] == 'REMOTE_CONFIRM') {
            // Client received a remote confirm request — queue it for UI
            final req = Map<String, Object?>.from(decoded);
            _pendingRequests.add(req);
            notifyListeners();
          }
        } catch (_) {}
      }, onDone: () {
        _sockets.remove(socket);
        connectedCompanions.removeWhere((device) => device.host == request.connectionInfo?.remoteAddress.address);
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
    _sockets.clear();
    notifyListeners();
  }

  /// Companion-side: respond to a remote confirm request (client role)
  Future<void> respondToRemoteConfirm(String requestId, bool granted) async {
    final payload = jsonEncode(<String, Object?>{'type': 'REMOTE_CONFIRM_RESPONSE', 'requestId': requestId, 'granted': granted});
    try {
      if (_channel != null) {
        _channel?.sink.add(payload);
      }
      for (final s in List<WebSocket>.from(_sockets)) {
        try {
          s.add(payload);
        } catch (_) {}
      }
    } catch (_) {}
    _pendingRequests.removeWhere((r) => r['requestId'] == requestId);
    notifyListeners();
  }

  List<Map<String, Object?>> get pendingRequests => List<Map<String, Object?>>.unmodifiable(_pendingRequests);
  

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
        } else if (decoded['type'] == 'REMOTE_CONFIRM') {
          // Auto-respond for now: accept the request and send response back
          final requestId = decoded['requestId'] as String? ?? '';
          _channel?.sink.add(jsonEncode(<String, Object?>{'type': 'REMOTE_CONFIRM_RESPONSE', 'requestId': requestId, 'granted': true}));
        }
      } catch (_) {}
    }, onDone: _scheduleReconnect, onError: (_) => _scheduleReconnect());
    notifyListeners();
  }

  /// Request remote confirmation from connected companions. Returns true if any companion grants.
  Future<bool> requestRemoteConfirm(String profileId, {String reason = 'Confirm action'}) async {
    if (_sockets.isEmpty) return false;
    final requestId = DateTime.now().millisecondsSinceEpoch.toString();
    final completer = Completer<bool>();
    _pendingConfirms[requestId] = completer;
    final payload = jsonEncode(<String, Object?>{'type': 'REMOTE_CONFIRM', 'requestId': requestId, 'profileId': profileId, 'reason': reason});
    for (final s in List<WebSocket>.from(_sockets)) {
      try {
        s.add(payload);
      } catch (_) {}
    }
    // Wait for response with timeout
    try {
      final granted = await completer.future.timeout(const Duration(seconds: 20));
      return granted;
    } catch (_) {
      _pendingConfirms.remove(requestId);
      return false;
    }
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