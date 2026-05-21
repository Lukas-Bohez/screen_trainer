class RepEvent {
  const RepEvent({
    required this.count,
    required this.intensity,
    required this.timestamp,
  });

  final int count;
  final double intensity;
  final DateTime timestamp;
}