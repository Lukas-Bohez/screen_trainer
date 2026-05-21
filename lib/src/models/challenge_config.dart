enum ChallengeType { manual, pushups, squats, plank, steps }

class ChallengeConfig {
  const ChallengeConfig({
    required this.challengeType,
    required this.targetReps,
    required this.cooldownMinutes,
  });

  final ChallengeType challengeType;
  final int targetReps;
  final int cooldownMinutes;

  ChallengeConfig copyWith({
    ChallengeType? challengeType,
    int? targetReps,
    int? cooldownMinutes,
  }) {
    return ChallengeConfig(
      challengeType: challengeType ?? this.challengeType,
      targetReps: targetReps ?? this.targetReps,
      cooldownMinutes: cooldownMinutes ?? this.cooldownMinutes,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'challengeType': challengeType.name,
        'targetReps': targetReps,
        'cooldownMinutes': cooldownMinutes,
      };

  factory ChallengeConfig.fromJson(Map<String, Object?> json) {
    return ChallengeConfig(
      challengeType: ChallengeType.values
          .byName(json['challengeType'] as String? ?? 'manual'),
      targetReps: (json['targetReps'] as int?) ?? 10,
      cooldownMinutes: (json['cooldownMinutes'] as int?) ?? 30,
    );
  }

  static const defaults = ChallengeConfig(
    challengeType: ChallengeType.manual,
    targetReps: 10,
    cooldownMinutes: 30,
  );
}