import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lang/features/home/vocabulary_home.dart';
import 'package:lang/language/app_language.dart';
import 'package:lang/language/app_language_controller.dart';
import 'package:lang/app/lang_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<void> pumpApp(
    WidgetTester tester, {
    Locale? deviceLocale,
    Map<String, Object> preferences = const <String, Object>{},
  }) async {
    tester.view.physicalSize = const Size(1600, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    if (deviceLocale != null) {
      tester.platformDispatcher.localeTestValue = deviceLocale;
      addTearDown(tester.platformDispatcher.clearLocaleTestValue);
    }
    SharedPreferences.setMockInitialValues(preferences);
    final controller = await loadAppLanguageController();
    await tester.pumpWidget(LangApp(controller: controller));
    await tester.pumpAndSettle();
  }

  Finder menuItem(String label) {
    return find.ancestor(
      of: find.text(label),
      matching: find.byType(PopupMenuItem<Object>),
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
    await tester.tap(find.byKey(const Key('avatar-menu')));
    await tester.pumpAndSettle();
  }

  Future<void> choose(WidgetTester tester, String label) async {
    await openMenu(tester);
    await tester.tap(find.text(label).last);
    await tester.pumpAndSettle();
  }

  void expectHomeCopy({required String heading}) {
    expect(find.text(heading), findsOneWidget);
    expect(find.byKey(const Key('suggestion-speak')), findsOneWidget);
    expect(find.text('Save'), findsNothing);
    expect(find.text('diagnosis'), findsWidgets);
    expect(find.text('5/20'), findsNothing);
  }

  testWidgets('a Vietnamese device still starts in English', (tester) async {
    await pumpApp(tester, deviceLocale: const Locale('vi'));

    expectHomeCopy(heading: 'Hot search');
    expect(
      MaterialLocalizations.of(tester.element(find.byType(VocabularyHome)))
          .backButtonTooltip,
      'Back',
    );
  });

  testWidgets('a German device still starts in English', (tester) async {
    await pumpApp(tester, deviceLocale: const Locale('de'));

    expectHomeCopy(heading: 'Hot search');
  });

  testWidgets('the language menu switches copy in place and keeps the sample', (
    tester,
  ) async {
    await pumpApp(tester, deviceLocale: const Locale('vi'));

    expectHomeCopy(heading: 'Hot search');

    await openMenu(tester);
    expect(find.byType(PopupMenuItem<Object>), findsNWidgets(11));
    expect(find.text('in4techit'), findsOneWidget);
    expect(find.text('in4tech.it@gmail.com'), findsOneWidget);
    expect(find.text('Achievements'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Light mode'), findsOneWidget);
    expect(find.text('Log out'), findsOneWidget);
    expect(find.text('Privacy policy'), findsOneWidget);
    expect(find.text('Help and feedback'), findsOneWidget);
    expect(find.text('Upgrade'), findsOneWidget);
    final avatar = tester.getRect(find.byKey(const Key('avatar-menu')));
    expect(tester.getRect(find.text('English')).top, greaterThan(avatar.bottom));
    expect(find.text('Tiếng Việt'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Deutsch'), findsOneWidget);
    expectOnlyChecked('English');

    await tester.tap(find.text('Tiếng Việt'));
    await tester.pumpAndSettle();

    expect(find.byType(VocabularyHome), findsOneWidget);
    expectHomeCopy(heading: 'Tìm kiếm nổi bật');
    expect(
      MaterialLocalizations.of(tester.element(find.byType(VocabularyHome)))
          .backButtonTooltip,
      'Quay lại',
    );

    await openMenu(tester);
    expectOnlyChecked('Tiếng Việt');
    await tester.tap(find.text('Deutsch'));
    await tester.pumpAndSettle();

    expectHomeCopy(heading: 'Beliebte Suche');
    expect(
      MaterialLocalizations.of(tester.element(find.byType(VocabularyHome)))
          .backButtonTooltip,
      'Zurück',
    );

    await choose(tester, 'English');

    expectHomeCopy(heading: 'Hot search');
    await openMenu(tester);
    expectOnlyChecked('English');
    await tester.tap(find.text('Upgrade'));
    await tester.pumpAndSettle();
    expectHomeCopy(heading: 'Hot search');
  });
}
