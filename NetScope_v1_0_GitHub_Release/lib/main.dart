import 'package:flutter/material.dart';
import 'data/app_storage.dart';
import 'presentation/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = AppStorage();
  final theme = await storage.loadTheme();
  runApp(_Root(initialTheme: theme, storage: storage));
}

class _Root extends StatefulWidget {
  final String initialTheme;
  final AppStorage storage;
  const _Root({required this.initialTheme, required this.storage});
  @override State<_Root> createState() => _RootState();
}

class _RootState extends State<_Root> {
  late ThemeMode mode = _parse(widget.initialTheme);

  ThemeMode _parse(String value) {
    switch (value) {
      case 'light': return ThemeMode.light;
      case 'system': return ThemeMode.system;
      default: return ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context) => NetScopeApp(
    themeMode: mode,
    onThemeChanged: (value) async {
      setState(() => mode = value);
      final stored = value == ThemeMode.light ? 'light' : value == ThemeMode.system ? 'system' : 'dark';
      await widget.storage.saveTheme(stored);
    },
  );
}
