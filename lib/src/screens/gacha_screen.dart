import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/gacha_item.dart';
import '../services/gacha_service.dart';
import '../state/screen_trainer_controller.dart';

class GachaScreen extends StatelessWidget {
  const GachaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ScreenTrainerController, GachaService>(
      builder: (context, controller, gachaService, _) {
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rep Coins', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text('${gachaService.repCoins}', style: Theme.of(context).textTheme.displaySmall),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      children: [
                        FilledButton(
                          onPressed: () => controller.pullSingle(GachaTrack.curtain),
                          child: const Text('Pull curtain'),
                        ),
                        FilledButton.tonal(
                          onPressed: () => controller.pullSingle(GachaTrack.theme),
                          child: const Text('Pull theme'),
                        ),
                        OutlinedButton(
                          onPressed: () => controller.pullTen(GachaTrack.curtain),
                          child: const Text('10 pull'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Inventory', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            ...gachaService.ownedItems.map(
              (item) => ListTile(
                leading: CircleAvatar(backgroundColor: item.color),
                title: Text(item.name),
                subtitle: Text('${item.track.name} · ${item.rarity.name}'),
                trailing: item is ThemeItem
                    ? TextButton(
                        onPressed: () => controller.setActiveTheme(item),
                        child: const Text('Set active'),
                      )
                    : TextButton(
                        onPressed: () => controller.setActiveCurtain(item),
                        child: const Text('Set active'),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}