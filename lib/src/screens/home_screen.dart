import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/gacha_service.dart';
import '../state/screen_trainer_controller.dart';
import '../utils/platform_utils.dart';
import 'curtain_screen.dart';
import 'exercise_screen.dart';
import 'gacha_screen.dart';
import 'onboarding_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ScreenTrainerController, GachaService>(
      builder: (context, controller, gachaService, _) {
        if (!controller.ready || controller.profiles.isEmpty) {
          return const OnboardingScreen();
        }

        final pages = <Widget>[
          const CurtainScreen(),
          const ExerciseScreen(),
          const GachaScreen(),
          const StatsScreen(),
          const SettingsScreen(),
        ];

        final destinations = <NavigationRailDestination>[
          const NavigationRailDestination(icon: Icon(Icons.roller_shades), label: Text('Curtain')),
          const NavigationRailDestination(icon: Icon(Icons.fitness_center), label: Text('Exercise')),
          const NavigationRailDestination(icon: Icon(Icons.card_giftcard), label: Text('Gacha')),
          const NavigationRailDestination(icon: Icon(Icons.bar_chart), label: Text('Stats')),
          const NavigationRailDestination(icon: Icon(Icons.settings), label: Text('Settings')),
        ];

        return LayoutBuilder(
          builder: (context, constraints) {
            final narrow = constraints.maxWidth < 760;
            final selectedIndex = controller.currentTab.clamp(0, pages.length - 1);
            if (narrow) {
              return Scaffold(
                appBar: AppBar(title: const Text('ScreenTrainer')),
                body: IndexedStack(index: selectedIndex, children: pages),
                bottomNavigationBar: NavigationBar(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: controller.selectTab,
                  destinations: const [
                    NavigationDestination(icon: Icon(Icons.roller_shades), label: 'Curtain'),
                    NavigationDestination(icon: Icon(Icons.fitness_center), label: 'Exercise'),
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
                                const CircleAvatar(child: Icon(Icons.sports_gymnastics)),
                                const SizedBox(height: 8),
                                Text('Coins ${gachaService.repCoins}'),
                              ],
                            ),
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