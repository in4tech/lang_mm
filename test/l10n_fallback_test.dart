import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lang/l10n/app_localizations.dart';

void main() {
  test('generated supported locales are English, Vietnamese, and German', () {
    expect(
      AppLocalizations.supportedLocales.map((locale) => locale.languageCode),
      containsAll(<String>['en', 'vi', 'de']),
    );
    expect(AppLocalizations.supportedLocales, hasLength(3));
  });

  testWidgets(
    'German localizations fall back to English for a missing string',
    (tester) async {
      late AppLocalizations localizations;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('de'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              localizations = AppLocalizations.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(
        localizations.missingTranslationProbe,
        'Missing translation probe',
      );
      expect(localizations.homeTitle, 'Flutter-Demo-Startseite');
    },
  );
}
