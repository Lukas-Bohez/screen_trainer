import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'services/companion_service.dart';
import 'services/exercise_service.dart';
import 'services/gacha_service.dart';
import 'services/gamification_service.dart';
import 'services/log_service.dart';
import 'services/overlay_service.dart';
import 'services/notification_service.dart';
import 'services/settings_repository.dart';
import 'state/screen_trainer_controller.dart';
import 'theme/app_theme.dart';

class ScreenTrainerApp extends StatelessWidget {
  const ScreenTrainerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsRepository>(create: (_) => SettingsRepository()),
        ChangeNotifierProvider<LogService>(create: (_) => LogService()),
        ChangeNotifierProvider<ThemeService>(create: (_) => ThemeService()),
        Provider<GamificationService>(create: (_) => GamificationService()),
        ChangeNotifierProvider<ExerciseService>(create: (_) => ExerciseService()),
        ChangeNotifierProvider<CompanionService>(create: (_) => CompanionService()),
        Provider<OverlayService>(create: (_) => OverlayService()),
        Provider<NotificationService>(create: (_) => NotificationService()),
        ChangeNotifierProvider<GachaService>(
          create: (context) => GachaService(context.read<SettingsRepository>()),
        ),
        ChangeNotifierProvider<ScreenTrainerController>(
          create: (context) {
            final controller = ScreenTrainerController(
              settingsRepository: context.read<SettingsRepository>(),
              themeService: context.read<ThemeService>(),
              gamificationService: context.read<GamificationService>(),
              exerciseService: context.read<ExerciseService>(),
              gachaService: context.read<GachaService>(),
              companionService: context.read<CompanionService>(),
              overlayService: context.read<OverlayService>(),
              notificationService: context.read<NotificationService>(),
              logService: context.read<LogService>(),
            );
            unawaited(controller.init());
            return controller;
          },
        ),
      ],
      child: const _AppView(),
    );
  }
}

class _AppView extends StatelessWidget {
  const _AppView();

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, _) {
        return MaterialApp(
          title: 'ScreenTrainer',
          debugShowCheckedModeBanner: false,
          themeMode: themeService.themeMode,
          theme: themeService.buildTheme(Brightness.light),
          darkTheme: themeService.buildTheme(Brightness.dark),
          home: const HomeScreen(),
        );
      },
    );
  }
}