import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/screen_trainer_controller.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ScreenTrainerController>(
      builder: (context, controller, _) {
        final profile = controller.activeProfile;
        final streak = profile?.streak ?? 0;
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Progress', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 220,
                      child: BarChart(
                        BarChartData(
                          barGroups: List.generate(7, (index) {
                            return BarChartGroupData(x: index, barRods: [BarChartRodData(toY: (index + 1).toDouble() * 2)]);
                          }),
                          titlesData: const FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('Streak: $streak days'),
                    Text('XP: ${profile?.xp ?? 0}'),
                    Text('Total reps: ${profile?.totalReps ?? 0}'),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}