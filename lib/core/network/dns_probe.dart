import 'dns_probe_result.dart';
import 'dns_probe_stub.dart' if (dart.library.io) 'dns_probe_io.dart' as platform;

Future<DnsProbeResult> probeDns(
  String server, {
  String domain = 'example.com',
  Duration timeout = const Duration(seconds: 2),
  bool ipv6 = false,
}) => platform.probeDns(server, domain: domain, timeout: timeout, ipv6: ipv6);
