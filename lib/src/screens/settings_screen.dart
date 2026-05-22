import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/challenge_config.dart';
import '../models/schedule_window.dart';
import '../services/review_service.dart';
import '../state/screen_trainer_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _addProfile(BuildContext context) async {
    final controller = context.read<ScreenTrainerController>();
    final profile = controller.settingsRepository.createProfileTemplate(
      name: 'Profile ${controller.profiles.length + 1}',
      isChild: false,
    );
    await controller.addProfile(profile);
  }

  Future<void> _addSchedule(BuildContext context) async {
    final controller = context.read<ScreenTrainerController>();
    await controller.addScheduleWindow(
      const ScheduleWindow(
        startHour: 21,
        startMinute: 0,
        endHour: 7,
        endMinute: 0,
        weekdays: [1, 2, 3, 4, 5],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ScreenTrainerController>(
      builder: (context, controller, _) {
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Theme mode', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment(value: ThemeMode.system, label: Text('System')),
                        ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                        ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
                      ],
                      selected: <ThemeMode>{controller.themeMode},
                      onSelectionChanged: (selected) => controller.setThemeMode(selected.first),
                    ),
                    const SizedBox(height: 16),
                    Text('Cooldown: ${controller.cooldownMinutes} minutes'),
                    Slider(
                      value: controller.cooldownMinutes.toDouble(),
                      min: 5,
                      max: 120,
                      divisions: 23,
                      label: '${controller.cooldownMinutes} minutes',
                      onChanged: (value) => controller.setCooldownMinutes(value.round()),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Profiles', style: Theme.of(context).textTheme.titleLarge),
                        FilledButton.tonal(onPressed: () => _addProfile(context), child: const Text('Add profile')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...controller.profiles.map(
                      (profile) => ListTile(
                        title: Text(profile.name),
                        subtitle: Text('${profile.challengeConfig.challengeType.name} · ${profile.challengeConfig.targetReps} reps'),
                        selected: controller.activeProfile?.id == profile.id,
                        trailing: Wrap(
                          spacing: 8,
                          children: [
                            TextButton(
                              onPressed: () => controller.setActiveProfile(profile.id),
                              child: const Text('Use'),
                            ),
                            TextButton(
                              onPressed: () => controller.removeProfile(profile.id),
                              child: const Text('Remove'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Schedule windows', style: Theme.of(context).textTheme.titleLarge),
                        FilledButton.tonal(onPressed: () => _addSchedule(context), child: const Text('Add window')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...controller.scheduleWindows.asMap().entries.map(
                      (entry) => ListTile(
                        title: Text('Window ${entry.key + 1}'),
                        subtitle: Text(
                          '${entry.value.startHour.toString().padLeft(2, '0')}:${entry.value.startMinute.toString().padLeft(2, '0')} '
                          'to ${entry.value.endHour.toString().padLeft(2, '0')}:${entry.value.endMinute.toString().padLeft(2, '0')}',
                        ),
                        trailing: TextButton(
                          onPressed: () => controller.deleteScheduleWindow(entry.key),
                          child: const Text('Delete'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Challenge configuration'),
                    subtitle: Text('Default target: ${ChallengeConfig.defaults.targetReps} reps'),
                    trailing: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.edit),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.star_rounded, color: Colors.amber),
                    title: const Text('Rate ScreenTrainer'),
                    subtitle: const Text('Enjoying the app? Leave a review.'),
                    onTap: () => ReviewService.openStoreListing(),
                  ),
                  ListTile(
                    leading: const Icon(Icons.ios_share),
                    title: const Text('Share ScreenTrainer'),
                    subtitle: const Text('Send the app to a friend.'),
                    onTap: () => Share.share(
                      'ScreenTrainer turns screen time into earned time. Try it: https://github.com/Lukas-Bohez/screen_trainer',
                      subject: 'ScreenTrainer',
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}