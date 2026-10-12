import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lang/theme/home_colors.dart';
import 'package:lang/features/home/widgets/home_header.dart';
import 'package:lang/features/home/sample/home_sample.dart';
import 'package:lang/features/home/widgets/today_panel.dart';
import 'package:lang/l10n/app_localizations.dart';
import 'package:lang/language/app_language_controller.dart';
import 'package:lang/app/lang_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<void> pumpHome(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1600, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues(<String, Object>{});
    final controller = await loadAppLanguageController();
    await tester.pumpWidget(LangApp(controller: controller));
    await tester.pumpAndSettle();
  }

  testWidgets('vocabulary home shows the pictured sample', (tester) async {
    await pumpHome(tester);
    final localizations = lookupAppLocalizations(const Locale('en'));

    expect(find.text(localizations.searchHint), findsOneWidget);
    await tester.tap(find.byType(TextField));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'Auto');
    expect(find.text('Auto'), findsOneWidget);
    expect(
      tester.getRect(find.byType(HomeHeader)).width,
      moreOrLessEquals(1600),
    );
    expect(find.text(localizations.newVocab), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);

    final selected = tester.widget<Material>(
      find.descendant(
        of: find.byKey(const Key('nav-home')),
        matching: find.byType(Material),
      ),
    );
    expect(selected.color, HomeColors.selectedFill);
    expect(find.text('German A1 vocabulary'), findsWidgets);
    expect(find.text('A2 vocabulary'), findsWidgets);
    expect(find.byIcon(Icons.expand_less), findsOneWidget);
    expect(find.byIcon(Icons.expand_more), findsOneWidget);

    expect(find.text('5/20'), findsOneWidget);
    expect(find.text('25%'), findsWidgets);
    final fills = find.byType(FractionallySizedBox);
    expect(fills, findsNWidgets(5));
    for (final element in fills.evaluate()) {
      final box = element.renderObject! as RenderBox;
      expect(box.size.height, greaterThan(0));
      expect(box.size.width, greaterThan(0));
    }
    expect(find.text('3'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('Lv.6 - Mastered'), findsOneWidget);
    expect(find.text('0%'), findsWidgets);
    expect(find.text('75%'), findsOneWidget);
    expect(find.text('Words learned'), findsOneWidget);
    expect(find.text('Words not yet learned'), findsOneWidget);

    final track = tester.getRect(find.byKey(const Key('all-switch')));
    final knobOn = tester.getRect(find.byKey(const Key('all-switch-knob')));
    expect(knobOn.center.dx, greaterThan(track.center.dx));
    await tester.tap(find.byKey(const Key('all-switch')));
    await tester.pump();
    final knobOff = tester.getRect(find.byKey(const Key('all-switch-knob')));
    expect(knobOff.center.dx, lessThan(track.center.dx));
    await tester.tap(find.byKey(const Key('all-switch')));
    await tester.pump();
    expect(
      tester.getRect(find.byKey(const Key('all-switch-knob'))).center.dx,
      greaterThan(track.center.dx),
    );

    expect(find.text('das Auto fahren'), findsNWidgets(4));
    expect(find.text('das, -s'), findsNWidgets(4));
    expect(find.text('die Frage verstehen'), findsNWidgets(4));
    expect(find.text('die, -n'), findsNWidgets(4));
    expect(find.text('Practice'), findsOneWidget);
    expect(find.byKey(const Key('today-scrollbar')), findsNothing);
    expect(
      tester.getSize(find.widgetWithText(FilledButton, 'Practice')).height,
      greaterThanOrEqualTo(48),
    );
    expect(
      tester.getSize(find.widgetWithText(TextButton, 'Continue').first).height,
      greaterThanOrEqualTo(40),
    );

    expect(find.text('The process is 25% complete.'), findsOneWidget);
    expect(find.text('The process is 50% complete.'), findsOneWidget);
    expect(find.text('The process is 93% complete.'), findsWidgets);
    expect(find.text('Continue'), findsWidgets);

    final clip = tester.getRect(find.byKey(const Key('recent-clip')));
    final fourth = tester.getRect(find.text('German B2 vocabulary'));
    expect(fourth.left, lessThan(clip.right));
    expect(fourth.right, greaterThan(clip.right));

    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();
    final shown = tester.getRect(find.text('German B2 vocabulary'));
    final window = tester.getRect(find.byKey(const Key('recent-clip')));
    expect(shown.left, greaterThanOrEqualTo(window.left));
    expect(shown.right, lessThanOrEqualTo(window.right));
    expect(find.byIcon(Icons.chevron_right), findsNothing);
    expect(find.byIcon(Icons.chevron_left), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    expect(find.byIcon(Icons.chevron_left), findsNothing);
    expect(
      tester.getRect(find.text('German B2 vocabulary')).right,
      greaterThan(window.right),
    );

    expect(
      find.text('You have pushed the button this many times:'),
      findsNothing,
    );
    expect(find.byIcon(Icons.add), findsNothing);

    await tester.tap(find.text('Practice'));
    await tester.pump();
    expect(find.text('5/20'), findsOneWidget);
    expect(find.text('25%'), findsWidgets);
  });

  testWidgets('today scrollbar appears only when the list overflows', (
    tester,
  ) async {
    final current = HomeSample.current;
    final overflowing = HomeSample(
      statisticsSetName: current.statisticsSetName,
      learnedCount: current.learnedCount,
      totalCount: current.totalCount,
      percent: current.percent,
      bars: current.bars,
      levels: current.levels,
      today: List<TodayRow>.filled(12, current.today.first),
      recent: current.recent,
      homepageSelected: current.homepageSelected,
      folders: current.folders,
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Center(child: TodayPanel(sample: overflowing)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('today-scrollbar')), findsOneWidget);
    expect(find.text('das Auto fahren'), findsWidgets);
  });
}
