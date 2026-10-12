import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lang/theme/home_colors.dart';
import 'package:lang/features/home/widgets/home_header.dart';
import 'package:lang/features/home/widgets/home_sidebar.dart';
import 'package:lang/features/home/sample/home_sample.dart';
import 'package:lang/features/home/widgets/today_panel.dart';
import 'package:lang/features/home/suggestions/suggestion_templates.dart';
import 'package:lang/features/home/vocabulary_home.dart';
import 'package:lang/library/vocabulary_library.dart';
import 'package:lang/library/vocabulary_library_store.dart';
import 'package:lang/l10n/app_localizations.dart';
import 'package:lang/language/app_language_controller.dart';
import 'package:lang/language/app_language_scope.dart';
import 'package:lang/language/app_language_store.dart';
import 'package:lang/app/lang_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<void> prepareView(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1600, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> pumpFixture(WidgetTester tester) async {
    await prepareView(tester);
    final controller = AppLanguageController(
      const UnavailableAppLanguageStore(),
    );
    await tester.pumpWidget(
      AppLanguageScope(
        controller: controller,
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: VocabularyHome(sample: HomeSample.current),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pumpApp(
    WidgetTester tester, {
    VocabularyLibrary library = VocabularyLibrary.empty,
  }) async {
    await prepareView(tester);
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final controller = await loadAppLanguageController();
    await tester.pumpWidget(LangApp(controller: controller, library: library));
    await tester.pumpAndSettle();
  }

  testWidgets('vocabulary home shows the pictured sample', (tester) async {
    await pumpFixture(tester);
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
    expect(
      find.image(const AssetImage('assets/images/lang_logo.png')),
      findsOneWidget,
    );
    expect(
      find.image(const AssetImage('assets/images/avatar.jpg')),
      findsOneWidget,
    );

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

  testWidgets('a fresh launch shows suggestion templates', (tester) async {
    await pumpApp(tester);

    expect(find.text('Hot search'), findsOneWidget);
    expect(find.text('Suggested sets'), findsOneWidget);
    expect(find.text('Suggested practice'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
    expect(find.text('80 saves'), findsOneWidget);
    expect(find.text('UK /ˈstjuːdnt/'), findsOneWidget);
    expect(find.text('US /ˈstuːdnt/'), findsOneWidget);
    expect(
      find.text('a person who is studying at a university or college'),
      findsOneWidget,
    );
    expect(find.text('student'), findsNWidgets(2));
    expect(find.text('Your vocabulary statistics'), findsNothing);
    expect(find.text("Today's vocabulary"), findsNothing);
    expect(find.text('Recent'), findsNothing);
    expect(find.text('0/0'), findsNothing);
    expect(find.text('Practice'), findsNothing);
    expect(find.text('5/20'), findsNothing);
    expect(find.text('das Auto fahren'), findsNothing);
    expect(find.text('German A1 vocabulary'), findsNothing);
    expect(find.byIcon(Icons.expand_less), findsNothing);

    var previous = tester.getTopLeft(find.byKey(const Key('hot-chip-love')));
    for (final chip in SuggestionTemplates.chips.skip(1)) {
      final offset = tester.getTopLeft(find.byKey(Key('hot-chip-$chip')));
      final below = offset.dy > previous.dy + 1;
      final beside =
          (offset.dy - previous.dy).abs() <= 1 && offset.dx > previous.dx;
      expect(below || beside, isTrue, reason: chip);
      previous = offset;
    }
    for (var index = 0; index < SuggestionTemplates.sets.length; index++) {
      expect(find.text(SuggestionTemplates.sets[index]), findsOneWidget);
      if (index > 0) {
        expect(
          tester.getTopLeft(find.byKey(Key('suggestion-set-$index'))).dy,
          greaterThan(
            tester
                .getTopLeft(find.byKey(Key('suggestion-set-${index - 1}')))
                .dy,
          ),
        );
      }
    }
    for (var index = 0; index < SuggestionTemplates.practice.length; index++) {
      expect(find.text(SuggestionTemplates.practice[index]), findsOneWidget);
      if (index > 0) {
        expect(
          tester.getTopLeft(find.byKey(Key('suggestion-practice-$index'))).dy,
          greaterThan(
            tester
                .getTopLeft(find.byKey(Key('suggestion-practice-${index - 1}')))
                .dy,
          ),
        );
      }
    }

    await tester.tap(find.text('New vocab'));
    await tester.pump();
    await tester.tap(find.byKey(const Key('suggestion-save')));
    await tester.pump();

    expect(find.text('student'), findsNWidgets(2));
    expect(find.text('German A1 vocabulary'), findsNothing);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString(VocabularyLibraryStore.storageKey), isNull);
  });

  testWidgets('a stored library shows names and empty progress', (
    tester,
  ) async {
    await pumpApp(
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
    expect(find.text('German A1 vocabulary'), findsOneWidget);
    expect(find.text('0/0'), findsOneWidget);
    expect(find.text('Lv.6 - Mastered'), findsOneWidget);
    expect(find.text('Lv.5 - Good'), findsOneWidget);
    expect(find.text('Lv.4 - Familiar'), findsOneWidget);
    expect(find.text('Lv.3 - Learning'), findsOneWidget);
    expect(find.text('Lv.2 - Hard'), findsOneWidget);
    expect(find.text('Lv.1 - Forgot'), findsOneWidget);
    expect(find.text('0%'), findsNWidgets(7));
    expect(find.text('Practice'), findsOneWidget);
    expect(find.text('Continue'), findsNothing);
    expect(find.text('Hot search'), findsNothing);
    expect(find.text('das Auto fahren'), findsNothing);
    expect(find.text('5/20'), findsNothing);
    expect(find.text('3'), findsNothing);
    expect(find.text('2'), findsNothing);
  });

  testWidgets('the debug button switches the sample and the empty home', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(find.byKey(const Key('debug-home-toggle')), findsOneWidget);
    expect(find.text('Sample'), findsOneWidget);
    expect(find.text('Hot search'), findsOneWidget);

    await tester.tap(find.byKey(const Key('debug-home-toggle')));
    await tester.pumpAndSettle();

    expect(find.text('Empty'), findsOneWidget);
    expect(find.text('5/20'), findsOneWidget);
    expect(find.text('das Auto fahren'), findsWidgets);
    expect(find.text('Hot search'), findsNothing);

    await tester.tap(find.byKey(const Key('debug-home-toggle')));
    await tester.pumpAndSettle();

    expect(find.text('Sample'), findsOneWidget);
    expect(find.text('Hot search'), findsOneWidget);
    expect(find.text('5/20'), findsNothing);
    expect(find.text('das Auto fahren'), findsNothing);
  });

  testWidgets('the drawer collapses the sidebar to navigation icons', (
    tester,
  ) async {
    await pumpApp(
      tester,
      library: const VocabularyLibrary(
        folders: [
          VocabularyFolder(name: 'My vocab', sets: ['German A1 vocabulary']),
        ],
      ),
    );

    expect(tester.getSize(find.byType(HomeSidebar)).width, HomeSidebar.width);
    expect(
      tester.getSize(find.byKey(const Key('nav-home-label'))).width,
      greaterThan(0),
    );
    expect(
      tester.getSize(find.byKey(const Key('sidebar-extra'))).height,
      greaterThan(0),
    );
    expect(
      tester.getSize(find.byKey(const Key('header-logo'))).width,
      greaterThan(0),
    );

    await tester.tap(find.byKey(const Key('drawer-menu')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 140));

    final midWidth = tester.getSize(find.byType(HomeSidebar)).width;
    expect(midWidth, greaterThan(HomeSidebar.collapsedWidth));
    expect(midWidth, lessThan(HomeSidebar.width));

    await tester.pumpAndSettle();

    expect(
      tester.getSize(find.byType(HomeSidebar)).width,
      HomeSidebar.collapsedWidth,
    );
    expect(tester.getSize(find.byKey(const Key('nav-home-label'))).width, 0);
    expect(tester.getSize(find.byKey(const Key('sidebar-extra'))).height, 0);
    final sidebar = tester.getRect(find.byType(HomeSidebar));
    expect(
      tester.getCenter(find.byIcon(Icons.home_outlined)).dx,
      moreOrLessEquals(sidebar.center.dx, epsilon: 1),
    );
    final selectedFill = find.descendant(
      of: find.byKey(const Key('nav-home')),
      matching: find.byType(Material),
    );
    expect(
      tester.widget<Material>(selectedFill).color,
      HomeColors.selectedFill,
    );
    expect(
      tester.getSize(selectedFill),
      const Size(HomeSidebar.collapsedSlot, HomeSidebar.collapsedSlot),
    );
    expect(
      tester.getCenter(selectedFill).dx,
      moreOrLessEquals(sidebar.center.dx, epsilon: 1),
    );
    final chip = tester.getSize(find.byKey(const Key('folder-My vocab')));
    expect(chip.width, HomeSidebar.collapsedSlot);
    expect(chip.height, HomeSidebar.collapsedSlot);
    expect(
      tester.getCenter(find.byKey(const Key('folder-My vocab'))).dx,
      moreOrLessEquals(sidebar.center.dx, epsilon: 1),
    );
    final search = find.descendant(
      of: find.byType(HomeSidebar),
      matching: find.byIcon(Icons.search),
    );
    final folderDivider = find.byKey(const Key('collapsed-folder-divider'));
    expect(search, findsOneWidget);
    expect(folderDivider, findsOneWidget);
    expect(
      tester.getCenter(search).dy,
      lessThan(tester.getCenter(folderDivider).dy),
    );
    expect(
      tester.getCenter(folderDivider).dy,
      lessThan(tester.getCenter(find.byKey(const Key('folder-My vocab'))).dy),
    );
    expect(find.text('My vocab'), findsNothing);
    expect(find.text('German A1 vocabulary'), findsNothing);
    expect(
      tester.getSize(find.byKey(const Key('header-logo'))).width,
      greaterThan(0),
    );
    expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    expect(find.byIcon(Icons.folder_open_outlined), findsOneWidget);
    expect(find.byIcon(Icons.notifications_none), findsOneWidget);
    expect(find.byIcon(Icons.menu), findsOneWidget);
    expect(find.byIcon(Icons.menu_open), findsNothing);

    await tester.tap(find.byKey(const Key('drawer-menu')));
    await tester.pumpAndSettle();

    expect(tester.getSize(find.byType(HomeSidebar)).width, HomeSidebar.width);
    expect(
      tester.getSize(find.byKey(const Key('nav-home-label'))).width,
      greaterThan(0),
    );
    expect(find.text('Homepage'), findsOneWidget);
    expect(find.byIcon(Icons.menu), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const Key('header-logo'))).width,
      greaterThan(0),
    );
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
