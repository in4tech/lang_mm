import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lang/language/app_language.dart';
import 'package:lang/language/app_language_controller.dart';
import 'package:lang/library/vocabulary_library.dart';
import 'package:lang/app/lang_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<void> pumpHome(
    WidgetTester tester, {
    Locale? deviceLocale,
    VocabularyLibrary library = VocabularyLibrary.empty,
  }) async {
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
    await tester.pumpWidget(LangApp(controller: controller, library: library));
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

  void expectSuggestions({required String heading}) {
    expect(find.text(heading), findsOneWidget);
    expect(find.text('student'), findsWidgets);
    expect(find.text('love'), findsOneWidget);
    expect(find.text('Love vocabulary'), findsOneWidget);
    expect(find.text('0/0'), findsNothing);
    expect(find.text('German A1 vocabulary'), findsNothing);
    expect(find.text('das Auto fahren'), findsNothing);
  }

  testWidgets('a Vietnamese device still starts in English', (tester) async {
    await pumpHome(tester, deviceLocale: const Locale('vi'));

    expectSuggestions(heading: 'Hot search');
  });

  testWidgets('a German device still starts in English', (tester) async {
    await pumpHome(tester, deviceLocale: const Locale('de'));

    expectSuggestions(heading: 'Hot search');
  });

  testWidgets('the avatar menu switches chrome and keeps the templates', (
    tester,
  ) async {
    await pumpHome(tester, deviceLocale: const Locale('vi'));

    expectSuggestions(heading: 'Hot search');

    await openMenu(tester);
    expect(find.byType(PopupMenuItem<Object>), findsNWidgets(11));
    expect(find.text('Tiếng Việt'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Deutsch'), findsOneWidget);
    expectOnlyChecked('English');

    await tester.tap(find.text('Tiếng Việt'));
    await tester.pumpAndSettle();

    expectSuggestions(heading: 'Tìm kiếm nổi bật');
    await openMenu(tester);
    expectOnlyChecked('Tiếng Việt');

    await tester.tap(find.text('Deutsch'));
    await tester.pumpAndSettle();
    expectSuggestions(heading: 'Beliebte Suche');

    await openMenu(tester);
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expectSuggestions(heading: 'Hot search');
    await openMenu(tester);
    expectOnlyChecked('English');
  });

  testWidgets('a saved library stays put when the language changes', (
    tester,
  ) async {
    await pumpHome(
      tester,
      library: const VocabularyLibrary(
        folders: <VocabularyFolder>[
          VocabularyFolder(
            name: 'My vocab',
            sets: <String>['German A1 vocabulary'],
          ),
        ],
      ),
    );

    expect(find.text('My vocab'), findsOneWidget);
    expect(find.text('0/0'), findsOneWidget);
    expect(find.text('Hot search'), findsNothing);

    await openMenu(tester);
    await tester.tap(find.text('Tiếng Việt'));
    await tester.pumpAndSettle();

    expect(find.text('My vocab'), findsOneWidget);
    await tester.tap(find.byKey(const Key('folder-toggle-My vocab')));
    await tester.pump();
    expect(find.text('German A1 vocabulary'), findsOneWidget);
    expect(find.text('0/0'), findsOneWidget);
    expect(find.text('das Auto fahren'), findsNothing);
    expect(find.text('Hot search'), findsNothing);
    expect(find.text('Thống kê từ vựng của bạn'), findsOneWidget);
  });
}
