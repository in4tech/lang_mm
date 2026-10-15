import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lang/theme/home_colors.dart';
import 'package:lang/theme/home_palette.dart';
import 'package:lang/features/home/widgets/home_header.dart';
import 'package:lang/features/home/widgets/home_sidebar.dart';
import 'package:lang/features/home/sample/home_sample.dart';
import 'package:lang/features/home/widgets/statistics_panel.dart';
import 'package:lang/features/home/widgets/today_panel.dart';
import 'package:lang/features/home/suggestions/suggestion_templates.dart';
import 'package:lang/features/home/vocabulary_home.dart';
import 'package:lang/library/study_progress.dart';
import 'package:lang/library/vocabulary_library.dart';
import 'package:lang/library/vocabulary_library_store.dart';
import 'package:lang/library/vocabulary_set.dart';
import 'package:lang/l10n/app_localizations.dart';
import 'package:lang/language/app_language_controller.dart';
import 'package:lang/language/app_language_scope.dart';
import 'package:lang/language/app_language_store.dart';
import 'package:lang/app/lang_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<void> prepareView(
    WidgetTester tester, {
    Size size = const Size(1600, 1200),
  }) async {
    tester.view.physicalSize = size;
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

  Future<void> openEditor(WidgetTester tester) async {
    await tester.tap(find.text('New vocab'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('new-vocab-term')));
    await tester.pumpAndSettle();
  }

  Future<void> pumpApp(
    WidgetTester tester, {
    VocabularyLibrary library = VocabularyLibrary.empty,
    VocabularySetStore? setStore,
    StudyProgressStore? studyProgress,
    Size size = const Size(1600, 1200),
  }) async {
    await prepareView(tester, size: size);
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final controller = await loadAppLanguageController();
    await tester.pumpWidget(
      LangApp(
        key: UniqueKey(),
        controller: controller,
        library: library,
        setStore: setStore,
        studyProgress: studyProgress,
      ),
    );
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
      moreOrLessEquals(tester.view.physicalSize.width),
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
    expect(find.byIcon(Icons.expand_less), findsNothing);
    expect(find.byIcon(Icons.expand_more), findsNWidgets(2));

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

    await openEditor(tester);

    expect(find.text('Add new word'), findsOneWidget);
    expect(find.text('Enter term'), findsOneWidget);
    expect(find.text('Find your vocab...'), findsOneWidget);
    expect(find.text('New vocab'), findsOneWidget);
    expect(find.text('Homepage'), findsOneWidget);
    expect(find.byType(HomeHeader), findsOneWidget);
    expect(find.byType(HomeSidebar), findsOneWidget);
    expect(find.text('Hot search'), findsNothing);
    expect(find.text('student'), findsNothing);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text('Required'), findsNWidgets(2));
    expect(find.text('Add new word'), findsOneWidget);

    await tester.tap(find.byKey(const Key('word-editor-back')));
    await tester.pumpAndSettle();

    expect(find.text('Homepage'), findsOneWidget);
    expect(find.text('Hot search'), findsOneWidget);
    expect(find.text('student'), findsNWidgets(2));
    var preferences = await SharedPreferences.getInstance();
    expect(preferences.getString(VocabularyLibraryStore.storageKey), isNull);

    await tester.tap(find.byKey(const Key('suggestion-save')));
    await tester.pump();

    expect(find.text('student'), findsNWidgets(2));
    preferences = await SharedPreferences.getInstance();
    expect(preferences.getString(VocabularyLibraryStore.storageKey), isNull);

    await openEditor(tester);
    await tester.enterText(find.byKey(const Key('word-term')), 'Kind');
    await tester.tap(find.byKey(const Key('word-editor-back')));
    await tester.pumpAndSettle();

    expect(find.text('student'), findsNWidgets(2));
    expect(find.text('Hot search'), findsOneWidget);
    preferences = await SharedPreferences.getInstance();
    expect(preferences.getString(VocabularyLibraryStore.storageKey), isNull);
  });

  testWidgets('new vocab opens a menu for a term or a folder', (tester) async {
    final store = _RecordingStore();
    await pumpApp(tester, setStore: store);

    await tester.tap(find.text('New vocab'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('new-vocab-term')), findsOneWidget);
    expect(find.byKey(const Key('new-vocab-folder')), findsOneWidget);
    expect(find.text('Add new word'), findsNothing);

    await tester.tap(find.byKey(const Key('new-vocab-folder')));
    await tester.pumpAndSettle();

    expect(find.text('Enter folder name'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('new-folder-name')), 'Travel');
    await tester.tap(find.byKey(const Key('new-folder-create')));
    await tester.pumpAndSettle();

    expect(find.text('Travel'), findsOneWidget);
    expect(find.text('Hot search'), findsNothing);
    expect(find.text('Add new word'), findsNothing);
    final raw = (await SharedPreferences.getInstance()).getString(
      VocabularyLibraryStore.storageKey,
    );
    expect(raw, contains('Travel'));
    expect(raw, contains('folder-1'));
    expect(raw, isNot(contains('editorFolder')));
    expect(store.createdFolders, <String>['Travel']);
    expect(store.editorFolders, <bool>[false]);
  });

  testWidgets('the set of words plus creates a sidebar folder', (
    tester,
  ) async {
    final store = _RecordingStore();
    await pumpApp(tester, setStore: store);

    await tester.tap(find.byKey(const Key('sidebar-add-folder')));
    await tester.pumpAndSettle();

    expect(find.text('Enter folder name'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('new-folder-name')), 'Travel');
    await tester.tap(find.byKey(const Key('new-folder-create')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('folder-Travel')), findsOneWidget);
    expect(find.text('Add new word'), findsNothing);
    expect(store.createdFolders, <String>['Travel']);
    expect(store.editorFolders, <bool>[false]);
  });

  testWidgets('done stores the set name in the editor folder', (tester) async {
    final store = _RecordingStore();
    await pumpApp(tester, setStore: store);

    await openEditor(tester);
    await tester.enterText(
      find.byKey(const Key('word-editor-title')),
      'German A1',
    );
    await tester.enterText(
      find.byKey(const Key('word-editor-description')),
      'basics',
    );
    await tester.enterText(find.byKey(const Key('word-term')), 'Kind');
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text('Your vocabulary set'), findsNWidgets(2));
    expect(find.text('German A1'), findsNothing);
    await tester.tap(find.byKey(const Key('folder-Your vocabulary set')));
    await tester.pump();
    expect(find.text('German A1'), findsOneWidget);
    expect(find.text('0/0'), findsOneWidget);
    expect(find.text('Hot search'), findsNothing);
    expect(find.text('student'), findsNothing);
    final raw = (await SharedPreferences.getInstance()).getString(
      VocabularyLibraryStore.storageKey,
    );
    expect(raw, contains('"editorFolder":"Your vocabulary set"'));
    expect(raw, contains('German A1'));
    expect(raw, contains('Kind'));
    expect(raw, contains('folder-1'));
    expect(store.saved.single.folderId, 'folder-1');
    expect(store.createdFolders, <String>['Your vocabulary set']);
    expect(store.editorFolders, <bool>[true]);
  });

  testWidgets('a failed store stays in the editor', (tester) async {
    final store = _RecordingStore()..error = Exception('offline');
    await pumpApp(tester, setStore: store);

    await openEditor(tester);
    await tester.enterText(
      find.byKey(const Key('word-editor-title')),
      'German',
    );
    await tester.enterText(
      find.byKey(const Key('word-editor-description')),
      'basics',
    );
    await tester.enterText(find.byKey(const Key('word-term')), 'Kind');
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text('Add new word'), findsOneWidget);
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('word-term')))
          .controller!
          .text,
      'Kind',
    );
    expect(
      (await SharedPreferences.getInstance()).getString(
        VocabularyLibraryStore.storageKey,
      ),
      isNull,
    );
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
    expect(find.text('German A1 vocabulary'), findsNothing);
    await tester.tap(find.byKey(const Key('folder-My vocab')));
    await tester.pump();
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

    await openEditor(tester);

    expect(find.text('Add new word'), findsOneWidget);
    expect(find.text('Find your vocab...'), findsOneWidget);
    expect(find.text('My vocab'), findsOneWidget);
    expect(find.text('Homepage'), findsOneWidget);
    expect(find.byType(HomeHeader), findsOneWidget);
    expect(find.byType(HomeSidebar), findsOneWidget);
    expect(find.text('0/0'), findsNothing);
    expect(find.text('Practice'), findsNothing);

    await tester.tap(find.byKey(const Key('word-editor-back')));
    await tester.pumpAndSettle();

    expect(find.text('My vocab'), findsOneWidget);
    expect(find.text('0/0'), findsOneWidget);
    expect(find.text('German A1 vocabulary'), findsOneWidget);
    expect(find.text('Homepage'), findsOneWidget);
    expect(find.text('Add new word'), findsNothing);
  });

  testWidgets('library shows saved sets and folders', (tester) async {
    const word = VocabularyWord(
      term: 'Kind',
      definition: 'child',
      sentence: '',
      ipa: '',
      singularPlural: '',
      note: '',
    );
    await pumpApp(
      tester,
      library: const VocabularyLibrary(
        folders: <VocabularyFolder>[
          VocabularyFolder(
            name: 'My vocab',
            sets: <String>['German A1'],
            contents: <VocabularySet?>[
              VocabularySet(
                title: 'German A1',
                description: '',
                words: <VocabularyWord>[word, word],
              ),
            ],
          ),
        ],
      ),
    );

    await tester.tap(find.byKey(const Key('nav-library')));
    await tester.pumpAndSettle();

    expect(find.text('Your library'), findsOneWidget);
    expect(find.text('Your vocabulary statistics'), findsNothing);
    expect(find.text('2 terms · My vocab'), findsOneWidget);
    expect(find.text('German A1'), findsOneWidget);
    expect(
      tester
          .widget<Material>(
            find.descendant(
              of: find.byKey(const Key('nav-library')),
              matching: find.byType(Material),
            ),
          )
          .color,
      HomePalette.dark.selectedFill,
    );

    await tester.tap(find.byKey(const Key('library-set-My vocab-0')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('set-study-page')), findsOneWidget);
    expect(find.text('Kind'), findsNWidgets(3));
    expect(find.text('child'), findsNWidgets(3));
    expect(find.byKey(const Key('word-term')), findsNothing);
    expect(find.text('Add new word'), findsNothing);

    await tester.tap(find.byKey(const Key('nav-library')));
    await tester.pumpAndSettle();
    expect(find.text('Your library'), findsOneWidget);

    await tester.tap(find.byKey(const Key('library-chip-folders')));
    await tester.pump();
    expect(find.text('1 sets'), findsOneWidget);
    expect(find.text('My vocab'), findsWidgets);

    await tester.enterText(find.byKey(const Key('library-search')), 'zzz');
    await tester.pump();
    expect(find.text('Nothing here yet'), findsOneWidget);

    await tester.tap(find.byKey(const Key('nav-home')));
    await tester.pumpAndSettle();
    expect(find.text('Your vocabulary statistics'), findsOneWidget);
    expect(find.text('Your library'), findsNothing);
  });

  testWidgets('the library recent control opens a sort menu', (tester) async {
    await pumpApp(
      tester,
      library: const VocabularyLibrary(
        folders: <VocabularyFolder>[
          VocabularyFolder(name: 'My vocab', sets: <String>['First', 'Second']),
        ],
      ),
    );

    await tester.tap(find.byKey(const Key('nav-library')));
    await tester.pumpAndSettle();

    expect(
      tester.getTopLeft(find.byKey(const Key('library-set-My vocab-1'))).dy,
      lessThan(
        tester.getTopLeft(find.byKey(const Key('library-set-My vocab-0'))).dy,
      ),
    );

    await tester.tap(find.byKey(const Key('library-recent')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('library-sort-created')), findsOneWidget);
    expect(find.byKey(const Key('library-sort-recent')), findsOneWidget);
    expect(find.byKey(const Key('library-sort-studied')), findsOneWidget);

    await tester.tap(find.byKey(const Key('library-sort-created')));
    await tester.pumpAndSettle();

    expect(find.text('Created'), findsOneWidget);
    expect(find.byKey(const Key('library-sort-studied')), findsNothing);
    expect(
      tester.getTopLeft(find.byKey(const Key('library-set-My vocab-0'))).dy,
      lessThan(
        tester.getTopLeft(find.byKey(const Key('library-set-My vocab-1'))).dy,
      ),
    );
  });

  testWidgets('a library folder opens its sets', (tester) async {
    const word = VocabularyWord(
      term: 'Kind',
      definition: 'child',
      sentence: 'Das Kind',
      ipa: '/kɪnt/',
      singularPlural: 'Kind, Kinder',
      note: 'people',
    );
    await pumpApp(
      tester,
      library: const VocabularyLibrary(
        folders: <VocabularyFolder>[
          VocabularyFolder(
            name: 'Travel',
            sets: <String>['Airport'],
            contents: <VocabularySet?>[
              VocabularySet(
                title: 'Airport',
                description: 'trips',
                words: <VocabularyWord>[word, word],
              ),
            ],
          ),
          VocabularyFolder(name: 'Home', sets: <String>['Kitchen']),
        ],
      ),
    );

    await tester.tap(find.byKey(const Key('nav-library')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('library-chip-folders')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('library-folder-Travel')));
    await tester.pumpAndSettle();

    final page = find.byKey(const Key('library-folder-page'));
    expect(page, findsOneWidget);
    expect(
      find.descendant(of: page, matching: find.text('Airport')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: page, matching: find.text('Kitchen')),
      findsNothing,
    );
    expect(
      find.descendant(
        of: page,
        matching: find.text('Flashcard sets · 2 terms'),
      ),
      findsOneWidget,
    );
    expect(find.text('Search this folder'), findsOneWidget);
    expect(find.byKey(const Key('library-folder-all')), findsOneWidget);
    expect(find.byKey(const Key('library-folder-study')), findsOneWidget);
    expect(find.byKey(const Key('library-folder-add-sets')), findsOneWidget);

    await tester.enterText(find.byKey(const Key('library-search')), 'zzz');
    await tester.pump();
    expect(
      find.descendant(of: page, matching: find.text('Nothing here yet')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('library-set-Travel-0')), findsNothing);

    await tester.enterText(find.byKey(const Key('library-search')), '');
    await tester.pump();
    await tester.tap(find.byKey(const Key('library-set-Travel-0')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('set-study-page')), findsOneWidget);
    expect(find.text('Kind'), findsNWidgets(3));
    expect(find.byKey(const Key('word-term')), findsNothing);

    await tester.tap(find.byKey(const Key('nav-library')));
    await tester.pumpAndSettle();
    expect(page, findsOneWidget);

    await tester.tap(find.byKey(const Key('nav-home')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('nav-library')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('library-page')), findsOneWidget);
    expect(find.text('Your library'), findsOneWidget);
  });

  testWidgets('a folder click hides and shows its sets', (tester) async {
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

    expect(find.text('German A1 vocabulary'), findsNothing);

    await tester.tap(find.byKey(const Key('folder-My vocab')));
    await tester.pump();

    expect(find.text('My vocab'), findsOneWidget);
    expect(find.text('German A1 vocabulary'), findsOneWidget);

    await tester.tap(find.byKey(const Key('folder-My vocab')));
    await tester.pump();

    expect(find.text('German A1 vocabulary'), findsNothing);
  });

  testWidgets('a set click opens that set in the editor', (tester) async {
    const word = VocabularyWord(
      term: 'Kind',
      definition: 'child',
      sentence: 'Das Kind',
      ipa: '/kɪnt/',
      singularPlural: 'Kind, Kinder',
      note: 'people',
      type: 'noun',
    );
    await pumpApp(
      tester,
      library: const VocabularyLibrary(
        folders: <VocabularyFolder>[
          VocabularyFolder(
            name: 'My vocab',
            sets: <String>['German A1'],
            contents: <VocabularySet?>[
              VocabularySet(
                title: 'German A1',
                description: 'basics',
                words: <VocabularyWord>[word],
              ),
            ],
          ),
        ],
      ),
    );

    await tester.tap(find.byKey(const Key('folder-My vocab')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('vocab-set-My vocab-0')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('set-study-page')), findsOneWidget);
    expect(find.text('Today practice'), findsOneWidget);
    expect(find.text('Learn new vocab'), findsOneWidget);
    expect(find.text('Vocabulary list'), findsOneWidget);
    expect(find.text('Your vocabulary statistics'), findsOneWidget);
    expect(find.text('0/1'), findsOneWidget);
    expect(find.text('Kind'), findsNWidgets(2));
    expect(_cardText('child'), findsOneWidget);
    expect(_cardText('Das Kind'), findsOneWidget);
    expect(_cardText('Kind'), findsOneWidget);
    expect(find.byKey(const Key('set-study-speak')), findsOneWidget);
    expect(find.byKey(const Key('set-study-prev')), findsOneWidget);
    expect(find.byKey(const Key('set-study-peek')), findsNothing);
    expect(find.text('Tap the card to see the meaning'), findsNothing);
    expect(find.byKey(const Key('word-term')), findsNothing);

    await tester.tap(find.byKey(const Key('set-study-today-practice')));
    await tester.pumpAndSettle();
    expect(_cardText('child'), findsNothing);
    expect(_cardText('Das Kind'), findsNothing);
    expect(_cardText('Kind'), findsOneWidget);
    expect(tester.widget<Text>(_cardText('Kind')).textAlign, TextAlign.center);
    expect(find.text('Tap the card to see the meaning'), findsOneWidget);
    expect(find.byKey(const Key('set-study-prev')), findsNothing);

    await tester.tap(find.byKey(const Key('set-study-card-tap')));
    await tester.pumpAndSettle();
    expect(_cardText('child'), findsOneWidget);
    expect(tester.widget<Text>(_cardText('child')).textAlign, TextAlign.center);
    expect(_cardText('Das Kind'), findsOneWidget);
    expect(_cardText('Kind'), findsNothing);
    expect(find.text('Tap the card to see the meaning'), findsNothing);
    expect(find.byKey(const Key('set-study-speak')), findsOneWidget);

    await tester.tap(find.byKey(const Key('set-study-card-tap')));
    await tester.pumpAndSettle();
    expect(_cardText('Kind'), findsOneWidget);
    expect(_cardText('child'), findsNothing);

    await tester.tap(find.byKey(const Key('set-study-easy')));
    await tester.pump();
    expect(find.text('1/1'), findsOneWidget);
    await tester.tap(find.byKey(const Key('set-study-practice-back')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('set-study-filter-mastered')));
    await tester.pump();
    expect(find.byKey(const Key('set-study-word-0')), findsOneWidget);
    await tester.tap(find.byKey(const Key('set-study-filter-learning')));
    await tester.pump();
    expect(find.byKey(const Key('set-study-word-0')), findsNothing);

    await tester.tap(find.byKey(const Key('set-study-add')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('word-editor-title')))
          .controller!
          .text,
      'German A1',
    );
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('word-editor-description')))
          .controller!
          .text,
      'basics',
    );
    expect(find.text('Noun'), findsNothing);
    expect(find.text('Add new word'), findsNothing);

    await tester.tap(find.byKey(const Key('word-editor-back')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('set-study-page')), findsOneWidget);
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
    final contentWidth = tester
        .getSize(find.byKey(const Key('home-canvas')))
        .width;
    final contentLeft = tester
        .getTopLeft(find.byKey(const Key('home-canvas')))
        .dx;

    await tester.tap(find.byKey(const Key('drawer-menu')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 140));

    expect(tester.getSize(find.byType(HomeSidebar)).width, HomeSidebar.width);

    await tester.pumpAndSettle();

    expect(tester.getSize(find.byType(HomeSidebar)).width, HomeSidebar.width);
    expect(
      tester.getSize(find.byKey(const Key('home-canvas'))).width,
      contentWidth,
    );
    expect(
      tester.getTopLeft(find.byKey(const Key('home-canvas'))).dx,
      contentLeft,
    );
    expect(tester.getSize(find.byKey(const Key('nav-home-label'))).width, 0);
    expect(tester.getSize(find.byKey(const Key('sidebar-extra'))).height, 0);
    final sidebar = tester.getRect(find.byType(HomeSidebar));
    expect(
      tester.getCenter(find.byIcon(Icons.home_outlined)).dx,
      lessThan(sidebar.center.dx),
    );
    final selectedFill = find.descendant(
      of: find.byKey(const Key('nav-home')),
      matching: find.byType(Material),
    );
    expect(
      tester.widget<Material>(selectedFill).color,
      HomePalette.dark.selectedFill,
    );
    expect(
      tester.getSize(selectedFill),
      const Size(HomeSidebar.collapsedSlot, HomeSidebar.collapsedSlot),
    );
    expect(tester.getCenter(selectedFill).dx, lessThan(sidebar.center.dx));
    final chip = tester.getSize(find.byKey(const Key('folder-My vocab')));
    expect(chip.width, HomeSidebar.collapsedSlot);
    expect(chip.height, HomeSidebar.collapsedSlot);
    expect(
      tester.getCenter(find.byKey(const Key('folder-My vocab'))).dx,
      lessThan(sidebar.center.dx),
    );
    final search = find.descendant(
      of: find.byType(HomeSidebar),
      matching: find.byIcon(Icons.search),
    );
    final folderDivider = find.byKey(const Key('collapsed-folder-divider'));
    expect(search, findsOneWidget);
    expect(
      tester.getCenter(search).dx,
      tester.getCenter(find.byIcon(Icons.home_outlined)).dx,
    );
    expect(folderDivider, findsOneWidget);
    expect(tester.getSize(folderDivider).width, HomeSidebar.collapsedSlot);
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

  testWidgets('wide home keeps the design width centered', (tester) async {
    await pumpApp(tester);
    final viewport = tester.view.physicalSize.width;
    final header = tester.getRect(find.byType(HomeHeader));
    final sidebar = tester.getRect(find.byType(HomeSidebar));
    final canvas = tester.getRect(find.byKey(const Key('home-canvas')));
    expect(header.left, 0);
    expect(header.width, viewport);
    expect(sidebar.left, 0);
    expect(canvas.width, VocabularyHome.designWidth - HomeSidebar.width);
    expect(canvas.left, greaterThanOrEqualTo(sidebar.right));
    expect(
      canvas.center.dx,
      moreOrLessEquals(sidebar.right + (viewport - sidebar.width) / 2),
    );
    expect(find.byKey(const Key('home-advertisement')), findsNothing);

    final logo = tester.getRect(find.byKey(const Key('header-logo')));
    final search = tester.getRect(find.text('Find your vocab...'));
    final searchField = tester.getRect(find.byType(TextField));
    final newVocab = tester.getRect(find.text('New vocab'));
    final avatar = tester.getRect(
      find.image(const AssetImage('assets/images/avatar.jpg')),
    );
    expect(search.top, lessThan(logo.bottom));
    expect(logo.top, lessThan(search.bottom));
    expect(searchField.width, HomeHeader.searchWidth);
    expect(searchField.center.dx, moreOrLessEquals(header.center.dx));
    expect(newVocab.top, lessThan(logo.bottom));
    expect(logo.top, lessThan(newVocab.bottom));
    expect(avatar.top, lessThan(logo.bottom));
    expect(logo.top, lessThan(avatar.bottom));

    final hotSearch = tester.getRect(find.text('Hot search'));
    final suggestedPractice = tester.getRect(find.text('Suggested practice'));
    expect(suggestedPractice.left, greaterThan(hotSearch.right));
    expect(suggestedPractice.top, lessThan(hotSearch.bottom + 800));
    expect(hotSearch.top, lessThan(suggestedPractice.bottom));
  });

  testWidgets('wide dashboard keeps statistics beside today', (tester) async {
    await pumpApp(
      tester,
      library: const VocabularyLibrary(
        folders: [
          VocabularyFolder(name: 'My vocab', sets: ['German A1 vocabulary']),
        ],
      ),
    );

    final statistics = tester.getRect(find.byType(StatisticsPanel));
    final today = tester.getRect(find.text("Today's vocabulary"));
    final recent = tester.getRect(find.text('Recent'));
    expect(find.text('Your vocabulary statistics'), findsOneWidget);
    expect(today.left, greaterThan(statistics.left));
    expect(today.top, lessThan(statistics.bottom));
    expect(statistics.top, lessThan(today.bottom));
    expect(recent.top, greaterThan(statistics.bottom));
    expect(recent.top, greaterThan(today.bottom));
  });

  testWidgets('narrow home stacks into one column', (tester) async {
    const narrow = Size(800, 1200);
    await pumpApp(tester, size: narrow);
    final canvas = tester.getRect(find.byKey(const Key('home-canvas')));
    expect(canvas.left, 0);
    expect(canvas.width, narrow.width);
    expect(find.byType(HomeSidebar), findsNothing);

    final menu = tester.getRect(find.byKey(const Key('drawer-menu')));
    final logo = tester.getRect(find.byKey(const Key('header-logo')));
    final avatar = tester.getRect(
      find.image(const AssetImage('assets/images/avatar.jpg')),
    );
    final search = tester.getRect(find.text('Find your vocab...'));
    final searchField = tester.getRect(find.byType(TextField));
    final newVocab = tester.getRect(find.text('New vocab'));
    final header = tester.getRect(find.byType(HomeHeader));
    expect(menu.top, lessThan(logo.bottom));
    expect(logo.top, lessThan(menu.bottom));
    expect(avatar.top, lessThan(logo.bottom));
    expect(logo.top, lessThan(avatar.bottom));
    expect(search.top, greaterThan(logo.bottom));
    expect(searchField.width, HomeHeader.searchWidth);
    expect(searchField.center.dx, moreOrLessEquals(header.center.dx));
    expect(newVocab.top, greaterThan(search.bottom));
    expect(
      tester.getSize(find.widgetWithText(FilledButton, 'New vocab')).width,
      greaterThan(narrow.width / 2),
    );

    final hotSearch = tester.getRect(find.text('Hot search'));
    final suggestedSets = tester.getRect(find.text('Suggested sets'));
    final suggestedPractice = tester.getRect(find.text('Suggested practice'));
    expect(suggestedSets.top, greaterThan(hotSearch.bottom));
    expect(suggestedPractice.top, greaterThan(suggestedSets.bottom));
    expect(find.text('Your vocabulary statistics'), findsNothing);
    expect(find.text("Today's vocabulary"), findsNothing);
    expect(find.text('Recent'), findsNothing);
    expect(find.text('0/0'), findsNothing);
    expect(find.text('Practice'), findsNothing);
  });

  testWidgets('narrow dashboard stacks statistics, today, and recent', (
    tester,
  ) async {
    const narrow = Size(800, 1200);
    await pumpApp(
      tester,
      size: narrow,
      library: const VocabularyLibrary(
        folders: [
          VocabularyFolder(name: 'My vocab', sets: ['German A1 vocabulary']),
        ],
      ),
    );

    final statistics = tester.getRect(find.text('Your vocabulary statistics'));
    final today = tester.getRect(find.text("Today's vocabulary"));
    final recent = tester.getRect(find.text('Recent'));
    expect(today.top, greaterThan(statistics.bottom));
    expect(recent.top, greaterThan(today.bottom));
    expect(recent.left, greaterThanOrEqualTo(0));
    expect(recent.right, lessThanOrEqualTo(narrow.width));
    expect(find.byType(HomeSidebar), findsNothing);
  });

  testWidgets('narrow menu covers the page with the sidebar', (tester) async {
    const narrow = Size(800, 1200);
    await pumpApp(tester, size: narrow);

    expect(find.byType(HomeSidebar), findsNothing);

    await tester.tap(find.byKey(const Key('drawer-menu')));
    await tester.pumpAndSettle();

    expect(tester.getSize(find.byType(HomeSidebar)).width, HomeSidebar.width);
    expect(find.text('Homepage'), findsOneWidget);
    expect(find.text('Library'), findsOneWidget);
    expect(find.text('Notification'), findsOneWidget);
    expect(find.text('Your vocabulary set'), findsOneWidget);
    expect(find.text('Set of words'), findsOneWidget);
    expect(tester.widget<Icon>(find.byIcon(Icons.add_outlined)).size, 20);
    expect(find.text('My vocab'), findsNothing);
    final selected = find.descendant(
      of: find.byKey(const Key('nav-home')),
      matching: find.byType(Material),
    );
    expect(
      tester.widget<Material>(selected).color,
      HomePalette.dark.selectedFill,
    );

    await tester.tap(find.byKey(const Key('sidebar-barrier')));
    await tester.pumpAndSettle();
    expect(find.byType(HomeSidebar), findsNothing);

    await tester.tap(find.byKey(const Key('drawer-menu')));
    await tester.pumpAndSettle();
    expect(find.byType(HomeSidebar), findsOneWidget);
    await tester.tap(find.byKey(const Key('drawer-menu')));
    await tester.pumpAndSettle();
    expect(find.byType(HomeSidebar), findsNothing);
  });

  testWidgets('narrow menu shows the loaded folder over the page', (
    tester,
  ) async {
    const narrow = Size(800, 1200);
    await pumpApp(
      tester,
      size: narrow,
      library: const VocabularyLibrary(
        folders: [
          VocabularyFolder(name: 'My vocab', sets: ['German A1 vocabulary']),
        ],
      ),
    );

    expect(find.text('My vocab'), findsNothing);
    expect(find.text('German A1 vocabulary'), findsNothing);
    expect(find.text('0/0'), findsOneWidget);
    expect(find.text('0%'), findsWidgets);
    expect(find.text('Hot search'), findsNothing);

    await tester.tap(find.byKey(const Key('drawer-menu')));
    await tester.pumpAndSettle();

    expect(find.text('My vocab'), findsOneWidget);
    expect(find.text('German A1 vocabulary'), findsNothing);
    await tester.tap(find.byKey(const Key('folder-My vocab')));
    await tester.pump();
    expect(find.text('German A1 vocabulary'), findsOneWidget);
    expect(tester.getSize(find.byType(HomeSidebar)).width, HomeSidebar.width);
    expect(find.text('0/0'), findsOneWidget);
    expect(find.text('Hot search'), findsNothing);
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

  testWidgets('random slides between words and one word stays', (tester) async {
    await pumpApp(
      tester,
      library: _libraryOf(<_NamedSet>[
        _NamedSet('German A1', <VocabularyWord>[_kind, _haus]),
      ]),
    );
    await _openSet(tester);
    await _startPractice(tester);

    await tester.tap(find.byKey(const Key('set-study-mode-random')));
    await tester.pumpAndSettle();
    expect(_cardText('Kind'), findsOneWidget);
    expect(_cardText('child'), findsOneWidget);
    expect(find.byKey(const Key('set-study-peek')), findsOneWidget);

    await tester.tap(find.byKey(const Key('set-study-card-tap')));
    await tester.pumpAndSettle();
    expect(_cardText('Kind'), findsOneWidget);
    expect(_cardText('child'), findsOneWidget);

    await tester.tap(find.byKey(const Key('set-study-next')));
    await tester.pumpAndSettle();
    expect(_cardText('Haus'), findsOneWidget);

    await tester.tap(find.byKey(const Key('set-study-prev')));
    await tester.pumpAndSettle();
    expect(_cardText('Kind'), findsOneWidget);

    await pumpApp(tester, library: _libraryOf(<_NamedSet>[
      _NamedSet('German A1', <VocabularyWord>[_kind]),
    ]));
    await _openSet(tester);
    await _startPractice(tester);
    await tester.tap(find.byKey(const Key('set-study-mode-random')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('set-study-next')));
    await tester.pumpAndSettle();
    expect(_cardText('Kind'), findsOneWidget);
  });

  testWidgets('ratings are stored and flashcard advances', (tester) async {
    final progress = _MemoryProgress();
    await pumpApp(
      tester,
      studyProgress: progress,
      library: _libraryOf(<_NamedSet>[
        _NamedSet('German A1', <VocabularyWord>[_kind], id: 'setA'),
      ]),
    );
    await _openSet(tester);
    await _startPractice(tester);
    await tester.tap(find.byKey(const Key('set-study-easy')));
    await tester.pumpAndSettle();

    expect(progress.rates, <(String, int, StudyMark)>[
      ('setA', 0, StudyMark.easy),
    ]);
    expect(find.text('1/1'), findsOneWidget);
    await tester.tap(find.byKey(const Key('set-study-practice-back')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('set-study-filter-mastered')));
    await tester.pump();
    expect(find.byKey(const Key('set-study-word-0')), findsOneWidget);
    final preferences = await SharedPreferences.getInstance();
    expect(
      preferences.getString(VocabularyLibraryStore.storageKey),
      isNot(contains('learnedCount')),
    );

    await pumpApp(
      tester,
      studyProgress: progress,
      library: _libraryOf(<_NamedSet>[
        _NamedSet('German A1', <VocabularyWord>[_kind, _haus], id: 'setA'),
      ]),
    );
    await _openSet(tester);
    await _startPractice(tester);
    await tester.tap(find.byKey(const Key('set-study-easy')));
    await tester.pumpAndSettle();
    expect(_cardText('Haus'), findsOneWidget);
    expect(_cardText('house'), findsNothing);

    final untouched = _MemoryProgress();
    await pumpApp(
      tester,
      studyProgress: untouched,
      library: _libraryOf(<_NamedSet>[
        _NamedSet('German A1', <VocabularyWord>[_kind]),
      ]),
    );
    await _openSet(tester);
    await _startPractice(tester);
    await tester.tap(find.byKey(const Key('set-study-easy')));
    await tester.pump();
    expect(untouched.rates, isEmpty);
    expect(
      tester
          .widget<IconButton>(find.byKey(const Key('set-study-easy')))
          .style
          ?.side
          ?.resolve(<WidgetState>{}),
      isNotNull,
    );
  });

  testWidgets('opening a set selects the stored easy mark', (tester) async {
    final progress = _MemoryProgress(
      marks: <String, Map<int, StudyMark>>{
        'setA': <int, StudyMark>{0: StudyMark.easy},
      },
    );
    await pumpApp(
      tester,
      studyProgress: progress,
      library: _libraryOf(<_NamedSet>[
        _NamedSet('German A1', <VocabularyWord>[_kind], id: 'setA'),
      ]),
    );
    await _openSet(tester);
    await _startPractice(tester);

    expect(find.text('1/1'), findsOneWidget);
    expect(
      tester
          .widget<IconButton>(find.byKey(const Key('set-study-easy')))
          .style
          ?.side
          ?.resolve(<WidgetState>{}),
      isNotNull,
    );
  });

  testWidgets('statistics follow stored marks and All', (tester) async {
    final progress = _MemoryProgress(
      home: StudyHomeData(
        progress: <String, StudySetProgress>{
          'setA': StudySetProgress(
            marks: const <int, StudyMark>{
              0: StudyMark.easy,
              1: StudyMark.familiar,
              2: StudyMark.hard,
            },
            updatedAt: DateTime(2026, 1, 1),
          ),
        },
      ),
    );
    await pumpApp(
      tester,
      studyProgress: progress,
      library: _libraryOf(<_NamedSet>[
        _NamedSet('German A1', <VocabularyWord>[
          _kind,
          _haus,
          _plain('Auto'),
          _plain('Baum'),
        ], id: 'setA'),
      ]),
    );

    await tester.pumpAndSettle();
    expect(find.text('1/4'), findsOneWidget);
    expect(find.text('25%'), findsNWidgets(5));
    expect(find.text('0%'), findsNWidgets(2));
    expect(find.text('1'), findsNWidgets(4));

    final later = _MemoryProgress(
      home: StudyHomeData(
        progress: <String, StudySetProgress>{
          'setA': StudySetProgress(
            marks: const <int, StudyMark>{0: StudyMark.hard},
            updatedAt: DateTime(2026, 1, 1),
          ),
          'setB': StudySetProgress(
            marks: const <int, StudyMark>{0: StudyMark.easy},
            updatedAt: DateTime(2026, 2, 1),
          ),
        },
      ),
    );
    await pumpApp(
      tester,
      studyProgress: later,
      library: _libraryOf(<_NamedSet>[
        _NamedSet('German A1 vocabulary', <VocabularyWord>[_kind, _haus], id: 'setA'),
        _NamedSet('Animals', <VocabularyWord>[_kind, _haus], id: 'setB'),
      ]),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('all-switch')));
    await tester.pumpAndSettle();
    expect(find.text('1/2'), findsOneWidget);
    expect(find.text('50%'), findsWidgets);
    expect(find.text('Animals'), findsWidgets);
  });

  testWidgets('today and recent use the stored study', (tester) async {
    final progress = _MemoryProgress(
      home: StudyHomeData(
        agenda: const <StudyWordRef>[
          StudyWordRef(setId: 'setA', index: 0),
          StudyWordRef(setId: 'setA', index: 1),
        ],
        progress: <String, StudySetProgress>{
          'setA': StudySetProgress(
            marks: const <int, StudyMark>{0: StudyMark.easy},
            updatedAt: DateTime(2026, 1, 1),
          ),
          'setB': StudySetProgress(
            marks: const <int, StudyMark>{0: StudyMark.easy},
            updatedAt: DateTime(2026, 3, 1),
          ),
          'setC': StudySetProgress(
            marks: <int, StudyMark>{
              0: StudyMark.easy,
              1: StudyMark.easy,
              2: StudyMark.easy,
              3: StudyMark.easy,
              4: StudyMark.easy,
              5: StudyMark.easy,
              6: StudyMark.easy,
              7: StudyMark.easy,
              8: StudyMark.easy,
              9: StudyMark.easy,
              10: StudyMark.easy,
              11: StudyMark.easy,
              12: StudyMark.easy,
              13: StudyMark.easy,
              14: StudyMark.easy,
            },
            updatedAt: DateTime(2026, 2, 1),
          ),
        },
      ),
    );
    await pumpApp(
      tester,
      studyProgress: progress,
      library: _libraryOf(<_NamedSet>[
        _NamedSet(
          'German A1 vocabulary',
          <VocabularyWord>[_kind, _haus, _plain('A'), _plain('B')],
          id: 'setA',
        ),
        _NamedSet('Animals', <VocabularyWord>[_kind, _haus], id: 'setB'),
        _NamedSet(
          'Green',
          <VocabularyWord>[
            for (var index = 0; index < 16; index++) _plain('W$index'),
          ],
          id: 'setC',
        ),
      ]),
    );

    await tester.pumpAndSettle();
    expect(find.text('Kind'), findsWidgets);
    expect(find.text('das, -er'), findsWidgets);
    expect(find.text('Haus'), findsWidgets);
    expect(find.text('Practice'), findsOneWidget);
    expect(find.byKey(const Key('recent-card-0')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('recent-card-0')),
        matching: find.text('Animals'),
      ),
      findsOneWidget,
    );
    expect(find.text('The process is 50% complete.'), findsOneWidget);
    expect(find.text('The process is 25% complete.'), findsOneWidget);
    expect(find.text('The process is 94% complete.'), findsOneWidget);
    expect(_barColor(tester, 0), HomeSample.learning);
    expect(_barColor(tester, 1), HomeSample.progressGreen);
    expect(_barColor(tester, 2), HomeSample.forgot);

    await tester.tap(find.byKey(const Key('today-practice')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('set-study-page')), findsOneWidget);
    expect(_cardText('Kind'), findsOneWidget);
    expect(find.text('My vocab'), findsOneWidget);

    await tester.tap(find.text('Homepage'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('recent-card-0')),
        matching: find.text('Continue'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Animals'), findsWidgets);
    expect(find.byKey(const Key('set-study-page')), findsOneWidget);
    expect(find.text('My vocab'), findsOneWidget);
  });

  testWidgets('an empty day list keeps Practice on the home', (tester) async {
    await pumpApp(
      tester,
      studyProgress: _MemoryProgress(),
      library: _libraryOf(<_NamedSet>[
        _NamedSet('German A1', <VocabularyWord>[_kind], id: 'setA'),
      ]),
    );

    await tester.pumpAndSettle();
    expect(find.text('Practice'), findsOneWidget);
    expect(find.text('Kind'), findsNothing);
    await tester.tap(find.byKey(const Key('today-practice')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('set-study-page')), findsNothing);
    expect(find.text('Homepage'), findsOneWidget);
    expect(find.text('0/0'), findsOneWidget);
  });
}

Finder _cardText(String text) {
  return find.descendant(
    of: find.byKey(const Key('set-study-card')),
    matching: find.text(text),
  );
}

Color? _barColor(WidgetTester tester, int index) {
  final box = tester.widget<DecoratedBox>(
    find.descendant(
      of: find.byKey(Key('recent-bar-$index')),
      matching: find.byType(DecoratedBox),
    ).last,
  );
  final decoration = box.decoration;
  return decoration is BoxDecoration ? decoration.color : null;
}

const _kind = VocabularyWord(
  term: 'Kind',
  definition: 'child',
  sentence: 'Das Kind',
  ipa: 'kɪnt',
  singularPlural: 'das, -er',
  note: 'noun',
);

const _haus = VocabularyWord(
  term: 'Haus',
  definition: 'house',
  sentence: 'Das Haus',
  ipa: 'haʊs',
  singularPlural: 'das, -er',
  note: 'noun',
);

VocabularyWord _plain(String term) {
  return VocabularyWord(
    term: term,
    definition: term,
    sentence: '',
    ipa: '',
    singularPlural: '',
    note: '',
  );
}

class _NamedSet {
  const _NamedSet(this.title, this.words, {this.id});

  final String title;
  final List<VocabularyWord> words;
  final String? id;
}

VocabularyLibrary _libraryOf(List<_NamedSet> sets) {
  return VocabularyLibrary(
    folders: <VocabularyFolder>[
      VocabularyFolder(
        name: 'My vocab',
        sets: <String>[for (final set in sets) set.title],
        contents: <VocabularySet?>[
          for (final set in sets)
            VocabularySet(
              id: set.id,
              title: set.title,
              description: '',
              words: set.words,
            ),
        ],
      ),
    ],
  );
}

Future<void> _startPractice(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('set-study-today-practice')));
  await tester.pumpAndSettle();
}

Future<void> _openSet(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('nav-library')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('library-set-My vocab-0')));
  await tester.pumpAndSettle();
}

class _MemoryProgress implements StudyProgressStore {
  _MemoryProgress({
    this.home = StudyHomeData.empty,
    Map<String, Map<int, StudyMark>>? marks,
  }) : marks = marks ?? <String, Map<int, StudyMark>>{};

  final StudyHomeData home;
  final Map<String, Map<int, StudyMark>> marks;
  final rates = <(String, int, StudyMark)>[];

  @override
  Future<StudyHomeData> loadHome(List<StudySetInput> sets) async => home;

  @override
  Future<Map<int, StudyMark>> marksFor(String setId) async {
    return marks[setId] ?? const <int, StudyMark>{};
  }

  @override
  Future<void> rate({
    required String setId,
    required int index,
    required StudyMark mark,
  }) async {
    rates.add((setId, index, mark));
  }
}

class _RecordingStore implements VocabularySetStore {
  Object? error;
  final saved = <VocabularySet>[];
  final createdFolders = <String>[];
  final editorFolders = <bool>[];

  @override
  Future<String> createFolder(String name, {bool editor = false}) async {
    final error = this.error;
    if (error != null) {
      throw error;
    }
    createdFolders.add(name);
    editorFolders.add(editor);
    return 'folder-${createdFolders.length}';
  }

  @override
  Future<void> save(VocabularySet set) async {
    final error = this.error;
    if (error != null) {
      throw error;
    }
    saved.add(set);
  }
}
