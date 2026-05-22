import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/screen_trainer_controller.dart';
import '../utils/strings.dart';
import '../widgets/curtain_widget.dart';
import '../services/sick_day_service.dart';
import '../models/profile.dart';

class CurtainScreen extends StatelessWidget {
  const CurtainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ScreenTrainerController>(
      builder: (context, controller, _) {
        final state = controller.curtainState;
        final progress = controller.targetReps == 0
          ? 0.0
          : controller.completedReps / controller.targetReps.toDouble();
        return CurtainWidget(
          state: state,
          progress: progress,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(Strings.curtainHeadline, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text(Strings.curtainSubhead, style: Theme.of(context).textTheme.titleMedium),
                  const Spacer(),
                  if (controller.statusMessage != null) ...[
                    Text(controller.statusMessage!, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 12),
                  ],
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton(onPressed: controller.startChallenge, child: const Text(Strings.startChallenge)),
                      OutlinedButton(onPressed: controller.openScreen, child: const Text(Strings.openScreen)),
                      TextButton(onPressed: controller.lockScreen, child: const Text(Strings.lockScreen)),
                      // Subtle Sick Day path — one extra tap from main actions
                      TextButton(
                        onPressed: () async {
                          final profile = controller.activeProfile;
                          if (profile == null) return;
                          final confirmed = await showDialog<SickDayOption?>(
                            context: context,
                            builder: (ctx) => _SickDayDialog(profile: profile),
                          );
                          if (confirmed == null) return;
                          // Authenticate before applying
                          bool ok = false;
                          final sickService = SickDayService();
                          if (profile.isChild) {
                            // Require a parent PIN: choose an adult profile then prompt for PIN
                            final adults = controller.profiles.where((p) => !p.isChild).toList();
                            // Try remote confirm first if any companion connected
                            final companionService = controller.companionService;
                            if (await companionService.requestRemoteConfirm(profile.id, reason: 'Child requests a sick-day skip')) {
                              // remote confirmed
                              final applied = await controller.applySickDayOption(confirmed);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(applied ? 'Sick day applied via companion.' : 'Could not apply sick day.')));
                              return;
                            }

                            if (adults.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No adult profiles configured.')));
                              return;
                            }
                            final selected = await showDialog<Profile?>(context: context, builder: (ctx) {
                              return SimpleDialog(title: const Text('Select parent to confirm'), children: adults.map((p) => SimpleDialogOption(onPressed: () => Navigator.of(ctx).pop(p), child: Text(p.name))).toList());
                            });
                            if (selected == null) return;
                            final pin = await showDialog<String?>(context: context, builder: (ctx) {
                              final ctl = TextEditingController();
                              return AlertDialog(title: const Text('Enter PIN'), content: TextField(controller: ctl, keyboardType: TextInputType.number, obscureText: true), actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.of(ctx).pop(ctl.text), child: const Text('OK'))]);
                            });
                            if (pin == null) return;
                            ok = controller.settingsRepository.verifyPin(selected.id, pin);
                          } else {
                            ok = await sickService.authenticateForSkip();
                          }
                          if (!ok) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Authentication failed.')));
                            return;
                          }
                          final applied = await controller.applySickDayOption(confirmed);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(applied ? 'Sick day applied.' : 'Could not apply sick day.')));
                        },
                        child: const Text('Not today'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('State: $state'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SickDayDialog extends StatelessWidget {
  const _SickDayDialog({required this.profile});

  final profile;

  @override
  Widget build(BuildContext context) {
    final choices = <Map<String, Object?>>[
      {'label': 'Skip this session (50 Rep Coins)', 'option': SickDayOption.skipSession},
      {'label': 'Reduce target reps by 50% (10 Rep Coins)', 'option': SickDayOption.reduceTargetReps},
      {'label': 'Use streak freeze (5 Fabric Scraps)', 'option': SickDayOption.streakFreeze},
    ];
    return AlertDialog(
      title: const Text('Not today'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(profile.isChild ? 'Ask a grown-up to confirm.' : 'Confirm your choice with device authentication.'),
          const SizedBox(height: 12),
          ...choices.map((c) => ListTile(
                title: Text(c['label'] as String),
                onTap: () => Navigator.of(context).pop(c['option'] as SickDayOption),
              ))
        ],
      ),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel'))],
    );
  }
}