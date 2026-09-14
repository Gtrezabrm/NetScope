import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import 'shell.dart';

class NetScopeApp extends StatelessWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;
  const NetScopeApp({super.key, required this.themeMode, required this.onThemeChanged});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'NetScope',
    theme: AppTheme.light(),
    darkTheme: AppTheme.dark(),
    themeMode: themeMode,
    locale: const Locale('fa'),
    home: Directionality(textDirection: TextDirection.rtl, child: AppShell(themeMode: themeMode, onThemeChanged: onThemeChanged)),
  );
}
