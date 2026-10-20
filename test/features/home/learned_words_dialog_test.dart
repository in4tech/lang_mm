import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lang/features/home/widgets/learned_words_dialog.dart';
import 'package:lang/l10n/app_localizations.dart';
import 'package:lang/library/vocabulary_set.dart';

void main() {
  VocabularyWord word(int index) => VocabularyWord(
    term: 'Word$index',
    definition: 'def$index',
    sentence: '',
    ipa: '',
    singularPlural: '',
    note: '',
  );

  Future<void> openDialog(
    WidgetTester tester, {
    required List<VocabularyWord> words,
  }) async {
    tester.view.physicalSize = const Size(1600, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              key: const Key('open-dialog'),
              onPressed: () => showLearnedWordsDialog(
                context: context,
                title: 'Words learned',
                words: words,
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('open-dialog')));
    await tester.pumpAndSettle();
  }

  Finder dialogText(String text) {
    return find.descendant(
      of: find.byKey(const Key('learned-words-dialog')),
      matching: find.text(text),
    );
  }

  testWidgets('shows 20 words then load more', (tester) async {
    final words = <VocabularyWord>[
      for (var i = 0; i < 25; i++) word(i),
    ];
    await openDialog(tester, words: words);

    expect(find.text('Words learned (25)'), findsOneWidget);
    expect(dialogText('Word0'), findsOneWidget);
    expect(dialogText('Word19'), findsOneWidget);
    expect(dialogText('Word20'), findsNothing);
    expect(find.byKey(const Key('learned-words-load-more')), findsOneWidget);

    await tester.tap(find.byKey(const Key('learned-words-load-more')));
    await tester.pumpAndSettle();

    expect(dialogText('Word20'), findsOneWidget);
    expect(dialogText('Word24'), findsOneWidget);
    expect(find.byKey(const Key('learned-words-load-more')), findsNothing);
  });

  testWidgets('hides load more when 20 or fewer words', (tester) async {
    final words = <VocabularyWord>[
      for (var i = 0; i < 20; i++) word(i),
    ];
    await openDialog(tester, words: words);

    expect(dialogText('Word0'), findsOneWidget);
    expect(dialogText('Word19'), findsOneWidget);
    expect(find.byKey(const Key('learned-words-load-more')), findsNothing);
  });

  testWidgets('search resets the page to the first 20 matches', (tester) async {
    final words = <VocabularyWord>[
      for (var i = 0; i < 25; i++) word(i),
    ];
    await openDialog(tester, words: words);

    await tester.tap(find.byKey(const Key('learned-words-load-more')));
    await tester.pumpAndSettle();
    expect(dialogText('Word24'), findsOneWidget);
    expect(find.byKey(const Key('learned-words-load-more')), findsNothing);

    await tester.enterText(
      find.byKey(const Key('learned-words-search')),
      'Word',
    );
    await tester.pump();

    expect(dialogText('Word19'), findsOneWidget);
    expect(dialogText('Word20'), findsNothing);
    expect(find.byKey(const Key('learned-words-load-more')), findsOneWidget);
  });
}
