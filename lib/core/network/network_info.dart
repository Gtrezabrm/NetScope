import 'package:flutter/services.dart';

class NetworkInfo {
  final bool connected;
  final bool validated;
  final String transport;
  final List<String> dnsServers;
  final String? ipv4;
  final List<String> ipv6;

  const NetworkInfo({
    required this.connected,
    required this.validated,
    required this.transport,
    required this.dnsServers,
    this.ipv4,
    this.ipv6 = const [],
  });

  bool get internetAvailable => connected && validated;

  String get connectionLabel {
    if (!connected) return 'بدون اتصال';
    if (!validated) return 'شبکه متصل، اینترنت تأیید نشد';
    return transport;
  }

  String get dnsLabel => dnsServers.isEmpty ? 'قابل خواندن نیست' : dnsServers.join(' • ');

  static const _channel = MethodChannel('netscope/network');

  static Future<NetworkInfo> read() async {
    try {
      final raw = await _channel.invokeMethod<Map<dynamic, dynamic>>('getNetworkInfo');
      if (raw == null) return const NetworkInfo(
        connected: false,
        validated: false,
        transport: 'نامشخص',
        dnsServers: [],
      );

      final dns = (raw['dnsServers'] as List?)?.map((e) => '$e').toList() ?? const <String>[];
      final ipv6 = (raw['ipv6'] as List?)?.map((e) => '$e').toList() ?? const <String>[];
      return NetworkInfo(
        connected: raw['connected'] == true,
        validated: raw['validated'] == true,
        transport: '${raw['transport'] ?? 'نامشخص'}',
        dnsServers: dns,
        ipv4: raw['ipv4']?.toString(),
        ipv6: ipv6,
      );
    } catch (_) {
      return const NetworkInfo(
        connected: false,
        validated: false,
        transport: 'در دسترس نیست',
        dnsServers: [],
      );
    }
  }
}
