import '../models/profile.dart';

class SickDayService {
  bool canSkip(Profile profile) => !profile.isChild;

  String explanation(Profile profile) {
    if (profile.isChild) {
      return 'This profile is managed by a configurator and uses a more deliberate skip path.';
    }
    return 'Adult profiles can use a protected skip path after confirming the choice.';
  }
}