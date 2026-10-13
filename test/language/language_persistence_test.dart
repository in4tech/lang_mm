import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lang/language/app_language.dart';
import 'package:lang/language/app_language_controller.dart';
import 'package:lang/app/lang_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<void> launch(
    WidgetTester tester,
    Map<String, Object> preferences,
  ) async {
    tester.view.physicalSize = const Size(1600, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues(preferences);
    final controller = await loadAppLanguageController();
    await tester.pumpWidget(LangApp(controller: controller));
    await tester.pumpAndSettle();
  }

  testWidgets('saved de opens in German', (tester) async {
    await launch(tester, <String, Object>{AppLanguage.storageKey: 'de'});

    expect(find.text('Beliebte Suche'), findsOneWidget);
    expect(find.text('Speichern'), findsOneWidget);
  });

  testWidgets('saved vi opens in Vietnamese', (tester) async {
    await launch(tester, <String, Object>{AppLanguage.storageKey: 'vi'});

    expect(find.text('Tìm kiếm nổi bật'), findsOneWidget);
    expect(find.text('Lưu từ'), findsOneWidget);
  });

  testWidgets('an unsupported saved code opens in English', (tester) async {
    await launch(tester, <String, Object>{AppLanguage.storageKey: 'fr'});

    expect(find.text('Hot search'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets('selecting German is restored on the next start', (tester) async {
    await launch(tester, <String, Object>{});

    await tester.tap(find.byKey(const Key('avatar-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Deutsch'));
    await tester.pumpAndSettle();

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString(AppLanguage.storageKey), 'de');

    final restarted = await loadAppLanguageController();
    await tester.pumpWidget(LangApp(controller: restarted));
    await tester.pumpAndSettle();

    expect(find.text('Beliebte Suche'), findsOneWidget);
    expect(find.text('Speichern'), findsOneWidget);
  });
}
