import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lang/features/home/quiz_tone.dart';
import 'package:lang/features/home/widgets/set_study_page.dart';
import 'package:lang/features/home/widgets/typing_card.dart';
import 'package:lang/l10n/app_localizations.dart';
import 'package:lang/library/study_progress.dart';
import 'package:lang/library/vocabulary_set.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> prepare(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1600, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<RecordingQuizTone> openTyping(
    WidgetTester tester, {
    required List<VocabularyWord> words,
    Map<int, StudyWordState>? levels,
    List<StudyCue>? cues,
    bool disableAnimations = false,
    _TypingMemory? store,
  }) async {
    await prepare(tester);
    if (disableAnimations) {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
    }
    final progress = store ?? _TypingMemory();
    if (levels != null) {
      progress.levels['setA'] = levels;
    }
    final tone = RecordingQuizTone();
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SetStudyPage(
          key: UniqueKey(),
          set: VocabularySet(
            id: 'setA',
            title: 'German A1',
            description: '',
            words: words,
          ),
          onEdit: () {},
          progress: progress,
          quizTone: tone,
          cues:
              cues ??
              <StudyCue>[
                for (var index = 0; index < words.length; index++)
                  StudyCue(word: words[index], setId: 'setA', index: index),
              ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('set-study-mode-typing')));
    await tester.pumpAndSettle();
    return tone;
  }

  Future<void> reveal(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();
  }

  Future<void> typeAnswer(WidgetTester tester, String value) async {
    await tester.enterText(find.byKey(const Key('set-study-typing')), value);
    await tester.pump();
  }

  testWidgets('typing shows meaning cue without the term', (tester) async {
    await openTyping(tester, words: <VocabularyWord>[_kind, _haus]);

    expect(find.byKey(const Key('typing-card')), findsOneWidget);
    expect(find.text('kɪnt'), findsOneWidget);
    expect(find.text('noun'), findsOneWidget);
    expect(find.text('child'), findsOneWidget);
    expect(find.text('Das ---'), findsOneWidget);
    expect(find.text('Your answer'), findsOneWidget);
    expect(find.text('Type the term'), findsOneWidget);
    expect(find.text("Don't know?"), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    expect(find.byKey(const Key('typing-revealed-term')), findsNothing);
    expect(
      find.descendant(
        of: find.byKey(const Key('typing-card')),
        matching: find.text('Kind'),
      ),
      findsNothing,
    );
    expect(find.byKey(const Key('set-study-next')), findsNothing);
    expect(find.byKey(const Key('set-study-prev')), findsNothing);
    expect(find.byKey(const Key('set-study-easy')), findsNothing);
    expect(
      tester.widget<FilledButton>(find.byKey(const Key('typing-check'))).onPressed,
      isNull,
    );

    await openTyping(tester, words: <VocabularyWord>[_bare]);
    expect(find.text('child'), findsOneWidget);
    expect(find.textContaining('kɪnt'), findsNothing);
    expect(typingCueLines(_bare), <String>['child']);
  });

  testWidgets('correct, wrong, and dont know settle with tones', (
    tester,
  ) async {
    final progress = _TypingMemory()
      ..levels['setA'] = <int, StudyWordState>{
        0: StudyWordState(level: 4, dueAt: DateTime(2020)),
        1: StudyWordState(level: 1, dueAt: DateTime(2020)),
      };
    final tone = await openTyping(
      tester,
      words: <VocabularyWord>[_kind, _haus],
      store: progress,
    );

    await typeAnswer(tester, 'kind');
    await tester.tap(find.byKey(const Key('typing-check')));
    await reveal(tester);
    expect(find.text('Nice!'), findsOneWidget);
    expect(find.byKey(const Key('typing-revealed-term')), findsOneWidget);
    expect(find.text('Kind'), findsWidgets);
    expect(tone.pitches, <QuizTonePitch>[QuizTonePitch.high]);
    expect(
      tester.widget<TextField>(find.byKey(const Key('set-study-typing'))).enabled,
      isFalse,
    );
    expect(
      tester
          .widget<TextButton>(find.byKey(const Key('typing-dont-know')))
          .onPressed,
      isNull,
    );

    await tester.tap(find.byKey(const Key('set-study-easy')));
    await tester.pumpAndSettle();
    await typeAnswer(tester, ' Haus ');
    await tester.tap(find.byKey(const Key('typing-check')));
    await reveal(tester);
    expect(find.text('Great job!'), findsOneWidget);

    tone.pitches.clear();
    final wrong = await openTyping(
      tester,
      words: <VocabularyWord>[_kind, _haus],
      store: progress,
    );
    await typeAnswer(tester, 'Haus');
    await tester.tap(find.byKey(const Key('typing-check')));
    await reveal(tester);
    expect(find.text("No sweat, you're still learning!"), findsOneWidget);
    expect(find.text('Kind'), findsWidgets);
    expect(wrong.pitches, <QuizTonePitch>[QuizTonePitch.low]);
    final saved = progress.saved.length;
    await tester.tap(find.byKey(const Key('typing-check')));
    await tester.pump();
    expect(progress.saved, hasLength(saved));

    final skipped = await openTyping(
      tester,
      words: <VocabularyWord>[_kind, _haus],
      store: progress,
    );
    await tester.tap(find.byKey(const Key('typing-dont-know')));
    await reveal(tester);
    expect(find.text('Give this one a try later!'), findsOneWidget);
    expect(find.byKey(const Key('typing-revealed-term')), findsOneWidget);
    expect(skipped.pitches, isEmpty);
  });

  testWidgets('level controls rise after the result', (tester) async {
    final progress = _TypingMemory()
      ..levels['setA'] = <int, StudyWordState>{
        0: StudyWordState(level: 1, dueAt: DateTime(2020)),
        1: StudyWordState(level: 1, dueAt: DateTime(2020)),
      };
    await openTyping(
      tester,
      words: <VocabularyWord>[_kind, _haus],
      store: progress,
    );
    expect(find.byKey(const Key('set-study-easy')), findsNothing);

    await typeAnswer(tester, 'Kind');
    await tester.tap(find.byKey(const Key('typing-check')));
    await reveal(tester);
    expect(find.byKey(const Key('set-study-easy')), findsOneWidget);
    expect(find.byKey(const Key('set-study-hard')), findsOneWidget);
    expect(find.byKey(const Key('set-study-familiar')), findsOneWidget);

    final fresh = _TypingMemory();
    await openTyping(tester, words: <VocabularyWord>[_kind], store: fresh);
    await typeAnswer(tester, 'Kind');
    await tester.tap(find.byKey(const Key('typing-check')));
    await reveal(tester);
    expect(find.byKey(const Key('set-study-easy')), findsNothing);
    expect(find.text('Not yet studied'), findsOneWidget);
    expect(find.text('Studied'), findsOneWidget);
  });

  testWidgets('easy, studied, and skip advance like quiz', (tester) async {
    final easy = _TypingMemory()
      ..levels['setA'] = <int, StudyWordState>{
        0: StudyWordState(level: 1, dueAt: DateTime(2020)),
        1: StudyWordState(level: 1, dueAt: DateTime(2020)),
      };
    await openTyping(tester, words: <VocabularyWord>[_kind, _haus], store: easy);
    await typeAnswer(tester, 'Kind');
    await tester.tap(find.byKey(const Key('typing-check')));
    await reveal(tester);
    await tester.tap(find.byKey(const Key('set-study-easy')));
    await tester.pumpAndSettle();
    expect(easy.saved.single.$3.level, 2);
    expect(find.text('haʊs'), findsOneWidget);
    expect(find.text('house'), findsOneWidget);

    final last = _TypingMemory()
      ..levels['setA'] = <int, StudyWordState>{
        0: StudyWordState(level: 4, dueAt: DateTime(2020)),
      };
    await openTyping(tester, words: <VocabularyWord>[_kind], store: last);
    await typeAnswer(tester, 'Kind');
    await tester.tap(find.byKey(const Key('typing-check')));
    await reveal(tester);
    await tester.tap(find.byKey(const Key('set-study-familiar')));
    await tester.pumpAndSettle();
    expect(last.saved.single.$3.level, 4);
    expect(find.byKey(const Key('set-study-complete')), findsOneWidget);

    final fresh = _TypingMemory();
    await openTyping(tester, words: <VocabularyWord>[_kind, _haus], store: fresh);
    await typeAnswer(tester, 'Kind');
    await tester.tap(find.byKey(const Key('typing-check')));
    await reveal(tester);
    await tester.tap(find.byKey(const Key('set-study-skip')));
    await tester.pumpAndSettle();
    expect(fresh.saved, isEmpty);
    expect(find.text('haʊs'), findsOneWidget);

    final studied = _TypingMemory();
    await openTyping(tester, words: <VocabularyWord>[_kind], store: studied);
    await typeAnswer(tester, 'Kind');
    await tester.tap(find.byKey(const Key('typing-check')));
    await reveal(tester);
    await tester.tap(find.byKey(const Key('set-study-studied')));
    await tester.pumpAndSettle();
    expect(studied.saved.single.$3.level, 1);
    expect(find.byKey(const Key('set-study-complete')), findsOneWidget);
  });

  testWidgets('leaving typing before a rating keeps the level', (tester) async {
    final progress = _TypingMemory()
      ..levels['setA'] = <int, StudyWordState>{
        0: StudyWordState(level: 1, dueAt: DateTime(2020)),
      };
    await openTyping(tester, words: <VocabularyWord>[_kind], store: progress);
    await typeAnswer(tester, 'Kind');
    await tester.tap(find.byKey(const Key('typing-check')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('set-study-mode-flashcard')));
    await tester.pumpAndSettle();
    expect(progress.saved, isEmpty);

    await openTyping(tester, words: <VocabularyWord>[_kind], store: progress);
    await typeAnswer(tester, 'Kind');
    await tester.tap(find.byKey(const Key('typing-check')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('set-study-practice-back')));
    await tester.pumpAndSettle();
    expect(progress.saved, isEmpty);
  });

  testWidgets('disabled animations show result and ratings at once', (
    tester,
  ) async {
    final progress = _TypingMemory()
      ..levels['setA'] = <int, StudyWordState>{
        0: StudyWordState(level: 1, dueAt: DateTime(2020)),
      };
    final tone = await openTyping(
      tester,
      words: <VocabularyWord>[_kind],
      store: progress,
      disableAnimations: true,
    );
    await typeAnswer(tester, 'Kind');
    await tester.tap(find.byKey(const Key('typing-check')));
    await tester.pump();
    expect(find.text('Nice!'), findsOneWidget);
    expect(find.byKey(const Key('set-study-easy')), findsOneWidget);
    expect(tone.pitches, <QuizTonePitch>[QuizTonePitch.high]);
    await tester.tap(find.byKey(const Key('set-study-easy')));
    await tester.pumpAndSettle();
    expect(progress.saved.single.$3.level, 2);
  });
}

const _kind = VocabularyWord(
  term: 'Kind',
  definition: 'child',
  sentence: 'Das Kind',
  ipa: 'kɪnt',
  singularPlural: '',
  note: '',
  type: 'noun',
);

const _haus = VocabularyWord(
  term: 'Haus',
  definition: 'house',
  sentence: 'Das Haus',
  ipa: 'haʊs',
  singularPlural: '',
  note: '',
  type: 'noun',
);

const _bare = VocabularyWord(
  term: 'Bare',
  definition: 'child',
  sentence: '',
  ipa: '',
  singularPlural: '',
  note: '',
);

class _TypingMemory implements StudyProgressStore {
  final levels = <String, Map<int, StudyWordState>>{};
  final saved = <(String, int, StudyWordState)>[];

  @override
  Future<StudyHomeData> loadHome(List<StudySetInput> sets) async {
    return StudyHomeData.empty;
  }

  @override
  Future<Map<int, StudyMark>> marksFor(String setId) async {
    return const <int, StudyMark>{};
  }

  @override
  Future<Map<int, StudyWordState>> levelsFor(String setId) async {
    return levels[setId] ?? const <int, StudyWordState>{};
  }

  @override
  Future<void> rate({
    required String setId,
    required int index,
    required StudyMark mark,
  }) async {}

  @override
  Future<void> saveLevel({
    required String setId,
    required int index,
    required StudyWordState state,
  }) async {
    saved.add((setId, index, state));
  }
}
