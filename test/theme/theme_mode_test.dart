import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lang/app/lang_app.dart';
import 'package:lang/language/app_language_controller.dart';
import 'package:lang/theme/app_theme_controller.dart';
import 'package:lang/theme/app_theme_mode.dart';
import 'package:lang/theme/home_palette.dart';
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
    final language = await loadAppLanguageController();
    final theme = await loadAppThemeController();
    await tester.pumpWidget(
      LangApp(controller: language, themeController: theme),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openAvatarMenu(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('avatar-menu')));
    await tester.pumpAndSettle();
  }

  testWidgets('the home starts in dark mode', (tester) async {
    await launch(tester, <String, Object>{});

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      HomePalette.dark.page,
    );

    final avatar = tester.getRect(find.byKey(const Key('avatar-menu')));
    await openAvatarMenu(tester);
    expect(
      tester.getRect(find.text('Light mode')).top,
      greaterThan(avatar.bottom),
    );
    expect(find.byIcon(Icons.light_mode_outlined), findsOneWidget);
    expect(find.text('Light'), findsNothing);
    expect(find.text('Dark'), findsNothing);
  });

  testWidgets('light mode is restored on the next start', (tester) async {
    await launch(tester, <String, Object>{});

    await openAvatarMenu(tester);
    await tester.tap(find.text('Light mode'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.light,
    );
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      HomePalette.light.page,
    );

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString(AppThemeMode.storageKey), 'light');

    final language = await loadAppLanguageController();
    final theme = await loadAppThemeController();
    await tester.pumpWidget(
      LangApp(controller: language, themeController: theme),
    );
    await tester.pumpAndSettle();

    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      HomePalette.light.page,
    );

    await openAvatarMenu(tester);
    expect(find.text('Dark mode'), findsOneWidget);
    expect(find.byIcon(Icons.dark_mode_outlined), findsOneWidget);
    expect(find.text('Light mode'), findsNothing);
    await tester.tap(find.text('Dark mode'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      HomePalette.dark.page,
    );
    expect(preferences.getString(AppThemeMode.storageKey), 'dark');
  });

  testWidgets('an unsupported saved code opens in dark mode', (tester) async {
    await launch(tester, <String, Object>{AppThemeMode.storageKey: 'sepia'});

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
  });
}
