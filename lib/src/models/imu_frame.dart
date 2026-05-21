class ImuFrame {
  const ImuFrame({
    required this.timestamp,
    required this.ax,
    required this.ay,
    required this.az,
    required this.gx,
    required this.gy,
    required this.gz,
  });

  final DateTime timestamp;
  final double ax;
  final double ay;
  final double az;
  final double gx;
  final double gy;
  final double gz;

  Map<String, Object?> toJson() => <String, Object?>{
        'timestamp': timestamp.millisecondsSinceEpoch,
        'ax': ax,
        'ay': ay,
        'az': az,
        'gx': gx,
        'gy': gy,
        'gz': gz,
      };

  factory ImuFrame.fromJson(Map<String, Object?> json) {
    return ImuFrame(
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (json['timestamp'] as num?)?.toInt() ?? 0,
      ),
      ax: (json['ax'] as num?)?.toDouble() ?? 0,
      ay: (json['ay'] as num?)?.toDouble() ?? 0,
      az: (json['az'] as num?)?.toDouble() ?? 0,
      gx: (json['gx'] as num?)?.toDouble() ?? 0,
      gy: (json['gy'] as num?)?.toDouble() ?? 0,
      gz: (json['gz'] as num?)?.toDouble() ?? 0,
    );
  }
}