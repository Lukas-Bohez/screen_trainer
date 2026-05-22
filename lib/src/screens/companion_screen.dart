import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/companion_service.dart';

class CompanionScreen extends StatelessWidget {
  const CompanionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CompanionService>(builder: (context, companion, _) {
      final pending = companion.pendingRequests;
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Companion Mode', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Text('Connected companions: ${companion.activeCompanionCount}'),
          const SizedBox(height: 12),
          if (pending.isEmpty) const Text('No pending confirm requests.'),
          ...pending.map((req) {
            final requestId = req['requestId'] as String? ?? '';
            final profileId = req['profileId'] as String? ?? '';
            final reason = req['reason'] as String? ?? 'Confirm?';
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Request for profile $profileId', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(reason),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: FilledButton(onPressed: () async { await companion.respondToRemoteConfirm(requestId, true); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Confirmed'))); }, child: const Text('Confirm'))),
                        const SizedBox(width: 12),
                        Expanded(child: OutlinedButton(onPressed: () async { await companion.respondToRemoteConfirm(requestId, false); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Denied'))); }, child: const Text('Deny'))),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      );
    });
  }
}
