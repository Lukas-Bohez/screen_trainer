import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/screen_trainer_controller.dart';
import '../widgets/exercise_card.dart';
import '../widgets/rep_counter_widget.dart';

class ExerciseScreen extends StatelessWidget {
  const ExerciseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ScreenTrainerController>(
      builder: (context, controller, _) {
        final progress = controller.targetReps == 0 ? 0.0 : controller.completedReps / controller.targetReps;
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            RepCounterWidget(
              completed: controller.completedReps,
              target: controller.targetReps,
              progress: progress,
            ),
            if (controller.cameraController != null && controller.cameraController!.value.isInitialized) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.exerciseStatus ?? 'Camera ready.',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: AspectRatio(
                          aspectRatio: controller.cameraController!.value.aspectRatio,
                          child: CameraPreview(controller.cameraController!),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.sensors),
                  title: Text(controller.exerciseStatus ?? 'Motion sensor active.'),
                  subtitle: const Text('Pose detection falls back to motion sensing or manual count when needed.'),
                ),
              ),
            ],
            const SizedBox(height: 16),
            ExerciseCard(
              title: 'Manual count',
              subtitle: 'Always available. Tap to count one rep.',
              icon: Icons.touch_app,
              onTap: controller.manualRep,
            ),
            ExerciseCard(
              title: 'Start challenge',
              subtitle: 'Use the configured challenge type for the active profile.',
              icon: Icons.fitness_center,
              onTap: controller.startChallenge,
            ),
            ExerciseCard(
              title: 'Challenge type',
              subtitle: controller.activeProfile?.challengeConfig.challengeType.name ?? 'manual',
              icon: Icons.tune,
              onTap: () {},
            ),
          ],
        );
      },
    );
  }
}