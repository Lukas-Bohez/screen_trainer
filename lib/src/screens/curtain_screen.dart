import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/screen_trainer_controller.dart';
import '../utils/strings.dart';
import '../widgets/curtain_widget.dart';

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