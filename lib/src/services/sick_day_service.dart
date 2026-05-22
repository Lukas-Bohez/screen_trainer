import 'package:local_auth/local_auth.dart';
import '../models/profile.dart';
import 'companion_service.dart';

enum SickDayOption { skipSession, reduceTargetReps, streakFreeze }

class SickDayService {
  final LocalAuthentication _auth = LocalAuthentication();
  // companion reference not stored permanently

  bool canSkip(Profile profile) => !profile.isChild;

  String explanation(Profile profile) {
    if (profile.isChild) {
      return 'A grown-up manages this profile, so skipping takes an extra confirmation.';
    }
    return 'Adult profiles can use a protected skip path after confirming the choice.';
  }

  /// Authenticate the user for a protected skip. Uses biometrics or device auth.
  Future<bool> authenticateForSkip() async {
    try {
      final available = await _auth.isDeviceSupported();
      if (!available) return false;
      final didAuth = await _auth.authenticate(
        localizedReason: 'Confirm to skip this session',
        options: const AuthenticationOptions(biometricOnly: false, stickyAuth: false),
      );
      return didAuth;
    } catch (_) {
      return false;
    }
  }

  /// Request a remote confirmation via CompanionService if available.
  Future<bool> requestRemoteConfirm(CompanionService companionService, String profileId) async {
    try {
      return await companionService.requestRemoteConfirm(profileId, reason: 'Allow sick day skip?');
    } catch (_) {
      return false;
    }
  }
}