class DnsSample {
  final int index;
  final String domain;
  final String endpoint;
  final int? latencyMs;
  final bool success;
  final bool usedSecondary;
  final String? error;

  const DnsSample({
    required this.index,
    required this.domain,
    required this.endpoint,
    required this.latencyMs,
    required this.success,
    this.usedSecondary = false,
    this.error,
  });
}
