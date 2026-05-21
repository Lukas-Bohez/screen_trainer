import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum OverlayScreenState { screenOn, screenOff }

class OverlayService {
  static const MethodChannel _channel = MethodChannel('com.screentrainer/overlay');
  static const EventChannel _screenStateChannel = EventChannel('com.screentrainer/screen_state');

  Stream<OverlayScreenState> get screenStateStream {
    if (kIsWeb || !Platform.isAndroid) {
      return const Stream<OverlayScreenState>.empty();
    }
    return _screenStateChannel.receiveBroadcastStream().map((event) {
      final value = event?.toString().toLowerCase();
      return value == 'screen_off' ? OverlayScreenState.screenOff : OverlayScreenState.screenOn;
    });
  }

  Future<void> showOverlay() async {
    try {
      await _channel.invokeMethod<void>('showOverlay');
    } catch (_) {}
  }

  Future<void> hideOverlay() async {
    try {
      await _channel.invokeMethod<void>('hideOverlay');
    } catch (_) {}
  }

  Future<bool> isOverlayShowing() async {
    try {
      return await _channel.invokeMethod<bool>('isOverlayShowing') ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> isScreenOn() async {
    try {
      return await _channel.invokeMethod<bool>('isScreenOn') ?? true;
    } catch (_) {
      return true;
    }
  }

  Future<void> requestOverlayPermission() async {
    try {
      await _channel.invokeMethod<void>('requestOverlayPermission');
    } catch (_) {}
  }

  Future<void> openAccessibilitySettings() async {
    try {
      await _channel.invokeMethod<void>('openAccessibilitySettings');
    } catch (_) {}
  }
}