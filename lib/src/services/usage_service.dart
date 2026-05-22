import 'dart:io' show Platform;
import 'package:flutter/services.dart';

class UsageService {
  static const MethodChannel _channel = MethodChannel('com.screentrainer/usage');

  Future<bool> hasUsagePermission() async {
    if (!Platform.isAndroid) return true;
    try {
      return await _channel.invokeMethod<bool>('hasUsagePermission') ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<int> getTodayUsageMs(String packageName) async {
    if (!Platform.isAndroid) return 0;
    try {
      final res = await _channel.invokeMethod<int>('getTodayUsageMs', {'packageName': packageName});
      return res ?? 0;
    } catch (_) {
      return 0;
    }
  }
}
