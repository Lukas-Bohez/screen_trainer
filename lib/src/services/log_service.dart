import 'package:flutter/foundation.dart';

class LogService extends ChangeNotifier {
  void debug(String message) {
    if (kDebugMode) {
      debugPrint('[ScreenTrainer] $message');
    }
  }
}