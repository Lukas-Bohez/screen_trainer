import '../models/profile.dart';

class SickDayService {
  bool canSkip(Profile profile) => !profile.isChild;

  String explanation(Profile profile) {
    if (profile.isChild) {
      return 'A grown-up manages this profile, so skipping takes an extra confirmation.';
    }
    return 'Adult profiles can use a protected skip path after confirming the choice.';
  }
}