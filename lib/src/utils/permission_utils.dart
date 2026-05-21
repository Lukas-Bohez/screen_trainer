import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  static Future<bool> requestMotionAndNotifications() async {
    final motion = await Permission.activityRecognition.request();
    final notification = await Permission.notification.request();
    return motion.isGranted && notification.isGranted;
  }
}