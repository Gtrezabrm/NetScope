import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/app_theme.dart';
import '../../core/network/network_info.dart';
import '../../core/network/network_health.dart';
import '../../domain/models/dns_test_result.dart';

class DashboardPage extends StatelessWidget {
  final bool testing;
  final int completedServers;
  final int totalServers;
  final DnsTestResult? bestResult;
  final NetworkInfo network;
  final VoidCallback onRunTest;
  final VoidCallback onQuickTest;
  final VoidCallback onCancelTest;
  final Future<void> Function() onRefreshNetwork;

  const DashboardPage({super.key, required this.testing, required this.completedServers, required this.totalServers, required this.bestResult, required this.network, required this.onRunTest, required this.onQuickTest, required this.onCancelTest, required this.onRefreshNetwork});

  @override
  Widget build(BuildContext context) {
    final text = AppTheme.text(context);
    final muted = AppTheme.muted(context);
    final surface = AppTheme.card(context);
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: onRefreshNetwork,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
          children: [
            _header(context, text, muted),
            const SizedBox(height: 20),
            _networkStatus(context, surface, text, muted),
            const SizedBox(height: 14),
            _hero(context),
            const SizedBox(height: 14),
            _metrics(context, surface, text),
            const SizedBox(height: 14),
            _healthCard(context, surface, text, muted),
            if (bestResult != null) ...[const SizedBox(height: 14), _bestCard(context)],
            const SizedBox(height: 18),
            _notice(context, surface, muted),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context, Color text, Color muted) => Row(children: [
    Container(width: 52, height: 52, decoration: BoxDecoration(borderRadius: BorderRadius.circular(17), gradient: const LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFF6D9BFF), Color(0xFF4C62FF)])), child: const Icon(Icons.radar_rounded, color: Colors.white, size: 29)),
    const SizedBox(width: 13),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('NetScope', style: AppTheme.displayStyle(size: 27, color: text)), Text('آزمایشگاه کیفیت DNS و شبکه', style: TextStyle(color: muted, fontSize: 12))])),
    _statusChip(context),
  ]);

  Widget _statusChip(BuildContext context) {
    final online = network.internetAvailable;
    final color = online ? AppTheme.success : AppTheme.danger;
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7), decoration: BoxDecoration(color: color.withValues(alpha: .10), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: .18))), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.circle, size: 7, color: color), const SizedBox(width: 6), Text(online ? 'ONLINE' : 'OFFLINE', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800))]));
  }

  Widget _networkStatus(BuildContext context, Color surface, Color text, Color muted) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: .12))),
    child: Row(children: [
      CircleAvatar(radius: 22, backgroundColor: (network.internetAvailable ? AppTheme.success : AppTheme.danger).withValues(alpha: .10), child: Icon(network.internetAvailable ? Icons.wifi_rounded : Icons.wifi_off_rounded, color: network.internetAvailable ? AppTheme.success : AppTheme.danger)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(network.connectionLabel, style: TextStyle(color: text, fontWeight: FontWeight.w700)), const SizedBox(height: 4), Text(network.dnsServers.isEmpty ? 'DNSهای فعلی توسط Android در دسترس گزارش نشده‌اند.' : 'DNS فعلی: ${network.dnsLabel}', style: TextStyle(color: muted, fontSize: 10), maxLines: 2, overflow: TextOverflow.ellipsis)])),
      PopupMenuButton<String>(onSelected: (v) async { if (v == 'copy' && network.dnsServers.isNotEmpty) { await Clipboard.setData(ClipboardData(text: network.dnsServers.join('\n'))); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('DNSهای فعلی کپی شدند.'))); } else if (v == 'details') { _networkDetails(context); } }, itemBuilder: (_) => [if (network.dnsServers.isNotEmpty) const PopupMenuItem(value: 'copy', child: Text('کپی DNSهای فعلی')), const PopupMenuItem(value: 'details', child: Text('جزئیات اتصال'))], icon: const Icon(Icons.more_vert_rounded)),
    ]),
  );

  void _networkDetails(BuildContext context) {
    showModalBottomSheet<void>(context: context, showDragHandle: true, builder: (c) => SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(20, 4, 20, 24), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('جزئیات اتصال', style: AppTheme.displayStyle(size: 23, color: AppTheme.text(c))),
      const SizedBox(height: 14),
      _detailLine(c, 'نوع شبکه', network.transport),
      _detailLine(c, 'وضعیت اینترنت', network.internetAvailable ? 'تأییدشده توسط Android' : network.connected ? 'متصل، اما تأیید نشده' : 'بدون اتصال'),
      _detailLine(c, 'IPv4', network.ipv4 ?? 'در دسترس نیست'),
      _detailLine(c, 'IPv6', network.ipv6.isEmpty ? 'در دسترس نیست' : network.ipv6.join(' • ')),
      _detailLine(c, 'DNS فعلی', network.dnsServers.isEmpty ? 'Android گزارش نکرده' : network.dnsServers.join(' • ')),
      const SizedBox(height: 8),
      Text('این اطلاعات از وضعیت شبکه خود دستگاه Android خوانده می‌شوند و ممکن است با تغییر شبکه تغییر کنند.', style: TextStyle(color: AppTheme.subtle(c), fontSize: 9, height: 1.7)),
    ]))));
  }

  Widget _detailLine(BuildContext context, String label, String value) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 90, child: Text(label, style: TextStyle(color: AppTheme.subtle(context), fontSize: 10))), Expanded(child: Text(value, style: TextStyle(color: AppTheme.text(context), fontWeight: FontWeight.w700, fontSize: 11)))]));

  Widget _hero(BuildContext context) {
    final progress = totalServers == 0 ? 0.0 : completedServers / totalServers;
    final canTest = network.internetAvailable && !testing;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(26), gradient: const LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFF172A4F), Color(0xFF10182A)]), border: Border.all(color: AppTheme.primary.withValues(alpha: .18))),
      child: Column(children: [
        Container(width: 64, height: 64, decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.primary.withValues(alpha: .13)), child: const Icon(Icons.speed_rounded, color: AppTheme.primaryBright, size: 32)),
        const SizedBox(height: 13),
        Text(testing ? 'در حال آزمایش شبکه' : 'Benchmark کامل DNS', style: AppTheme.displayStyle(size: 23, color: Colors.white)),
        const SizedBox(height: 7),
        Text(testing ? '$completedServers از $totalServers سرویس بررسی شده' : network.internetAvailable ? 'سرعت، پایداری و قابلیت پاسخ‌گویی DNSها را مقایسه کن' : 'اتصال اینترنت تأیید نشده؛ تست DNS غیرفعال است', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white60, fontSize: 12, height: 1.6)),
        const SizedBox(height: 18),
        if (testing) ...[
          ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: progress, minHeight: 8, backgroundColor: Colors.white10)),
          const SizedBox(height: 10),
          Text('${(progress * 100).round()}٪', style: const TextStyle(color: AppTheme.primaryBright, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          OutlinedButton.icon(onPressed: onCancelTest, icon: const Icon(Icons.stop_rounded), label: const Text('توقف تست')),
        ] else Column(children: [
          SizedBox(width: double.infinity, height: 53, child: FilledButton.icon(onPressed: canTest ? onRunTest : null, icon: const Icon(Icons.play_arrow_rounded), label: const Text('تست کامل DNS', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)))),
          const SizedBox(height: 8),
          SizedBox(width: double.infinity, height: 44, child: OutlinedButton.icon(onPressed: canTest ? onQuickTest : null, icon: const Icon(Icons.flash_on_rounded, size: 19), label: const Text('تست سریع · ۳ نمونه'))),
        ]),
      ]),
    );
  }

  Widget _metrics(BuildContext context, Color surface, Color text) {
    final l = bestResult?.averageMs;
    final j = bestResult?.jitterMs;
    final loss = bestResult?.packetLossPercent;
    return Row(children: [
      Expanded(child: _metric(surface, text, Icons.bolt_rounded, 'Latency', l == null ? '—' : '${l.toStringAsFixed(0)} ms')),
      const SizedBox(width: 8),
      Expanded(child: _metric(surface, text, Icons.timeline_rounded, 'Jitter', j == null ? '—' : '${j.toStringAsFixed(1)} ms')),
      const SizedBox(width: 8),
      Expanded(child: _metric(surface, text, Icons.network_check_rounded, 'Loss', loss == null ? '—' : '${loss.toStringAsFixed(0)}٪')),
    ]);
  }

  Widget _healthCard(BuildContext context, Color surface, Color text, Color muted) {
    final health = NetworkHealth.from(network, bestResult);
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: .10)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.health_and_safety_rounded, color: health.score >= 70 ? AppTheme.success : AppTheme.warning),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('سلامت اتصال', style: TextStyle(color: text, fontWeight: FontWeight.w800)),
            const SizedBox(height: 3),
            Text(health.label, style: TextStyle(color: muted, fontSize: 10)),
          ])),
          if (bestResult != null) Text('${health.score}/100', style: TextStyle(color: text, fontWeight: FontWeight.w900, fontSize: 17)),
        ]),
        const SizedBox(height: 10),
        ...health.factors.map((f) => Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('• ', style: TextStyle(color: AppTheme.primaryBright)),
            Expanded(child: Text(f, style: TextStyle(color: muted, fontSize: 10, height: 1.5))),
          ]),
        )),
      ]),
    );
  }

  Widget _metric(Color surface, Color text, IconData icon, String label, String value) => Container(padding: const EdgeInsets.fromLTRB(12, 15, 12, 14), decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(18)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, size: 20, color: AppTheme.primaryBright), const SizedBox(height: 11), Text(label, style: TextStyle(color: text.withValues(alpha: .48), fontSize: 10)), const SizedBox(height: 4), Text(value, style: TextStyle(color: text, fontWeight: FontWeight.w800, fontSize: 14))]));

  Widget _bestCard(BuildContext context) => Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: AppTheme.success.withValues(alpha: .08), borderRadius: BorderRadius.circular(21), border: Border.all(color: AppTheme.success.withValues(alpha: .14))), child: Column(children: [Row(children: [const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFC857), size: 35), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('بهترین نتیجه برای همین اتصال', style: TextStyle(color: AppTheme.text(context).withValues(alpha: .58), fontSize: 10)), const SizedBox(height: 4), Text(bestResult!.server.name, style: TextStyle(color: AppTheme.text(context), fontWeight: FontWeight.w800, fontSize: 17)), Text('${bestResult!.server.primary} • ${bestResult!.averageMs.toStringAsFixed(0)} ms • J ${bestResult!.jitterMs.toStringAsFixed(1)} • L ${bestResult!.packetLossPercent.toStringAsFixed(0)}٪', style: TextStyle(color: AppTheme.text(context).withValues(alpha: .55), fontSize: 10))])), Text(bestResult!.score.toStringAsFixed(0), style: const TextStyle(color: AppTheme.success, fontWeight: FontWeight.w900, fontSize: 24))]), const SizedBox(height: 10), Align(alignment: Alignment.centerRight, child: TextButton.icon(onPressed: () async { await Clipboard.setData(ClipboardData(text: '${bestResult!.server.primary}\n${bestResult!.server.secondary}')); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('DNS پیشنهادی کپی شد.'))); }, icon: const Icon(Icons.copy_rounded, size: 17), label: const Text('کپی DNS پیشنهادی')))]));

  Widget _notice(BuildContext context, Color surface, Color muted) => Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(18)), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.info_outline_rounded, size: 20, color: AppTheme.primaryBright), const SizedBox(width: 10), Expanded(child: Text('Latency اینجا زمان پاسخ DNS به درخواست‌های واقعی است؛ Ping سرور بازی محسوب نمی‌شود. برای جزئیات کامل هر DNS، وارد بخش نتایج شو و روی کارت آن بزن.', style: TextStyle(color: muted, fontSize: 10, height: 1.7)))]));
}
