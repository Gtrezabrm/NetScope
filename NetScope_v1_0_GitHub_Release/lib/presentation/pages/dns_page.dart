import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/app_theme.dart';
import '../../domain/models/dns_server.dart';

class DnsPage extends StatefulWidget {
  final List<DnsServer> servers;
  final Future<void> Function(DnsServer) onAdd;
  final Future<void> Function(String) onRemove;
  const DnsPage({super.key, required this.servers, required this.onAdd, required this.onRemove});
  @override State<DnsPage> createState() => _DnsPageState();
}

class _DnsPageState extends State<DnsPage> {
  bool iranOnly = false;
  String query = '';

  @override
  Widget build(BuildContext context) {
    final q = query.trim().toLowerCase();
    final list = widget.servers.where((e) => (!iranOnly || e.region == DnsRegion.iran) && (q.isEmpty || '${e.name} ${e.primary} ${e.secondary}'.toLowerCase().contains(q))).toList();
    final text = AppTheme.text(context);
    final muted = AppTheme.muted(context);
    return SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(20, 22, 20, 30), children: [
      Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('DNSها', style: AppTheme.displayStyle(size: 30, color: text)), const SizedBox(height: 4), Text('${widget.servers.length} سرویس آماده تست', style: TextStyle(color: muted, fontSize: 12))])), IconButton.filledTonal(onPressed: () => _addDialog(context), icon: const Icon(Icons.add_rounded), tooltip: 'افزودن DNS')]),
      const SizedBox(height: 14),
      TextField(onChanged: (v) => setState(() => query = v), decoration: const InputDecoration(prefixIcon: Icon(Icons.search_rounded), hintText: 'جست‌وجوی نام یا IP')),
      const SizedBox(height: 12),
      SegmentedButton<bool>(segments: const [ButtonSegment(value: false, label: Text('همه')), ButtonSegment(value: true, label: Text('ایران'))], selected: {iranOnly}, onSelectionChanged: (v) => setState(() => iranOnly = v.first)),
      const SizedBox(height: 18),
      if (list.isEmpty) Container(padding: const EdgeInsets.all(28), decoration: BoxDecoration(color: AppTheme.card(context), borderRadius: BorderRadius.circular(20)), child: Center(child: Text('DNS موردنظر پیدا نشد.', style: TextStyle(color: muted)))) else ...list.map(_tile),
    ]));
  }

  Widget _tile(DnsServer dns) {
    final iran = dns.region == DnsRegion.iran;
    final text = AppTheme.text(context);
    final muted = AppTheme.muted(context);
    return Container(margin: const EdgeInsets.only(bottom: 11), padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: AppTheme.card(context), borderRadius: BorderRadius.circular(19), border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: .10))), child: Row(children: [
      Container(width: 46, height: 46, decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: (iran ? AppTheme.warning : AppTheme.primary).withValues(alpha: .11)), child: Icon(iran ? Icons.flag_rounded : Icons.public_rounded, color: iran ? AppTheme.warning : AppTheme.primaryBright)),
      const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(dns.name, style: TextStyle(color: text, fontWeight: FontWeight.w800)), const SizedBox(height: 4), Text('${dns.primary}  •  ${dns.secondary}', style: TextStyle(color: muted, fontSize: 11)), Text(dns.description, style: TextStyle(color: AppTheme.subtle(context), fontSize: 9))])),
      Column(mainAxisSize: MainAxisSize.min, children: [
        IconButton(onPressed: () async { await Clipboard.setData(ClipboardData(text: '${dns.primary}\n${dns.secondary}')); if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Primary و Secondary کپی شدند.'))); }, icon: const Icon(Icons.copy_rounded, size: 19), tooltip: 'کپی DNS'),
        if (dns.userAdded) PopupMenuButton<String>(onSelected: (v) { if (v == 'delete') widget.onRemove(dns.id); }, itemBuilder: (_) => const [PopupMenuItem(value: 'delete', child: Text('حذف DNS'))]) else Text(iran ? 'ایران' : 'جهانی', style: TextStyle(color: iran ? AppTheme.warning : AppTheme.primaryBright, fontSize: 10, fontWeight: FontWeight.w700)),
      ]),
    ]));
  }

  Future<void> _addDialog(BuildContext context) async {
    final name = TextEditingController(), primary = TextEditingController(), secondary = TextEditingController(), primaryV6 = TextEditingController(), secondaryV6 = TextEditingController();
    final form = GlobalKey<FormState>();
    final result = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(title: const Text('افزودن DNS'), content: SingleChildScrollView(child: Form(key: form, child: Column(mainAxisSize: MainAxisSize.min, children: [
      TextFormField(controller: name, decoration: const InputDecoration(labelText: 'نام DNS'), validator: (v) => v == null || v.trim().isEmpty ? 'نام را وارد کن' : null),
      const SizedBox(height: 10),
      TextFormField(controller: primary, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Primary IPv4'), validator: _validIp),
      const SizedBox(height: 10),
      TextFormField(controller: secondary, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Secondary IPv4 (اختیاری)'), validator: (v) => v == null || v.trim().isEmpty ? null : _validIp(v)),
      const SizedBox(height: 10),
      TextFormField(controller: primaryV6, decoration: const InputDecoration(labelText: 'Primary IPv6 (اختیاری)'), validator: _validV6),
      const SizedBox(height: 10),
      TextFormField(controller: secondaryV6, decoration: const InputDecoration(labelText: 'Secondary IPv6 (اختیاری)'), validator: _validV6),
    ]))), actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('انصراف')), FilledButton(onPressed: () { if (!form.currentState!.validate()) return; final p = primary.text.trim(); final s = secondary.text.trim().isEmpty ? p : secondary.text.trim(); widget.onAdd(DnsServer(id: 'custom_${DateTime.now().microsecondsSinceEpoch}', name: name.text.trim(), primary: p, secondary: s, primaryV6: primaryV6.text.trim().isEmpty ? null : primaryV6.text.trim(), secondaryV6: secondaryV6.text.trim().isEmpty ? null : secondaryV6.text.trim(), region: DnsRegion.global, description: 'DNS افزوده‌شده توسط کاربر', userAdded: true)); Navigator.pop(dialogContext, true); }, child: const Text('افزودن'))]));
    name.dispose(); primary.dispose(); secondary.dispose(); primaryV6.dispose(); secondaryV6.dispose();
    if (result == true && mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('DNS با موفقیت اضافه شد.')));
  }

  String? _validIp(String? value) { final s = value?.trim() ?? ''; final parts = s.split('.'); if (parts.length != 4) return 'IPv4 معتبر وارد کن'; for (final p in parts) { final n = int.tryParse(p); if (n == null || n < 0 || n > 255) return 'IPv4 معتبر وارد کن'; } return null; }
  String? _validV6(String? value) { final s = value?.trim() ?? ''; if (s.isEmpty) return null; if (!s.contains(':')) return 'IPv6 معتبر وارد کن'; return null; }
}
