import 'package:flutter/widgets.dart';

import 'src/app.dart';
import 'src/services/review_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ReviewService.trackLaunch();
  runApp(const ScreenTrainerApp());
}
