import 'challenge_config.dart';

class Profile {
  const Profile({
    required this.id,
    required this.name,
    required this.challengeConfig,
    required this.isChild,
    required this.streak,
    required this.xp,
    required this.totalReps,
    required this.badgeIds,
  });

  final String id;
  final String name;
  final ChallengeConfig challengeConfig;
  final bool isChild;
  final int streak;
  final int xp;
  final int totalReps;
  final List<String> badgeIds;

  Profile copyWith({
    String? id,
    String? name,
    ChallengeConfig? challengeConfig,
    bool? isChild,
    int? streak,
    int? xp,
    int? totalReps,
    List<String>? badgeIds,
  }) {
    return Profile(
      id: id ?? this.id,
      name: name ?? this.name,
      challengeConfig: challengeConfig ?? this.challengeConfig,
      isChild: isChild ?? this.isChild,
      streak: streak ?? this.streak,
      xp: xp ?? this.xp,
      totalReps: totalReps ?? this.totalReps,
      badgeIds: badgeIds ?? this.badgeIds,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'name': name,
        'challengeConfig': challengeConfig.toJson(),
        'isChild': isChild,
        'streak': streak,
        'xp': xp,
        'totalReps': totalReps,
        'badgeIds': badgeIds,
      };

  factory Profile.fromJson(Map<String, Object?> json) {
    return Profile(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Profile',
      challengeConfig: ChallengeConfig.fromJson(
        Map<String, Object?>.from(json['challengeConfig'] as Map? ?? const {}),
      ),
      isChild: json['isChild'] as bool? ?? false,
      streak: (json['streak'] as int?) ?? 0,
      xp: (json['xp'] as int?) ?? 0,
      totalReps: (json['totalReps'] as int?) ?? 0,
      badgeIds: List<String>.from(json['badgeIds'] as List? ?? const []),
    );
  }

  static Profile createDefault() {
    return Profile(
      id: 'default',
      name: 'Configurator',
      challengeConfig: ChallengeConfig.defaults,
      isChild: false,
      streak: 0,
      xp: 0,
      totalReps: 0,
      badgeIds: const <String>[],
    );
  }
}