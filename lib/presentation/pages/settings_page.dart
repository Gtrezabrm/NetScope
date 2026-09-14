import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import 'advanced_diagnostics_page.dart';

class SettingsPage extends StatelessWidget {
  final int samples;
  final ThemeMode themeMode;
  final Future<void> Function(int) onSamplesChanged;
  final ValueChanged<ThemeMode> onThemeChanged;
  final Future<void> Function() onClearHistory;
  const SettingsPage({super.key, required this.samples, required this.themeMode, required this.onSamplesChanged, required this.onThemeChanged, required this.onClearHistory});

  @override
  Widget build(BuildContext context) {
    final text = AppTheme.text(context);
    final muted = AppTheme.muted(context);
    return SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(20, 22, 20, 30), children: [
      Text('تنظیمات', style: AppTheme.displayStyle(size: 30, color: text)),
      const SizedBox(height: 18),
      _item(context, Icons.timer_outlined, 'تعداد نمونه‌ها', '$samples درخواست برای هر DNS', () => _samplesDialog(context)),
      _item(context, Icons.palette_outlined, 'ظاهر برنامه', 'تاریک، روشن یا هماهنگ با سیستم', () => _themeDialog(context)),
      _item(context, Icons.biotech_rounded, 'تشخیص‌های پیشرفته', 'IPv6، DoH و DoT', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdvancedDiagnosticsPage()))),
      _item(context, Icons.delete_sweep_outlined, 'پاک کردن تاریخچه', 'حذف نتایج ذخیره‌شده قبلی', () => _clearHistory(context)),
      _item(context, Icons.route_rounded, 'روش اندازه‌گیری', 'توضیح دقیق روش سنجش DNS و Gaming', () => _methodDialog(context)),
      _item(context, Icons.info_outline_rounded, 'درباره NetScope', 'نسخه 1.0.0 • ابزار تشخیص شبکه', () => _about(context)),
      Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppTheme.card(context), borderRadius: BorderRadius.circular(18)), child: Text('NetScope برای انتخاب DNS، زمان پاسخ و پایداری شبکه را اندازه می‌گیرد. بخش Gaming اتصال TCP به مقصدهای مشخص را بررسی می‌کند و نتیجه آن Ping داخل بازی نیست.', style: TextStyle(color: muted, fontSize: 11, height: 1.7))),
    ]));
  }

  Widget _item(BuildContext context, IconData icon, String title, String subtitle, VoidCallback action) => Container(margin: const EdgeInsets.only(bottom: 10), decoration: BoxDecoration(color: AppTheme.card(context), borderRadius: BorderRadius.circular(18)), child: ListTile(onTap: action, leading: Container(width: 42, height: 42, decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: .10), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: AppTheme.primaryBright)), title: Text(title, style: TextStyle(color: AppTheme.text(context), fontWeight: FontWeight.w700)), subtitle: Text(subtitle, style: TextStyle(color: AppTheme.subtle(context), fontSize: 10)), trailing: Icon(Icons.chevron_left_rounded, color: AppTheme.subtle(context))));

  Future<void> _samplesDialog(BuildContext context) async { var value = samples; await showDialog<void>(context: context, builder: (dialogContext) => StatefulBuilder(builder: (context, setLocal) => AlertDialog(title: const Text('تعداد نمونه‌ها'), content: Column(mainAxisSize: MainAxisSize.min, children: [Text('$value درخواست برای هر DNS', style: const TextStyle(fontWeight: FontWeight.w700)), Slider(min: 3, max: 10, divisions: 7, value: value.toDouble(), onChanged: (v) => setLocal(() => value = v.round()))]), actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('انصراف')), FilledButton(onPressed: () { onSamplesChanged(value); Navigator.pop(dialogContext); }, child: const Text('ذخیره'))]))); }

  Future<void> _themeDialog(BuildContext context) async {
    var selected = themeMode;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(builder: (context, setLocal) => AlertDialog(
        title: const Text('ظاهر برنامه'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          RadioListTile<ThemeMode>(value: ThemeMode.dark, groupValue: selected, onChanged: (v) { if (v != null) { setLocal(() => selected = v); onThemeChanged(v); Navigator.pop(dialogContext); } }, title: const Text('تاریک')),
          RadioListTile<ThemeMode>(value: ThemeMode.light, groupValue: selected, onChanged: (v) { if (v != null) { setLocal(() => selected = v); onThemeChanged(v); Navigator.pop(dialogContext); } }, title: const Text('روشن')),
          RadioListTile<ThemeMode>(value: ThemeMode.system, groupValue: selected, onChanged: (v) { if (v != null) { setLocal(() => selected = v); onThemeChanged(v); Navigator.pop(dialogContext); } }, title: const Text('هماهنگ با سیستم')),
        ]),
      )),
    );
  }

  Future<void> _clearHistory(BuildContext context) async { final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: const Text('پاک کردن تاریخچه؟'), content: const Text('تمام نتایج ذخیره‌شده قبلی حذف می‌شوند.'), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('انصراف')), FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('پاک کردن'))])); if (ok == true) await onClearHistory(); }

  void _methodDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Directionality(textDirection: TextDirection.rtl, child: Text('روش اندازه‌گیری')),
        content: const Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
            child: Text(
              '''در NetScope، هر عدد باید قابل توضیح باشد.

• DNS Benchmark
به هر Resolver انتخاب‌شده مستقیماً روی UDP/53 درخواست DNS فرستاده می‌شود. زمان از ارسال درخواست تا دریافت پاسخ اندازه‌گیری می‌شود و برای محاسبه Latency از سرور واسطه استفاده نمی‌کنیم.

• Gaming / TCP Connectivity
به مقصد مشخص روی TCP و Port مشخص اتصال برقرار می‌شود. زمان برقراری اتصال اندازه‌گیری می‌شود. این عدد Ping داخل بازی یا ICMP Ping نیست.

• وضعیت اتصال
«باز» یعنی مقصد اتصال TCP را پذیرفته است. «بسته / رد شد» یعنی مقصد صریحاً اتصال را رد کرده است. «فیلترشده / بدون پاسخ» یعنی در مهلت تست پاسخ قابل اتکا دریافت نشده است؛ Timeout به‌تنهایی اثبات نمی‌کند Port واقعاً بسته است.

• Loss
در DNS، Loss درصد دورهای بدون پاسخ موفق است. در Gaming، Loss نرخ تلاش‌های ناموفق TCP است. این دو معادل Packet Loss واقعی ICMP یا UDP نیستند.

• نتیجه‌ها
بهترین DNS برای اتصال فعلی کاربر انتخاب می‌شود؛ هیچ DNS یا مسیر شبکه‌ای به‌صورت جهانی «بهترین» فرض نمی‌شود.''',
              textAlign: TextAlign.right,
              style: TextStyle(height: 1.8),
            ),
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('بستن'))],
      ),
    );
  }

  void _about(BuildContext context) => showAboutDialog(context: context, applicationName: 'NetScope', applicationVersion: '1.0.0', applicationLegalese: 'Android-first DNS & Network Diagnostics', children: const [SizedBox(height: 12), Directionality(textDirection: TextDirection.rtl, child: Text('''NetScope یک ابزار متن‌باز برای سنجش DNS، پایداری شبکه و قابلیت اتصال است. این پروژه برای ارائه یک تصویر شفاف و قابل‌اندازه‌گیری از وضعیت اتصال کاربر ساخته شده است.

ساخته‌شده با ❤️ توسط Gtrezabrm''', textAlign: TextAlign.right))]);
}
