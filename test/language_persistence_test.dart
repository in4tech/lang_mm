import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lang/localization/app_language.dart';
import 'package:lang/localization/app_language_controller.dart';
import 'package:lang/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<void> launch(
    WidgetTester tester,
    Map<String, Object> preferences,
  ) async {
    SharedPreferences.setMockInitialValues(preferences);
    final controller = await loadAppLanguageController();
    await tester.pumpWidget(LangApp(controller: controller));
  }

  testWidgets('saved de opens in German', (tester) async {
    await launch(tester, <String, Object>{AppLanguage.storageKey: 'de'});

    expect(find.text('Flutter-Demo-Startseite'), findsOneWidget);
    expect(
      find.text('Sie haben die Schaltfläche so oft gedrückt:'),
      findsOneWidget,
    );
  });

  testWidgets('saved vi opens in Vietnamese', (tester) async {
    await launch(tester, <String, Object>{AppLanguage.storageKey: 'vi'});

    expect(find.text('Trang chủ bản demo Flutter'), findsOneWidget);
    expect(find.text('Bạn đã nhấn nút này bấy nhiêu lần:'), findsOneWidget);
  });

  testWidgets('an unsupported saved code opens in English', (tester) async {
    await launch(tester, <String, Object>{AppLanguage.storageKey: 'fr'});

    expect(find.text('Flutter Demo Home Page'), findsOneWidget);
    expect(
      find.text('You have pushed the button this many times:'),
      findsOneWidget,
    );
  });

  testWidgets('selecting German is restored on the next start', (tester) async {
    await launch(tester, <String, Object>{});

    await tester.tap(find.byType(PopupMenuButton<AppLanguage>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Deutsch'));
    await tester.pumpAndSettle();

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString(AppLanguage.storageKey), 'de');

    final restarted = await loadAppLanguageController();
    await tester.pumpWidget(LangApp(controller: restarted));

    expect(find.text('Flutter-Demo-Startseite'), findsOneWidget);
    expect(
      find.text('Sie haben die Schaltfläche so oft gedrückt:'),
      findsOneWidget,
    );
  });
}
