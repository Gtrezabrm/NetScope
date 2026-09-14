import 'dart:io';

enum PortStatus { open, closed, filtered, error }

class GamingTargetResult {
  final String name;
  final String host;
  final int port;
  final List<int> samples;
  final int attempts;
  final DateTime testedAt;
  final String? lastError;
  final PortStatus status;

  const GamingTargetResult({
    required this.name,
    required this.host,
    required this.port,
    required this.samples,
    required this.attempts,
    required this.testedAt,
    required this.status,
    this.lastError,
  });

  int get successes => samples.length;
  double get successRate => attempts == 0 ? 0 : successes / attempts;
  double get lossPercent => attempts == 0 ? 0 : (1 - successRate) * 100;
  double get averageMs => samples.isEmpty ? double.nan : samples.reduce((a, b) => a + b) / samples.length;
  double get medianMs {
    if (samples.isEmpty) return double.nan;
    final sorted = [...samples]..sort();
    final m = sorted.length ~/ 2;
    return sorted.length.isOdd ? sorted[m].toDouble() : (sorted[m - 1] + sorted[m]) / 2;
  }
  double get jitterMs {
    if (samples.length < 2) return 0;
    final mean = averageMs;
    return samples.map((v) => (v - mean).abs()).reduce((a, b) => a + b) / samples.length;
  }
  bool get success => status == PortStatus.open;
}

class GamingDiagnosticsService {
  const GamingDiagnosticsService();

  PortStatus _classify(Object error) {
    if (error is SocketException) {
      final code = error.osError?.errorCode;
      final message = error.message.toLowerCase();
      if (code == 111 || code == 61 || message.contains('connection refused')) return PortStatus.closed;
      if (message.contains('timed out') || message.contains('timeout') || code == 110 || code == 60) return PortStatus.filtered;
    }
    return PortStatus.error;
  }

  Future<GamingTargetResult> testTarget({
    required String name,
    required String host,
    required int port,
    int repetitions = 10,
    Duration timeout = const Duration(seconds: 2),
    bool Function()? shouldContinue,
  }) async {
    final samples = <int>[];
    String? lastError;
    var attempts = 0;
    var status = PortStatus.error;

    for (var i = 0; i < repetitions; i++) {
      if (shouldContinue != null && !shouldContinue()) break;
      final watch = Stopwatch()..start();
      Socket? socket;
      attempts++;
      try {
        socket = await Socket.connect(host, port, timeout: timeout);
        samples.add(watch.elapsedMilliseconds);
        status = PortStatus.open;
      } catch (e) {
        lastError = e.toString();
        final classified = _classify(e);
        if (status != PortStatus.open) status = classified;
      } finally {
        socket?.destroy();
      }
      if (i < repetitions - 1) await Future<void>.delayed(const Duration(milliseconds: 100));
    }

    return GamingTargetResult(
      name: name,
      host: host,
      port: port,
      samples: List.unmodifiable(samples),
      attempts: attempts,
      testedAt: DateTime.now(),
      status: status,
      lastError: lastError,
    );
  }

  Future<List<GamingTargetResult>> run({
    int repetitions = 10,
    String? customHost,
    int customPort = 443,
    bool Function()? shouldContinue,
  }) async {
    final targets = <({String name, String host, int port})>[
      (name: 'Cloudflare Edge', host: '1.1.1.1', port: 443),
      (name: 'Steam', host: 'store.steampowered.com', port: 443),
      (name: 'Epic Games', host: 'epicgames.com', port: 443),
    ];
    if (customHost != null && customHost.trim().isNotEmpty) {
      targets.add((name: 'مقصد سفارشی', host: customHost.trim(), port: customPort));
    }

    final out = <GamingTargetResult>[];
    for (final target in targets) {
      if (shouldContinue != null && !shouldContinue()) break;
      out.add(await testTarget(
        name: target.name,
        host: target.host,
        port: target.port,
        repetitions: repetitions,
        shouldContinue: shouldContinue,
      ));
    }
    return out;
  }
}
