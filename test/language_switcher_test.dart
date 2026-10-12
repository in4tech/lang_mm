import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lang/localization/app_language.dart';
import 'package:lang/localization/app_language_controller.dart';
import 'package:lang/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<void> pumpApp(
    WidgetTester tester, {
    Locale? deviceLocale,
    Map<String, Object> preferences = const <String, Object>{},
  }) async {
    if (deviceLocale != null) {
      tester.platformDispatcher.localeTestValue = deviceLocale;
      addTearDown(tester.platformDispatcher.clearLocaleTestValue);
    }
    SharedPreferences.setMockInitialValues(preferences);
    final controller = await loadAppLanguageController();
    await tester.pumpWidget(LangApp(controller: controller));
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

  Future<void> choose(WidgetTester tester, String label) async {
    await openMenu(tester);
    await tester.tap(find.text(label).last);
    await tester.pumpAndSettle();
  }

  void expectHomeCopy({
    required String title,
    required String message,
    required String action,
  }) {
    expect(find.text(title), findsOneWidget);
    expect(find.text(message), findsOneWidget);
    expect(find.byTooltip(action), findsOneWidget);
  }

  testWidgets('a Vietnamese device still starts in English', (tester) async {
    await pumpApp(tester, deviceLocale: const Locale('vi'));

    expectHomeCopy(
      title: 'Flutter Demo Home Page',
      message: 'You have pushed the button this many times:',
      action: 'Increment',
    );
    expect(
      MaterialLocalizations.of(tester.element(find.byType(MyHomePage)))
          .backButtonTooltip,
      'Back',
    );
  });

  testWidgets('a German device still starts in English', (tester) async {
    await pumpApp(tester, deviceLocale: const Locale('de'));

    expectHomeCopy(
      title: 'Flutter Demo Home Page',
      message: 'You have pushed the button this many times:',
      action: 'Increment',
    );
  });

  testWidgets(
    'the language menu switches copy in place and keeps the counter',
    (tester) async {
      await pumpApp(tester, deviceLocale: const Locale('vi'));

      expectHomeCopy(
        title: 'Flutter Demo Home Page',
        message: 'You have pushed the button this many times:',
        action: 'Increment',
      );

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(find.text('1'), findsOneWidget);

      await openMenu(tester);
      expect(find.byType(PopupMenuItem<AppLanguage>), findsNWidgets(3));
      expect(find.text('Tiếng Việt'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Deutsch'), findsOneWidget);
      expectOnlyChecked('English');

      await tester.tap(find.text('Tiếng Việt'));
      await tester.pumpAndSettle();

      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expectHomeCopy(
        title: 'Trang chủ bản demo Flutter',
        message: 'Bạn đã nhấn nút này bấy nhiêu lần:',
        action: 'Tăng',
      );
      expect(
        MaterialLocalizations.of(tester.element(find.byType(MyHomePage)))
            .backButtonTooltip,
        'Quay lại',
      );

      await openMenu(tester);
      expectOnlyChecked('Tiếng Việt');
      await tester.tap(find.text('Deutsch'));
      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget);
      expectHomeCopy(
        title: 'Flutter-Demo-Startseite',
        message: 'Sie haben die Schaltfläche so oft gedrückt:',
        action: 'Erhöhen',
      );
      expect(
        MaterialLocalizations.of(tester.element(find.byType(MyHomePage)))
            .backButtonTooltip,
        'Zurück',
      );

      await choose(tester, 'English');

      expect(find.text('1'), findsOneWidget);
      expectHomeCopy(
        title: 'Flutter Demo Home Page',
        message: 'You have pushed the button this many times:',
        action: 'Increment',
      );
      await openMenu(tester);
      expectOnlyChecked('English');
    },
  );
}
