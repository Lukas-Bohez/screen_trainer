import '../models/schedule_window.dart';

class ScheduleService {
  bool isLockedNow(List<ScheduleWindow> windows, DateTime now) {
    return windows.any((window) => window.contains(now));
  }

  Duration? nextWindowDuration(List<ScheduleWindow> windows, DateTime now) {
    if (windows.isEmpty) return null;
    final locked = windows.any((window) => window.contains(now));
    if (!locked) return Duration.zero;
    return const Duration(minutes: 1);
  }
}