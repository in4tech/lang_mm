import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lang/l10n/app_localizations.dart';

void main() {
  Future<AppLocalizations> load(WidgetTester tester, Locale locale) async {
    late AppLocalizations localizations;
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
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
    return localizations;
  }

  testWidgets('chrome strings match the design in each language', (
    tester,
  ) async {
    final english = await load(tester, const Locale('en'));
    expect(english.statisticsHeading, 'Your vocabulary statistics');
    expect(english.practice, 'Practice');
    expect(english.progressComplete(25), 'The process is 25% complete.');

    final vietnamese = await load(tester, const Locale('vi'));
    expect(vietnamese.statisticsHeading, 'Thống kê từ vựng của bạn');
    expect(vietnamese.practice, 'Luyện tập');

    final german = await load(tester, const Locale('de'));
    expect(german.statisticsHeading, 'Deine Vokabelstatistik');
    expect(german.practice, 'Üben');
    expect(german.homeTitle, 'Flutter-Demo-Startseite');
    expect(german.missingTranslationProbe, 'Missing translation probe');
  });
}
