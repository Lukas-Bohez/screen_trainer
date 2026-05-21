import 'package:flutter/material.dart';

class RepCounterWidget extends StatelessWidget {
  const RepCounterWidget({
    super.key,
    required this.completed,
    required this.target,
    required this.progress,
  });

  final int completed;
  final int target;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reps', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              style: Theme.of(context).textTheme.displaySmall!.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.primary,
                  ),
              child: Text('$completed / $target'),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: progress.clamp(0, 1)),
          ],
        ),
      ),
    );
  }
}