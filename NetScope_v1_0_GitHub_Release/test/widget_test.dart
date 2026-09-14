import 'package:flutter_test/flutter_test.dart';
import 'package:netscope/presentation/app.dart';

void main() {
  testWidgets('NetScope app builds', (tester) async {
    await tester.pumpWidget(
      NetScopeApp(
        themeMode: ThemeMode.system,
        onThemeChanged: (_) {},
      ),
    );
    expect(find.text('داشبورد'), findsOneWidget);
  });
}
