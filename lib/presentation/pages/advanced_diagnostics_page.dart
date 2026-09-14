import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../domain/services/advanced_diagnostics_service.dart';

class AdvancedDiagnosticsPage extends StatefulWidget { const AdvancedDiagnosticsPage({super.key}); @override State<AdvancedDiagnosticsPage> createState() => _AdvancedDiagnosticsPageState(); }
class _AdvancedDiagnosticsPageState extends State<AdvancedDiagnosticsPage> {
  final service = AdvancedDiagnosticsService();
  bool running = false;
  final results = <DiagnosticResult>[];

  Future<void> run() async {
    if (running) return;
    setState(() => running = true);
    final out = <DiagnosticResult>[];
    out.add(await service.testIpv6Dns('2606:4700:4700::1111'));
    out.add(await service.testDoH());
    out.add(await service.testDoT());
    if (!mounted) return;
    setState(() { results..clear()..addAll(out); running = false; });
  }

  @override
  Widget build(BuildContext context) {
    final text = AppTheme.text(context);
    final muted = AppTheme.muted(context);
    return Scaffold(appBar: AppBar(title: const Text('تشخیص‌های پیشرفته')), body: ListView(padding: const EdgeInsets.all(20), children: [
      Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppTheme.card(context), borderRadius: BorderRadius.circular(22)), child: Column(children: [
        const Icon(Icons.biotech_rounded, size: 48, color: AppTheme.primaryBright), const SizedBox(height: 12), Text('IPv6 + DoH + DoT', style: TextStyle(color: text, fontSize: 19, fontWeight: FontWeight.w900)), const SizedBox(height: 8),
        Text('این تست‌ها دسترسی مسیرهای مدرن DNS را بررسی می‌کنند. نتیجه DoH/DoT نشان‌دهنده دسترسی است، نه تضمین سریع‌تر بودن آن.', textAlign: TextAlign.center, style: TextStyle(color: muted, fontSize: 11, height: 1.6)), const SizedBox(height: 16),
        SizedBox(width: double.infinity, height: 50, child: FilledButton.icon(onPressed: running ? null : run, icon: const Icon(Icons.play_arrow_rounded), label: Text(running ? 'در حال بررسی' : 'اجرای تست‌ها'))),
      ])),
      const SizedBox(height: 14),
      ...results.map((r) => Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: AppTheme.card(context), borderRadius: BorderRadius.circular(18)), child: Row(children: [Icon(r.success ? Icons.check_circle_rounded : Icons.error_rounded, color: r.success ? AppTheme.success : AppTheme.danger), const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(r.name, style: TextStyle(color: text, fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text(r.detail, style: TextStyle(color: AppTheme.subtle(context), fontSize: 10))])), Text(r.latencyMs == null ? '—' : '${r.latencyMs} ms', style: TextStyle(color: text, fontWeight: FontWeight.w800))]))),
    ]));
  }
}
