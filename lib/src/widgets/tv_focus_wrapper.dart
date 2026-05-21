import 'package:flutter/material.dart';

class TvFocusWrapper extends StatelessWidget {
  const TvFocusWrapper({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: child,
    );
  }
}