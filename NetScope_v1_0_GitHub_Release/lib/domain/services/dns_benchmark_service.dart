import '../../core/network/dns_probe.dart';
import '../models/dns_sample.dart';
import '../models/dns_server.dart';
import '../models/dns_test_result.dart';

class DnsBenchmarkService {
  const DnsBenchmarkService();

  Future<DnsTestResult> testOne(
    DnsServer server, {
    int repetitions = 5,
    Duration timeout = const Duration(milliseconds: 1200),
    List<String> domains = const [
      'example.com',
      'cloudflare.com',
      'google.com',
      'wikipedia.org',
      'github.com',
      'microsoft.com',
      'mozilla.org',
      'apple.com',
      'amazon.com',
      'openai.com',
    ],
    bool Function()? shouldContinue,
  }) async {
    final samples = <int>[];
    final details = <DnsSample>[];
    var lastStatus = DnsTestStatus.failed;
    String? lastError;
    var primaryFailures = 0;
    var fallbackSuccesses = 0;
    var consecutiveFailures = 0;

    for (var i = 0; i < repetitions; i++) {
      if (shouldContinue != null && !shouldContinue()) break;
      // Prefer a different domain on every round. The default pool contains
      // enough distinct targets for the supported 3-10 sample range.
      final domain = domains[i % domains.length];
      var endpoint = server.primary;
      var usedSecondary = false;
      final primary = await probeDns(server.primary, domain: domain, timeout: timeout);
      var result = primary;
      if (primary.status != DnsTestStatus.success) primaryFailures++;

      if (primary.status != DnsTestStatus.success && server.secondary.isNotEmpty && server.secondary != server.primary) {
        final secondary = await probeDns(server.secondary, domain: domain, timeout: timeout);
        if (secondary.status == DnsTestStatus.success) {
          result = secondary;
          endpoint = server.secondary;
          usedSecondary = true;
          fallbackSuccesses++;
        }
      }

      lastStatus = result.status;
      lastError = result.error;
      if (result.status == DnsTestStatus.success && result.latencyMs != null) {
        samples.add(result.latencyMs!);
        consecutiveFailures = 0;
      } else {
        consecutiveFailures++;
      }
      details.add(DnsSample(
        index: i + 1,
        domain: domain,
        endpoint: endpoint,
        latencyMs: result.latencyMs,
        success: result.status == DnsTestStatus.success && result.latencyMs != null,
        usedSecondary: usedSecondary,
        error: result.error,
      ));

      // A completely unreachable resolver should not hold up the whole
      // benchmark for every configured sample. Three consecutive failed
      // attempts are enough to classify it as unreachable for this run.
      if (consecutiveFailures >= 3) break;

      if (i < repetitions - 1) {
        await Future<void>.delayed(const Duration(milliseconds: 120));
      }
    }

    return DnsTestResult(
      server: server,
      status: samples.isNotEmpty ? DnsTestStatus.success : lastStatus,
      samples: List.unmodifiable(samples),
      attempts: details.length,
      testedAt: DateTime.now(),
      error: samples.isNotEmpty ? null : lastError,
      usedSecondary: fallbackSuccesses > 0,
      sampleDetails: List.unmodifiable(details),
      primaryFailures: primaryFailures,
      fallbackSuccesses: fallbackSuccesses,
    );
  }
}
