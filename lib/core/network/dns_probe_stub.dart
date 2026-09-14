import '../../domain/models/dns_test_result.dart';
import 'dns_probe_result.dart';

Future<DnsProbeResult> probeDns(
  String server, {
  String domain = 'example.com',
  Duration timeout = const Duration(seconds: 2),
  bool ipv6 = false,
}) async {
  return const DnsProbeResult(
    status: DnsTestStatus.unsupported,
    error: 'Raw UDP DNS probing requires the Android runtime.',
  );
}
