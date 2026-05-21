import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

class PlatformUtils {
  static bool get isDesktop =>
      !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

  static bool get isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  static Future<bool> isAndroidTV() async {
    if (kIsWeb || !Platform.isAndroid) {
      return false;
    }
    return false;
  }
}