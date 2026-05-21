class ScheduleWindow {
  const ScheduleWindow({
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
    required this.weekdays,
  });

  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;
  final List<int> weekdays;

  Map<String, Object?> toJson() => <String, Object?>{
        'startHour': startHour,
        'startMinute': startMinute,
        'endHour': endHour,
        'endMinute': endMinute,
        'weekdays': weekdays,
      };

  factory ScheduleWindow.fromJson(Map<String, Object?> json) {
    return ScheduleWindow(
      startHour: (json['startHour'] as int?) ?? 21,
      startMinute: (json['startMinute'] as int?) ?? 0,
      endHour: (json['endHour'] as int?) ?? 7,
      endMinute: (json['endMinute'] as int?) ?? 0,
      weekdays: List<int>.from(json['weekdays'] as List? ?? const [1, 2, 3, 4, 5]),
    );
  }

  bool contains(DateTime dateTime) {
    final weekday = dateTime.weekday;
    if (!weekdays.contains(weekday)) return false;
    final current = dateTime.hour * 60 + dateTime.minute;
    final start = startHour * 60 + startMinute;
    final end = endHour * 60 + endMinute;
    if (start <= end) {
      return current >= start && current <= end;
    }
    return current >= start || current <= end;
  }
}