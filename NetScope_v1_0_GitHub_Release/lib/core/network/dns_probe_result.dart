import '../../domain/models/dns_test_result.dart';

class DnsProbeResult {
  final DnsTestStatus status;
  final int? latencyMs;
  final String? error;

  const DnsProbeResult({required this.status, this.latencyMs, this.error});
}
