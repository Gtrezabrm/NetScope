import 'dns_sample.dart';
import 'dns_server.dart';

enum DnsTestStatus { success, timeout, failed, unsupported }

class DnsTestResult {
  final DnsServer server;
  final DnsTestStatus status;
  final List<int> samples;
  final int attempts;
  final DateTime testedAt;
  final String? error;
  final bool usedSecondary;
  final List<DnsSample> sampleDetails;
  final int primaryFailures;
  final int fallbackSuccesses;

  const DnsTestResult({
    required this.server,
    required this.status,
    required this.samples,
    required this.attempts,
    required this.testedAt,
    this.error,
    this.usedSecondary = false,
    this.sampleDetails = const [],
    this.primaryFailures = 0,
    this.fallbackSuccesses = 0,
  });

  bool get isSuccessful => status == DnsTestStatus.success && samples.isNotEmpty;
  double get successRate => attempts == 0 ? 0 : samples.length / attempts;
  double get packetLossPercent => attempts == 0 ? 0 : (1 - successRate) * 100;
  double get averageMs => samples.isEmpty ? double.nan : samples.reduce((a, b) => a + b) / samples.length;
  int get minMs => samples.isEmpty ? 0 : samples.reduce((a, b) => a < b ? a : b);
  int get maxMs => samples.isEmpty ? 0 : samples.reduce((a, b) => a > b ? a : b);

  double get medianMs {
    if (samples.isEmpty) return double.nan;
    final sorted = [...samples]..sort();
    final middle = sorted.length ~/ 2;
    return sorted.length.isOdd ? sorted[middle].toDouble() : (sorted[middle - 1] + sorted[middle]) / 2;
  }

  double get jitterMs {
    if (samples.length < 2) return 0;
    final mean = averageMs;
    return samples.map((v) => (v - mean).abs()).reduce((a, b) => a + b) / samples.length;
  }

  /// A resolver with very low latency but severe loss must never rank near
  /// a consistently responding resolver. Reliability therefore acts as both
  /// a score component and a strong multiplier once loss exceeds 20%.
  double get score {
    if (!isSuccessful) return double.nan;
    final latencyScore = (100 - averageMs * 0.65).clamp(0, 100).toDouble();
    final stabilityScore = (100 - jitterMs * 1.8).clamp(0, 100).toDouble();
    final reliabilityScore = (successRate * 100).clamp(0, 100).toDouble();
    final base = latencyScore * 0.40 + stabilityScore * 0.25 + reliabilityScore * 0.35;
    final reliabilityFactor = (successRate / 0.80).clamp(0, 1).toDouble();
    return base * reliabilityFactor;
  }

  bool get isReliable => isSuccessful && successRate >= 0.80;

  String get statusLabel {
    switch (status) {
      case DnsTestStatus.success:
        if (successRate < 0.80) return 'ناپایدار';
        if (score >= 90) return 'عالی';
        if (score >= 75) return 'خوب';
        if (score >= 55) return 'متوسط';
        return 'ضعیف';
      case DnsTestStatus.timeout:
        return 'Timeout';
      case DnsTestStatus.failed:
        return 'ناموفق';
      case DnsTestStatus.unsupported:
        return 'پشتیبانی نمی‌شود';
    }
  }
}
