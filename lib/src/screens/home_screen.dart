import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../services/gacha_service.dart';
import '../state/screen_trainer_controller.dart';
import '../utils/platform_utils.dart';
import 'curtain_screen.dart';
import 'exercise_screen.dart';
import 'gacha_screen.dart';
import 'companion_screen.dart';
import 'onboarding_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';
import '../utils/strings.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ScreenTrainerController, GachaService>(
      builder: (context, controller, gachaService, _) {
        if (!controller.ready) {
          return _StartupLoadingScreen(
            message: controller.statusMessage,
            onRetry: controller.init,
          );
        }

        if (controller.profiles.isEmpty) {
          return const OnboardingScreen();
        }

        final pages = <Widget>[
          const CurtainScreen(),
          const ExerciseScreen(),
          const CompanionScreen(),
          const GachaScreen(),
          const StatsScreen(),
          const SettingsScreen(),
        ];

        final destinations = <NavigationRailDestination>[
          const NavigationRailDestination(icon: Icon(Icons.roller_shades), label: Text('Curtain')),
          const NavigationRailDestination(icon: Icon(Icons.fitness_center), label: Text('Exercise')),
          const NavigationRailDestination(icon: Icon(Icons.phone_iphone), label: Text('Companion')),
          const NavigationRailDestination(icon: Icon(Icons.card_giftcard), label: Text('Gacha')),
          const NavigationRailDestination(icon: Icon(Icons.bar_chart), label: Text('Stats')),
          const NavigationRailDestination(icon: Icon(Icons.settings), label: Text('Settings')),
        ];

        return LayoutBuilder(
          builder: (context, constraints) {
            final narrow = constraints.maxWidth < 760;
            final selectedIndex = controller.currentTab.clamp(0, pages.length - 1);
            final shareMessage =
                'I am using ScreenTrainer to earn my screen time. Try it here: https://github.com/Lukas-Bohez/screen_trainer';
            if (narrow) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text(Strings.appName),
                  flexibleSpace: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary.withValues(alpha: 0.18),
                          Colors.transparent,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.share),
                      tooltip: Strings.shareAppTitle,
                      onPressed: () => Share.share(shareMessage, subject: 'ScreenTrainer'),
                    ),
                  ],
                ),
                body: IndexedStack(index: selectedIndex, children: pages),
                bottomNavigationBar: NavigationBar(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: controller.selectTab,
                  destinations: const [
                    NavigationDestination(icon: Icon(Icons.roller_shades), label: 'Curtain'),
                    NavigationDestination(icon: Icon(Icons.fitness_center), label: 'Exercise'),
                    NavigationDestination(icon: Icon(Icons.phone_iphone), label: 'Companion'),
                    NavigationDestination(icon: Icon(Icons.card_giftcard), label: 'Gacha'),
                    NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Stats'),
                    NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
                  ],
                ),
              );
            }

            return Scaffold(
              body: SafeArea(
                child: Row(
                  children: [
                    FutureBuilder<bool>(
                      future: PlatformUtils.isAndroidTV(),
                      builder: (context, snapshot) {
                        return NavigationRail(
                          selectedIndex: selectedIndex,
                          onDestinationSelected: controller.selectTab,
                          labelType: NavigationRailLabelType.all,
                          leading: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                                  child: Icon(Icons.sports_gymnastics, color: Theme.of(context).colorScheme.primary),
                                ),
                                const SizedBox(height: 8),
                                Text('Coins ${gachaService.repCoins}'),
                              ],
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.share),
                            tooltip: 'Share ScreenTrainer',
                            onPressed: () => Share.share(shareMessage, subject: 'ScreenTrainer'),
                          ),
                          destinations: destinations,
                        );
                      },
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(child: IndexedStack(index: selectedIndex, children: pages)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _StartupLoadingScreen extends StatelessWidget {
  const _StartupLoadingScreen({
    this.message,
    required this.onRetry,
  });

  final String? message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text('Preparing ScreenTrainer', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    message ?? 'Loading profiles, theme, and services so you can continue.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry startup'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}