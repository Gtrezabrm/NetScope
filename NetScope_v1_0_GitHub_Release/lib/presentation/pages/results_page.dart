import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/app_theme.dart';
import '../../domain/models/dns_sample.dart';
import '../../domain/models/dns_test_result.dart';
import '../../domain/models/dns_server.dart';

class ResultsPage extends StatefulWidget {
  final List<DnsTestResult> results;
  final List<Map<String, dynamic>> history;
  final Future<void> Function() onClearHistory;
  const ResultsPage({super.key, required this.results, required this.history, required this.onClearHistory});
  @override State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  final Set<String> _compare = <String>{};

  @override
  Widget build(BuildContext context) {
    final text = AppTheme.text(context);
    final muted = AppTheme.muted(context);
    return SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(20, 22, 20, 30), children: [
      Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('نتایج', style: AppTheme.displayStyle(size: 30, color: text)), const SizedBox(height: 4), Text(widget.results.isEmpty ? 'جزئیات تست‌های فعلی اینجا نمایش داده می‌شود' : '${widget.results.where((e) => e.isSuccessful).length} سرویس با موفقیت پاسخ دادند', style: TextStyle(color: muted, fontSize: 12))])), if (widget.history.isNotEmpty) IconButton(onPressed: () => _clearHistory(context), tooltip: 'پاک کردن تاریخچه', icon: const Icon(Icons.delete_sweep_outlined))]),
      const SizedBox(height: 12),
      if (widget.results.isNotEmpty) _summary(context),
      if (_compare.length >= 2) ...[const SizedBox(height: 12), _compareCard(context)],
      if (widget.results.isNotEmpty) const SizedBox(height: 14),
      if (widget.results.isEmpty) _empty(context) else ...widget.results.asMap().entries.map((e) => _card(context, e.key + 1, e.value)),
      if (widget.history.isNotEmpty) ...[const SizedBox(height: 22), Text('تاریخچه تست‌ها', style: AppTheme.displayStyle(size: 21, color: text)), const SizedBox(height: 10), ...widget.history.map((h) => _historyCard(context, h))],
    ]));
  }

  Widget _summary(BuildContext context) {
    final ok = widget.results.where((e) => e.isSuccessful).toList();
    final avg = ok.isEmpty ? null : ok.map((e) => e.averageMs).reduce((a, b) => a + b) / ok.length;
    final loss = widget.results.isEmpty ? null : widget.results.map((e) => e.packetLossPercent).reduce((a, b) => a + b) / widget.results.length;
    return Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: AppTheme.card(context), borderRadius: BorderRadius.circular(18)), child: Row(children: [
      Expanded(child: _summaryMetric(context, 'موفق', '${ok.length}/${widget.results.length}', Icons.check_circle_outline_rounded)),
      Expanded(child: _summaryMetric(context, 'میانگین', avg == null ? '—' : '${avg.toStringAsFixed(0)} ms', Icons.bolt_rounded)),
      Expanded(child: _summaryMetric(context, 'Loss', loss == null ? '—' : '${loss.toStringAsFixed(0)}٪', Icons.network_check_rounded)),
    ]));
  }

  Widget _summaryMetric(BuildContext context, String label, String value, IconData icon) => Column(children: [Icon(icon, size: 20, color: AppTheme.primaryBright), const SizedBox(height: 5), Text(value, style: TextStyle(color: AppTheme.text(context), fontWeight: FontWeight.w900, fontSize: 13)), Text(label, style: TextStyle(color: AppTheme.subtle(context), fontSize: 9))]);

  Widget _empty(BuildContext context) => Container(padding: const EdgeInsets.all(30), decoration: BoxDecoration(color: AppTheme.card(context), borderRadius: BorderRadius.circular(22)), child: Column(children: [Icon(Icons.analytics_outlined, size: 55, color: AppTheme.subtle(context)), const SizedBox(height: 12), Text('هنوز نتیجه‌ای نداریم', style: TextStyle(color: AppTheme.text(context), fontWeight: FontWeight.w800)), const SizedBox(height: 6), Text('از داشبورد تست سریع یا کامل را اجرا کن.', style: TextStyle(color: AppTheme.muted(context), fontSize: 11))]));

  Widget _card(BuildContext context, int rank, DnsTestResult r) {
    final selected = _compare.contains(r.server.id);
    return Container(margin: const EdgeInsets.only(bottom: 10), decoration: BoxDecoration(color: AppTheme.card(context), borderRadius: BorderRadius.circular(19), border: Border.all(color: selected ? AppTheme.primary.withValues(alpha: .55) : Colors.transparent)), child: InkWell(borderRadius: BorderRadius.circular(19), onTap: () => _details(context, r), child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [
      InkWell(onTap: () => _toggleCompare(r), borderRadius: BorderRadius.circular(12), child: Padding(padding: const EdgeInsets.all(3), child: Icon(selected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded, color: selected ? AppTheme.primaryBright : AppTheme.subtle(context), size: 22))),
      const SizedBox(width: 6),
      Container(width: 36, height: 36, alignment: Alignment.center, decoration: BoxDecoration(shape: BoxShape.circle, color: rank == 1 ? const Color(0x22FFC857) : AppTheme.text(context).withValues(alpha: .05)), child: rank == 1 ? const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFC857), size: 20) : Text('$rank', style: TextStyle(color: AppTheme.muted(context), fontWeight: FontWeight.w800))),
      const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(r.server.name, style: TextStyle(color: AppTheme.text(context), fontWeight: FontWeight.w800)), Text('${r.server.primary}${r.usedSecondary ? ' • fallback فعال' : ''}', style: TextStyle(color: AppTheme.muted(context), fontSize: 10))])),
      r.isSuccessful ? Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text('${r.averageMs.toStringAsFixed(0)} ms', style: TextStyle(color: AppTheme.text(context), fontWeight: FontWeight.w900)), Text('J ${r.jitterMs.toStringAsFixed(1)} • L ${r.packetLossPercent.toStringAsFixed(0)}٪', style: TextStyle(color: r.packetLossPercent == 0 ? AppTheme.success : AppTheme.warning, fontSize: 9))]) : Text(r.statusLabel, style: TextStyle(color: AppTheme.danger, fontSize: 10, fontWeight: FontWeight.w700)),
      const SizedBox(width: 4), Icon(Icons.chevron_left_rounded, color: AppTheme.subtle(context)),
    ]))));
  }

  void _toggleCompare(DnsTestResult r) {
    setState(() {
      if (_compare.contains(r.server.id)) { _compare.remove(r.server.id); }
      else if (_compare.length < 3) { _compare.add(r.server.id); }
      else { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('برای مقایسه حداکثر ۳ DNS انتخاب کن.'))); }
    });
  }

  Widget _compareCard(BuildContext context) {
    final selected = widget.results.where((r) => _compare.contains(r.server.id)).where((r) => r.isSuccessful).toList();
    if (selected.isEmpty) return const SizedBox.shrink();
    selected.sort((a, b) => a.score.compareTo(b.score));
    return Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: AppTheme.card(context), borderRadius: BorderRadius.circular(19), border: Border.all(color: AppTheme.primary.withValues(alpha: .18))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Expanded(child: Text('مقایسه انتخاب‌شده‌ها', style: TextStyle(color: AppTheme.text(context), fontWeight: FontWeight.w800))), TextButton(onPressed: () => setState(_compare.clear), child: const Text('پاک کردن'))]),
      const SizedBox(height: 6),
      ...selected.map((r) => Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Row(children: [Expanded(child: Text(r.server.name, style: TextStyle(color: AppTheme.text(context), fontWeight: FontWeight.w700))), Text('${r.averageMs.toStringAsFixed(0)} ms', style: TextStyle(color: AppTheme.text(context), fontWeight: FontWeight.w800)), const SizedBox(width: 10), Text('J ${r.jitterMs.toStringAsFixed(1)}', style: TextStyle(color: AppTheme.muted(context), fontSize: 10)), const SizedBox(width: 10), Text('L ${r.packetLossPercent.toStringAsFixed(0)}٪', style: TextStyle(color: r.packetLossPercent == 0 ? AppTheme.success : AppTheme.warning, fontSize: 10))]))),
      const SizedBox(height: 5), Text('مقایسه بر اساس همین اجرای تست است؛ نتیجه عمومی یا دائمی نیست.', style: TextStyle(color: AppTheme.subtle(context), fontSize: 9)),
    ]));
  }

  Future<void> _details(BuildContext context, DnsTestResult r) async {
    final text = AppTheme.text(context);
    await showModalBottomSheet<void>(context: context, isScrollControlled: true, showDragHandle: true, builder: (sheetContext) => SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(20, 4, 20, 20), child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(r.server.name, style: AppTheme.displayStyle(size: 25, color: text)), Text('${r.server.primary} • ${r.server.secondary}', style: TextStyle(color: AppTheme.muted(context), fontSize: 11))])), IconButton(onPressed: () => _copyDns(context, r.server), icon: const Icon(Icons.copy_all_rounded), tooltip: 'کپی DNS')]),
      const SizedBox(height: 16), Wrap(spacing: 8, runSpacing: 8, children: [_pill(context, 'Latency', r.isSuccessful ? '${r.averageMs.toStringAsFixed(1)} ms' : '—'), _pill(context, 'Median', r.isSuccessful ? '${r.medianMs.toStringAsFixed(1)} ms' : '—'), _pill(context, 'Jitter', '${r.jitterMs.toStringAsFixed(1)} ms'), _pill(context, 'Loss', '${r.packetLossPercent.toStringAsFixed(1)}٪'), _pill(context, 'Min/Max', r.isSuccessful ? '${r.minMs}/${r.maxMs} ms' : '—'), _pill(context, 'Score', r.isSuccessful ? r.score.toStringAsFixed(0) : '—')]),
      const SizedBox(height: 18), Row(children: [Expanded(child: Text('ریز تست‌ها', style: TextStyle(color: text, fontWeight: FontWeight.w800, fontSize: 15))), TextButton.icon(onPressed: () async { await Clipboard.setData(ClipboardData(text: _buildReport(r))); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('گزارش در کلیپ‌بورد کپی شد.'))); }, icon: const Icon(Icons.copy_rounded, size: 16), label: const Text('کپی گزارش'))]),
      const SizedBox(height: 8), if (r.sampleDetails.isEmpty) Text(r.error ?? 'جزئیاتی ثبت نشده است.', style: TextStyle(color: AppTheme.muted(context))), ...r.sampleDetails.map((s) => _sampleRow(context, s)),
      const SizedBox(height: 8), Text('Loss در این صفحه بر اساس دورهای بدون پاسخ موفق محاسبه شده است. اگر Primary شکست بخورد ولی Secondary پاسخ دهد، آن دور موفق محسوب می‌شود و fallback ثبت می‌شود.', style: TextStyle(color: AppTheme.subtle(context), fontSize: 9, height: 1.7)),
    ])))));
  }

  Future<void> _copyDns(BuildContext context, DnsServer server) async {
    await Clipboard.setData(ClipboardData(text: '${server.primary}\n${server.secondary}'));
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Primary و Secondary کپی شدند.')));
  }

  String _buildReport(DnsTestResult r) { final b = StringBuffer(); b.writeln('NetScope - ${r.server.name}'); b.writeln('Primary: ${r.server.primary}'); b.writeln('Secondary: ${r.server.secondary}'); b.writeln('Latency: ${r.isSuccessful ? r.averageMs.toStringAsFixed(1) : '-'} ms'); b.writeln('Median: ${r.isSuccessful ? r.medianMs.toStringAsFixed(1) : '-'} ms'); b.writeln('Jitter: ${r.jitterMs.toStringAsFixed(1)} ms'); b.writeln('Loss: ${r.packetLossPercent.toStringAsFixed(1)}%'); b.writeln('Score: ${r.isSuccessful ? r.score.toStringAsFixed(0) : '-'}'); for (final s in r.sampleDetails) { b.writeln('#${s.index} ${s.domain} -> ${s.endpoint}: ${s.success ? '${s.latencyMs} ms' : 'failed'}'); } return b.toString(); }
  Widget _pill(BuildContext context, String label, String value) => Container(padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9), decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(13)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(color: AppTheme.subtle(context), fontSize: 8)), const SizedBox(height: 2), Text(value, style: TextStyle(color: AppTheme.text(context), fontWeight: FontWeight.w800, fontSize: 11))]));
  Widget _sampleRow(BuildContext context, DnsSample s) => Container(margin: const EdgeInsets.only(bottom: 7), padding: const EdgeInsets.all(11), decoration: BoxDecoration(color: AppTheme.card(context), borderRadius: BorderRadius.circular(13)), child: Row(children: [Text('#${s.index}', style: TextStyle(color: AppTheme.muted(context), fontWeight: FontWeight.w800, fontSize: 10)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(s.domain, style: TextStyle(color: AppTheme.text(context), fontWeight: FontWeight.w700, fontSize: 11)), Text('${s.endpoint}${s.usedSecondary ? ' • Secondary' : ' • Primary'}', style: TextStyle(color: AppTheme.subtle(context), fontSize: 9))])), Icon(s.success ? Icons.check_circle_rounded : Icons.error_outline_rounded, color: s.success ? AppTheme.success : AppTheme.danger, size: 18), const SizedBox(width: 8), Text(s.success ? '${s.latencyMs} ms' : 'ناموفق', style: TextStyle(color: s.success ? AppTheme.text(context) : AppTheme.danger, fontWeight: FontWeight.w800, fontSize: 10))]));
  Widget _historyCard(BuildContext context, Map<String, dynamic> h) { final at = DateTime.tryParse('${h['at']}'); return Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppTheme.card(context), borderRadius: BorderRadius.circular(16)), child: Row(children: [const Icon(Icons.history_rounded, color: AppTheme.primaryBright), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${h['successful'] ?? 0} از ${h['tested'] ?? 0} موفق', style: TextStyle(color: AppTheme.text(context), fontWeight: FontWeight.w700)), Text('بهترین: ${h['bestName'] ?? '—'}', style: TextStyle(color: AppTheme.subtle(context), fontSize: 10))])), Text(at == null ? '—' : '${at.year}/${at.month}/${at.day}', style: TextStyle(color: AppTheme.subtle(context), fontSize: 9))])); }
  Future<void> _clearHistory(BuildContext context) async { final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: const Text('پاک کردن تاریخچه؟'), content: const Text('نتایج ذخیره‌شده قبلی حذف می‌شوند.'), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('انصراف')), FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('پاک کردن'))])); if (ok == true) await widget.onClearHistory(); }
}
