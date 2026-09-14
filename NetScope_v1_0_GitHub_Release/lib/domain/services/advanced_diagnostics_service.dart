import 'dart:io';
import '../models/dns_test_result.dart';
import '../../core/network/dns_probe.dart';

class DiagnosticResult {
  final String name;
  final bool success;
  final int? latencyMs;
  final String detail;
  const DiagnosticResult({required this.name, required this.success, this.latencyMs, required this.detail});
}

class AdvancedDiagnosticsService {
  Future<DiagnosticResult> testIpv6Dns(String server) async {
    final result = await probeDns(server, ipv6: true, timeout: const Duration(seconds: 2));
    return DiagnosticResult(
      name: 'IPv6 DNS',
      success: result.status == DnsTestStatus.success,
      latencyMs: result.latencyMs,
      detail: result.status == DnsTestStatus.success ? 'پاسخ IPv6 دریافت شد' : (result.error ?? result.status.name),
    );
  }

  Future<DiagnosticResult> testDoH() async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 4);
    final watch = Stopwatch()..start();
    try {
      final request = await client.getUrl(Uri.parse('https://cloudflare-dns.com/dns-query?name=example.com&type=A'));
      request.headers.set('accept', 'application/dns-json');
      final response = await request.close().timeout(const Duration(seconds: 5));
      await response.drain<void>();
      return DiagnosticResult(name: 'DoH', success: response.statusCode >= 200 && response.statusCode < 300, latencyMs: watch.elapsedMilliseconds, detail: 'HTTPS ${response.statusCode}');
    } catch (_) {
      return DiagnosticResult(name: 'DoH', success: false, latencyMs: watch.elapsedMilliseconds, detail: 'دسترسی به DoH ناموفق بود');
    } finally {
      client.close(force: true);
    }
  }

  Future<DiagnosticResult> testDoT() async {
    final watch = Stopwatch()..start();
    SecureSocket? socket;
    try {
      socket = await SecureSocket.connect('one.one.one.one', 853, timeout: const Duration(seconds: 5));
      return DiagnosticResult(name: 'DoT', success: true, latencyMs: watch.elapsedMilliseconds, detail: 'TLS روی پورت 853 برقرار شد');
    } catch (_) {
      return DiagnosticResult(name: 'DoT', success: false, latencyMs: watch.elapsedMilliseconds, detail: 'اتصال TLS/853 ناموفق بود');
    } finally {
      socket?.destroy();
    }
  }
}
