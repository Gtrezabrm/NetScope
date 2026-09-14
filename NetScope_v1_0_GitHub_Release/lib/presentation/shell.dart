import 'dart:async';
import 'package:flutter/material.dart';
import '../core/network/network_info.dart';
import '../data/app_storage.dart';
import '../data/dns_catalog.dart';
import '../domain/models/dns_server.dart';
import '../domain/models/dns_test_result.dart';
import '../domain/services/dns_benchmark_service.dart';
import 'pages/dashboard_page.dart';
import 'pages/dns_page.dart';
import 'pages/results_page.dart';
import 'pages/settings_page.dart';
import 'pages/gaming_page.dart';

class AppShell extends StatefulWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;
  const AppShell({super.key, required this.themeMode, required this.onThemeChanged});
  @override State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with WidgetsBindingObserver {
  final _benchmark = const DnsBenchmarkService();
  final _storage = AppStorage();
  Timer? _networkTimer;
  int _index = 0;
  bool _testing = false;
  bool _cancelRequested = false;
  int _completedServers = 0;
  int _samples = 10;
  List<DnsServer> _servers = dnsCatalog;
  List<Map<String, dynamic>> _history = const [];
  NetworkInfo _network = const NetworkInfo(connected: false, validated: false, transport: 'در حال بررسی...', dnsServers: []);
  final Map<String, DnsTestResult> _results = {};

  @override
  void initState() {
    super.initState(); WidgetsBinding.instance.addObserver(this); _load();
    _networkTimer = Timer.periodic(const Duration(seconds: 3), (_) => _refreshNetwork());
  }

  Future<void> _load() async {
    final custom = await _storage.loadCustomDns();
    final history = await _storage.loadHistory();
    final samples = await _storage.loadSamples();
    if (!mounted) return;
    setState(() { _servers = [...dnsCatalog, ...custom]; _history = history; _samples = samples; });
    await _refreshNetwork();
  }

  Future<void> _refreshNetwork() async {
    final info = await NetworkInfo.read();
    if (mounted) setState(() => _network = info);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) { if (state == AppLifecycleState.resumed) _refreshNetwork(); }

  @override
  void dispose() { WidgetsBinding.instance.removeObserver(this); _networkTimer?.cancel(); super.dispose(); }

  List<DnsTestResult> get sortedResults {
    final list = _results.values.toList();
    list.sort((a, b) {
      // Reliable DNS results always stay above unstable results, even when an
      // unstable resolver happens to have a very low latency sample.
      final ar = a.isReliable ? 1 : 0;
      final br = b.isReliable ? 1 : 0;
      if (ar != br) return br.compareTo(ar);
      final ascore = a.isSuccessful ? a.score : -1;
      final bscore = b.isSuccessful ? b.score : -1;
      return bscore.compareTo(ascore);
    });
    return list;
  }

  DnsTestResult? get bestResult { final successful = sortedResults.where((e) => e.isReliable); return successful.isEmpty ? null : successful.first; }

  Future<void> runFullBenchmark({int? repetitions}) async {
    if (_testing) return;
    await _refreshNetwork();
    if (!_network.internetAvailable) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اتصال اینترنت تأیید نشده است؛ ابتدا اتصال را بررسی کن.'))); return; }
    setState(() { _testing = true; _cancelRequested = false; _completedServers = 0; _results.clear(); });

    for (final server in _servers) {
      if (_cancelRequested || !mounted) break;
      await _refreshNetwork();
      if (!_network.internetAvailable) break;
      final result = await _benchmark.testOne(server, repetitions: repetitions ?? _samples, shouldContinue: () => mounted && _testing && !_cancelRequested);
      if (!mounted || _cancelRequested) break;
      setState(() { _results[server.id] = result; _completedServers++; });
    }

    if (!mounted) return;
    final best = bestResult;
    if (_completedServers > 0) {
      await _storage.addHistory(tested: _completedServers, successful: _results.values.where((e) => e.isSuccessful).length, bestName: best?.server.name, bestScore: best?.score, at: DateTime.now());
      _history = await _storage.loadHistory();
    }
    setState(() { _testing = false; _cancelRequested = false; });
  }

  void cancelBenchmark() { if (_testing) setState(() => _cancelRequested = true); }

  Future<void> addDns(DnsServer server) async {
    final custom = await _storage.loadCustomDns();
    if (custom.any((e) => e.primary == server.primary || e.id == server.id)) return;
    custom.add(server); await _storage.saveCustomDns(custom);
    if (mounted) setState(() => _servers = [...dnsCatalog, ...custom]);
  }

  Future<void> removeDns(String id) async { await _storage.removeCustomDns(id); final custom = await _storage.loadCustomDns(); if (mounted) setState(() => _servers = [...dnsCatalog, ...custom]); }
  Future<void> setSamples(int value) async { await _storage.saveSamples(value); if (mounted) setState(() => _samples = value); }
  Future<void> clearHistory() async { await _storage.clearHistory(); if (mounted) setState(() => _history = const []); }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(testing: _testing, completedServers: _completedServers, totalServers: _servers.length, bestResult: bestResult, network: _network, onRefreshNetwork: _refreshNetwork, onRunTest: () => runFullBenchmark(), onQuickTest: () => runFullBenchmark(repetitions: 3), onCancelTest: cancelBenchmark),
      DnsPage(servers: _servers, onAdd: addDns, onRemove: removeDns),
      ResultsPage(results: sortedResults, history: _history, onClearHistory: clearHistory),
      GamingPage(repetitions: _samples),
      SettingsPage(samples: _samples, themeMode: widget.themeMode, onSamplesChanged: setSamples, onThemeChanged: widget.onThemeChanged, onClearHistory: clearHistory),
    ];
    return Scaffold(body: IndexedStack(index: _index, children: pages), bottomNavigationBar: NavigationBar(selectedIndex: _index, onDestinationSelected: (v) => setState(() => _index = v), destinations: const [
      NavigationDestination(icon: Icon(Icons.space_dashboard_outlined), selectedIcon: Icon(Icons.space_dashboard_rounded), label: 'داشبورد'),
      NavigationDestination(icon: Icon(Icons.dns_outlined), selectedIcon: Icon(Icons.dns_rounded), label: 'DNSها'),
      NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart_rounded), label: 'نتایج'),
      NavigationDestination(icon: Icon(Icons.sports_esports_outlined), selectedIcon: Icon(Icons.sports_esports_rounded), label: 'گیم'),
      NavigationDestination(icon: Icon(Icons.tune_outlined), selectedIcon: Icon(Icons.tune_rounded), label: 'تنظیمات'),
    ]));
  }
}
