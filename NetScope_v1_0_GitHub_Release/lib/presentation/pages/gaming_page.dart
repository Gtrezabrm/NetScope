import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../domain/services/gaming_diagnostics_service.dart';

class GamingPage extends StatefulWidget {
  final int repetitions;
  const GamingPage({super.key, required this.repetitions});
  @override State<GamingPage> createState() => _GamingPageState();
}

class _GamingPageState extends State<GamingPage> {
  final service = const GamingDiagnosticsService();
  final hostController = TextEditingController();
  final portController = TextEditingController(text: '443');
  bool running = false;
  bool cancelRequested = false;
  List<GamingTargetResult> results = const [];

  @override
  void dispose() { hostController.dispose(); portController.dispose(); super.dispose(); }

  Future<void> run() async {
    if (running) return;
    final customHost = hostController.text.trim();
    final port = int.tryParse(portController.text.trim()) ?? 443;
    if (port < 1 || port > 65535) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('پورت باید بین 1 تا 65535 باشد.')));
      return;
    }
    setState(() { running = true; cancelRequested = false; results = const []; });
    final r = await service.run(
      repetitions: widget.repetitions,
      customHost: customHost.isEmpty ? null : customHost,
      customPort: port,
      shouldContinue: () => mounted && !cancelRequested,
    );
    if (!mounted) return;
    setState(() { running = false; results = r; });
  }

  void cancel() => setState(() => cancelRequested = true);

  @override
  Widget build(BuildContext context) {
    final text = AppTheme.text(context);
    final muted = AppTheme.muted(context);
    final ok = results.where((e) => e.success).toList();
    return SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(20, 22, 20, 30), children: [
      Text('Gaming Diagnostics', style: AppTheme.displayStyle(size: 29, color: text)),
      const SizedBox(height: 4),
      Text('قابلیت اتصال TCP به چند مقصد عمومی و سرویس گیمینگ را می‌سنجد؛ این عدد Ping سرور واقعی بازی نیست.', style: TextStyle(color: muted, fontSize: 12, height: 1.5)),
      const SizedBox(height: 12),
      Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppTheme.card(context), borderRadius: BorderRadius.circular(22)), child: Column(children: [
        const Icon(Icons.sports_esports_rounded, size: 48, color: AppTheme.primaryBright),
        const SizedBox(height: 10),
        Text(running ? 'در حال بررسی مسیر...' : 'تست اتصال و پورت', style: AppTheme.displayStyle(size: 21, color: text)),
        const SizedBox(height: 8),
        Text('سه مقصد عمومی و گیمینگ برای سنجش قابلیت اتصال TCP بررسی می‌شوند. برای بررسی وضعیت یک پورت مشخص، Host/IP معتبر همان سرویس را وارد کن. فقط در این حالت NetScope می‌تواند نتیجه را برای همان مقصد به‌صورت باز، بسته یا فیلترشده گزارش کند.', textAlign: TextAlign.center, style: TextStyle(color: muted, fontSize: 11, height: 1.6)),
        const SizedBox(height: 14),
        Container(width: double.infinity, padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: .07), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.primary.withValues(alpha: .12))), child: const Text('NetScope مستقیماً اتصال TCP به مقصدهای مشخص را بررسی می‌کند. «باز» یعنی اتصال TCP پذیرفته شده، «بسته» یعنی مقصد اتصال را رد کرده و «فیلترشده/بدون پاسخ» یعنی در مهلت تست پاسخی دریافت نشده است. این نتیجه فقط درباره همان مقصد و پورت است و وضعیت سرورهای واقعی بازی را تضمین نمی‌کند.', style: TextStyle(fontSize: 10, height: 1.7))),
        const SizedBox(height: 14),
        Row(children: [Expanded(child: TextField(controller: hostController, decoration: const InputDecoration(labelText: 'Host / IP مقصد', hintText: 'مثلاً example.com'))), const SizedBox(width: 8), SizedBox(width: 92, child: TextField(controller: portController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Port')))]),
        const SizedBox(height: 14),
        SizedBox(width: double.infinity, height: 50, child: FilledButton.icon(onPressed: running ? null : run, icon: Icon(running ? Icons.hourglass_top_rounded : Icons.play_arrow_rounded), label: Text(running ? 'در حال تست' : 'شروع تست'))),
        if (running) ...[const SizedBox(height: 8), TextButton.icon(onPressed: cancel, icon: const Icon(Icons.stop_rounded), label: const Text('توقف'))],
      ])),
      if (ok.isNotEmpty) ...[const SizedBox(height: 14), _overall(context, ok)],
      const SizedBox(height: 14),
      ...results.map((r) => _targetCard(context, r)),
      if (results.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Text('در این بخش، Loss نرخ شکست اتصال TCP است؛ Packet Loss واقعی ICMP یا UDP نیست. «بسته» فقط وقتی گزارش می‌شود که مقصد مشخصاً اتصال را رد کند؛ Timeout/عدم پاسخ به‌عنوان «فیلترشده یا غیرقابل‌دسترسی» نمایش داده می‌شود.', style: TextStyle(color: AppTheme.subtle(context), fontSize: 10, height: 1.7))),
    ]));
  }

  Widget _overall(BuildContext context, List<GamingTargetResult> ok) {
    final avg = ok.map((e) => e.averageMs).reduce((a, b) => a + b) / ok.length;
    final jitter = ok.map((e) => e.jitterMs).reduce((a, b) => a + b) / ok.length;
    final loss = results.map((e) => e.lossPercent).reduce((a, b) => a + b) / results.length;
    return Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: AppTheme.card(context), borderRadius: BorderRadius.circular(18)), child: Row(children: [Expanded(child: _metric(context, 'Latency', '${avg.toStringAsFixed(0)} ms')), Expanded(child: _metric(context, 'Jitter', '${jitter.toStringAsFixed(1)} ms')), Expanded(child: _metric(context, 'Loss', '${loss.toStringAsFixed(0)}٪'))]));
  }

  Widget _metric(BuildContext context, String label, String value) => Column(children: [Text(value, style: TextStyle(color: AppTheme.text(context), fontWeight: FontWeight.w900, fontSize: 13)), const SizedBox(height: 3), Text(label, style: TextStyle(color: AppTheme.subtle(context), fontSize: 9))]);

  String _statusLabel(GamingTargetResult r) {
    switch (r.status) {
      case PortStatus.open: return 'باز';
      case PortStatus.closed: return 'بسته / رد شد';
      case PortStatus.filtered: return 'فیلترشده / بدون پاسخ';
      case PortStatus.error: return 'خطای اتصال';
    }
  }

  Color _statusColor(BuildContext context, GamingTargetResult r) {
    switch (r.status) {
      case PortStatus.open: return AppTheme.success;
      case PortStatus.closed: return AppTheme.danger;
      case PortStatus.filtered: return AppTheme.warning;
      case PortStatus.error: return AppTheme.subtle(context);
    }
  }

  Widget _targetCard(BuildContext context, GamingTargetResult r) => Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: AppTheme.card(context), borderRadius: BorderRadius.circular(18)), child: Column(children: [Row(children: [Icon(r.success ? Icons.check_circle_rounded : Icons.error_rounded, color: _statusColor(context, r)), const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(r.name, style: TextStyle(color: AppTheme.text(context), fontWeight: FontWeight.w800)), Text('Target: ${r.host}:${r.port} • TCP • ${r.successes}/${r.attempts} موفق', style: TextStyle(color: AppTheme.subtle(context), fontSize: 10)), const SizedBox(height: 3), Text(_statusLabel(r), style: TextStyle(color: _statusColor(context, r), fontWeight: FontWeight.w800, fontSize: 10))])), Text(r.success ? '${r.averageMs.toStringAsFixed(0)} ms' : '—', style: TextStyle(color: AppTheme.text(context), fontWeight: FontWeight.w900))]), if (r.attempts > 0) Padding(padding: const EdgeInsets.only(top: 12), child: Row(children: [Expanded(child: Text('Jitter ${r.jitterMs.toStringAsFixed(1)} ms', style: TextStyle(color: AppTheme.muted(context), fontSize: 10))), Text('Loss ${r.lossPercent.toStringAsFixed(0)}٪', style: TextStyle(color: r.lossPercent == 0 ? AppTheme.success : AppTheme.warning, fontWeight: FontWeight.w700, fontSize: 10))]))]));
}
