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
                          onPressed: () async {
                            await showDialog<void>(
                              context: context,
                              barrierDismissible: false,
                              builder: (ctx) => _GachaPullDialog(track: GachaTrack.curtain, controller: controller),
                            );
                          },
                          child: const Text('Pull curtain'),
                        ),
                        FilledButton.tonal(
                          onPressed: () async {
                            await showDialog<void>(
                              context: context,
                              barrierDismissible: false,
                              builder: (ctx) => _GachaPullDialog(track: GachaTrack.theme, controller: controller),
                            );
                          },
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

class _GachaPullDialog extends StatefulWidget {
  const _GachaPullDialog({required this.track, required this.controller});
  final GachaTrack track;
  final ScreenTrainerController controller;
  @override
  State<_GachaPullDialog> createState() => _GachaPullDialogState();
}

class _GachaPullDialogState extends State<_GachaPullDialog> {
  Future<List<GachaItem>>? _future;

  @override
  void initState() {
    super.initState();
    _future = widget.controller.gachaService.pullSingle(widget.track);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: FutureBuilder<List<GachaItem>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Column(mainAxisSize: MainAxisSize.min, children: const [SizedBox(height: 16), CircularProgressIndicator(), SizedBox(height: 12), Text('Spinning the wheel...')]);
            }
            if (snapshot.hasError || snapshot.data == null || snapshot.data!.isEmpty) {
              return Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.error_outline, size: 48, color: Colors.red), const SizedBox(height: 8), const Text('Not enough Rep Coins or an error occurred.'), const SizedBox(height: 12), FilledButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))]);
            }
            final item = snapshot.data!.first;
            // Apply theme immediately for theme items to give live transition
            if (item is ThemeItem) {
              widget.controller.setActiveTheme(item);
            }
            return Column(mainAxisSize: MainAxisSize.min, children: [
              const SizedBox(height: 12),
              CircleAvatar(radius: 48, backgroundColor: item.color, child: Icon(item.isAnimated ? Icons.auto_awesome : Icons.image, size: 36, color: Colors.white)),
              const SizedBox(height: 12),
              Text(item.name, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('Rarity: ${item.rarity.name}'),
              const SizedBox(height: 16),
              FilledButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
            ]);
          },
        ),
      ),
    );
  }
}