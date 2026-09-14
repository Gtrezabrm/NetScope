import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const background = Color(0xFF070B14);
  static const surface = Color(0xFF0E1626);
  static const surface2 = Color(0xFF121D31);
  static const primary = Color(0xFF5B8CFF);
  static const primaryBright = Color(0xFF80A9FF);
  static const success = Color(0xFF37D89B);
  static const warning = Color(0xFFFFB84D);
  static const danger = Color(0xFFFF6577);

  static ThemeData dark() => _theme(Brightness.dark);
  static ThemeData light() => _theme(Brightness.light);

  static ThemeData _theme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(seedColor: primary, brightness: brightness).copyWith(
      primary: primary,
      onPrimary: Colors.white,
      surface: dark ? surface : const Color(0xFFF7F9FD),
      onSurface: dark ? Colors.white : const Color(0xFF172033),
      surfaceContainerHighest: dark ? surface2 : const Color(0xFFEFF3F9),
      outline: dark ? Colors.white24 : const Color(0xFFCCD3DF),
    );
    final base = ThemeData(useMaterial3: true, brightness: brightness, colorScheme: scheme);
    final textTheme = GoogleFonts.vazirmatnTextTheme(base.textTheme).apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );
    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: dark ? background : const Color(0xFFF4F7FC),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: dark ? background : const Color(0xFFF4F7FC),
        foregroundColor: scheme.onSurface,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: dark ? surface : Colors.white,
        indicatorColor: primary.withValues(alpha: 0.20),
        labelTextStyle: WidgetStatePropertyAll(GoogleFonts.vazirmatn(fontSize: 11, fontWeight: FontWeight.w600, color: scheme.onSurface)),
      ),
      cardTheme: CardThemeData(
        color: dark ? surface : Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: dark ? surface : Colors.white,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.vazirmatn(fontSize: 19, fontWeight: FontWeight.w800, color: scheme.onSurface),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? surface2 : Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: dark ? const Color(0xFF202A3B) : const Color(0xFF172033),
        contentTextStyle: GoogleFonts.vazirmatn(fontSize: 12, color: Colors.white),
      ),
    );
  }

  static TextStyle displayStyle({double size = 28, Color? color}) => GoogleFonts.lalezar(fontSize: size, color: color, height: 1.1);
  static Color text(BuildContext context) => Theme.of(context).colorScheme.onSurface;
  static Color muted(BuildContext context) => Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.62);
  static Color subtle(BuildContext context) => Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.40);
  static Color card(BuildContext context) => Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface;
}
