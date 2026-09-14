import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/models/dns_server.dart';

class AppStorage {
  static const _customDnsKey = 'custom_dns_servers_v1';
  static const _historyKey = 'benchmark_history_v1';
  static const _samplesKey = 'benchmark_samples';
  static const _themeKey = 'theme_mode';

  Future<List<DnsServer>> loadCustomDns() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_customDnsKey) ?? const [];
    return raw.map((e) {
      try { return DnsServer.fromJson(jsonDecode(e) as Map<String, dynamic>); } catch (_) { return null; }
    }).whereType<DnsServer>().toList();
  }

  Future<void> saveCustomDns(List<DnsServer> servers) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_customDnsKey, servers.map((e) => jsonEncode(e.toJson())).toList());
  }

  Future<void> removeCustomDns(String id) async {
    final current = await loadCustomDns();
    current.removeWhere((e) => e.id == id);
    await saveCustomDns(current);
  }

  Future<int> loadSamples() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getInt(_samplesKey) ?? 10).clamp(3, 10).toInt();
  }

  Future<void> saveSamples(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_samplesKey, value.clamp(3, 10).toInt());
  }

  Future<String> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey) ?? 'dark';
  }

  Future<void> saveTheme(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, value);
  }

  Future<List<Map<String, dynamic>>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_historyKey) ?? const [];
    return raw.map((e) {
      try { return jsonDecode(e) as Map<String, dynamic>; } catch (_) { return <String, dynamic>{}; }
    }).where((e) => e.isNotEmpty).toList();
  }

  Future<void> addHistory({required int tested, required int successful, required String? bestName, required double? bestScore, required DateTime at}) async {
    final history = await loadHistory();
    history.insert(0, {'tested': tested, 'successful': successful, 'bestName': bestName, 'bestScore': bestScore, 'at': at.toIso8601String()});
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_historyKey, history.take(15).map((e) => jsonEncode(e)).toList());
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}
