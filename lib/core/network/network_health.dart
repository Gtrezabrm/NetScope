import '../../domain/models/dns_test_result.dart';
import 'network_info.dart';

class NetworkHealth {
  final int score;
  final String label;
  final List<String> factors;

  const NetworkHealth({required this.score, required this.label, required this.factors});

  factory NetworkHealth.from(NetworkInfo network, DnsTestResult? best) {
    if (!network.connected) {
      return const NetworkHealth(score: 0, label: 'بدون اتصال', factors: ['اتصال شبکه فعال نیست.']);
    }

    var score = network.internetAvailable ? 60 : 35;
    final factors = <String>[
      network.internetAvailable ? 'اینترنت توسط Android تأیید شده.' : 'اتصال برقرار است، اما Android اینترنت را تأیید نکرده است.',
    ];

    if (best == null) {
      factors.add('هنوز Benchmark DNS انجام نشده است.');
      return NetworkHealth(score: score, label: score >= 60 ? 'قابل استفاده' : 'نیازمند بررسی', factors: factors);
    }

    final dnsPart = (best.score.isFinite ? best.score : 0).clamp(0, 100).round();
    score = (score * .45 + dnsPart * .55).round();
    factors.add('بهترین DNS قابل‌اعتماد: ${best.server.name} با ${best.packetLossPercent.toStringAsFixed(0)}٪ Loss.');
    if (best.jitterMs > 20) factors.add('Jitter DNS بالاست (${best.jitterMs.toStringAsFixed(1)} ms).');

    final label = score >= 85 ? 'عالی' : score >= 70 ? 'خوب' : score >= 50 ? 'متوسط' : 'نیازمند بررسی';
    return NetworkHealth(score: score, label: label, factors: factors);
  }
}
