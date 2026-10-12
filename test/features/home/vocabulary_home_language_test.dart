import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lang/language/app_language.dart';
import 'package:lang/language/app_language_controller.dart';
import 'package:lang/app/lang_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<void> pumpHome(WidgetTester tester, {Locale? deviceLocale}) async {
    tester.view.physicalSize = const Size(1600, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    if (deviceLocale != null) {
      tester.platformDispatcher.localeTestValue = deviceLocale;
      addTearDown(tester.platformDispatcher.clearLocaleTestValue);
    }
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final controller = await loadAppLanguageController();
    await tester.pumpWidget(LangApp(controller: controller));
    await tester.pumpAndSettle();
  }

  Finder menuItem(String label) {
    return find.ancestor(
      of: find.text(label),
      matching: find.byType(PopupMenuItem<AppLanguage>),
    );
  }

  void expectOnlyChecked(String label) {
    for (final language in AppLanguage.values) {
      final check = find.descendant(
        of: menuItem(language.endonym),
        matching: find.byIcon(Icons.check),
      );
      expect(check, language.endonym == label ? findsOneWidget : findsNothing);
    }
  }

  Future<void> openMenu(WidgetTester tester) async {
    await tester.tap(find.byType(PopupMenuButton<AppLanguage>));
    await tester.pumpAndSettle();
  }

  void expectChrome({required String heading, required String practice}) {
    expect(find.text(heading), findsOneWidget);
    expect(find.text(practice), findsOneWidget);
    expect(find.text('5/20'), findsOneWidget);
    expect(find.byIcon(Icons.expand_less), findsOneWidget);
    expect(find.text('German A1 vocabulary'), findsWidgets);
  }

  testWidgets('a Vietnamese device still starts in English', (tester) async {
    await pumpHome(tester, deviceLocale: const Locale('vi'));

    expectChrome(heading: 'Your vocabulary statistics', practice: 'Practice');
  });

  testWidgets('a German device still starts in English', (tester) async {
    await pumpHome(tester, deviceLocale: const Locale('de'));

    expectChrome(heading: 'Your vocabulary statistics', practice: 'Practice');
  });

  testWidgets('the avatar menu switches chrome and keeps the sample', (
    tester,
  ) async {
    await pumpHome(tester, deviceLocale: const Locale('vi'));

    expectChrome(heading: 'Your vocabulary statistics', practice: 'Practice');

    await openMenu(tester);
    expect(find.byType(PopupMenuItem<AppLanguage>), findsNWidgets(3));
    expect(find.text('Tiếng Việt'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Deutsch'), findsOneWidget);
    expectOnlyChecked('English');

    await tester.tap(find.text('Tiếng Việt'));
    await tester.pumpAndSettle();

    expectChrome(heading: 'Thống kê từ vựng của bạn', practice: 'Luyện tập');
    await openMenu(tester);
    expectOnlyChecked('Tiếng Việt');

    await tester.tap(find.text('Deutsch'));
    await tester.pumpAndSettle();
    expectChrome(heading: 'Deine Vokabelstatistik', practice: 'Üben');

    await openMenu(tester);
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expectChrome(heading: 'Your vocabulary statistics', practice: 'Practice');
    await openMenu(tester);
    expectOnlyChecked('English');
  });
}
