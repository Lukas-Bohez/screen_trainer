import '../models/profile.dart';

class GamificationService {
  Profile awardRep(Profile profile, {int multiplier = 1}) {
    return profile.copyWith(
      xp: profile.xp + (10 * multiplier),
      totalReps: profile.totalReps + 1,
    );
  }

  Profile awardChallenge(Profile profile, {int completedReps = 0}) {
    final streakBonus = profile.streak >= 7 ? 2 : 1;
    return profile.copyWith(
      xp: profile.xp + (completedReps * 5 * streakBonus),
      totalReps: profile.totalReps + completedReps,
    );
  }

  Profile advanceStreak(Profile profile) {
    return profile.copyWith(streak: profile.streak + 1);
  }
}