import 'package:flutter/material.dart';

import '../state/curtain_state.dart';

class CurtainWidget extends StatelessWidget {
  const CurtainWidget({
    super.key,
    required this.state,
    required this.progress,
    required this.child,
  });

  final CurtainState state;
  final double progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final reveal = switch (state) {
      CurtainState.locked => 0.0,
      CurtainState.unlocking => progress,
      CurtainState.pendingReveal => 0.88,
      CurtainState.open => 1.0,
      CurtainState.cooldown => 0.62,
    };
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            colorScheme.primary.withValues(alpha: 0.95),
            colorScheme.primaryContainer.withValues(alpha: 0.92),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            top: MediaQuery.of(context).size.height * reveal,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 220),
              opacity: state == CurtainState.pendingReveal ? 0.9 : 1,
              child: child,
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 220),
                opacity: state == CurtainState.open ? 0.0 : 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: state == CurtainState.pendingReveal
                          ? colorScheme.tertiary
                          : colorScheme.secondary.withValues(alpha: 0.4),
                      width: state == CurtainState.pendingReveal ? 3 : 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}