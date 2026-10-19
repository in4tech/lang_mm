import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lang/features/home/quiz_tone.dart';
import 'package:lang/features/home/widgets/quiz_card.dart';
import 'package:lang/features/home/widgets/set_study_page.dart';
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

  Future<RecordingQuizTone> openQuiz(
    WidgetTester tester, {
    required List<VocabularyWord> words,
    Map<int, StudyWordState>? levels,
    List<StudyCue>? cues,
    bool disableAnimations = false,
    _QuizMemory? store,
  }) async {
    await prepare(tester);
    if (disableAnimations) {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
    }
    final progress = store ?? _QuizMemory();
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
    await tester.tap(find.byKey(const Key('set-study-mode-quiz')));
    await tester.pumpAndSettle();
    return tone;
  }

  Future<void> reveal(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();
  }

  testWidgets('quiz asks with numbered options from the set', (tester) async {
    await openQuiz(tester, words: <VocabularyWord>[_kind, _haus, _auto, _baum]);

    expect(find.text('Term'), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('quiz-term'))).data,
      'Kind',
    );
    expect(find.text('Choose an answer'), findsOneWidget);
    expect(find.text("Don't know?"), findsOneWidget);
    expect(find.text('1'), findsWidgets);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.textContaining('child'), findsOneWidget);
    expect(find.textContaining('house'), findsOneWidget);
    expect(_optionText('car'), findsOneWidget);
    expect(_optionText('tree'), findsOneWidget);
    expect(find.textContaining('kɪnt'), findsOneWidget);
    expect(find.textContaining('noun'), findsWidgets);
    expect(find.textContaining('Das Kind'), findsOneWidget);
    expect(find.byKey(const Key('set-study-next')), findsNothing);
    expect(find.byKey(const Key('set-study-prev')), findsNothing);
    expect(find.byKey(const Key('set-study-easy')), findsNothing);

    await openQuiz(tester, words: <VocabularyWord>[_kind, _haus]);
    expect(find.byKey(const Key('quiz-option-0')), findsOneWidget);
    expect(find.byKey(const Key('quiz-option-1')), findsOneWidget);
    expect(find.text('1'), findsWidgets);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsNothing);

    await openQuiz(tester, words: <VocabularyWord>[_bare]);
    expect(find.text('child'), findsOneWidget);
    expect(find.textContaining('kɪnt'), findsNothing);
  });

  testWidgets('a correct, wrong, and skipped answer settle in place', (
    tester,
  ) async {
    final progress = _QuizMemory()
      ..levels['setA'] = <int, StudyWordState>{
        0: StudyWordState(level: 4, dueAt: DateTime(2020)),
        1: StudyWordState(level: 1, dueAt: DateTime(2020)),
      };
    final tone = await openQuiz(
      tester,
      words: <VocabularyWord>[_kind, _haus, _auto],
      store: progress,
    );

    await tester.tap(find.byKey(const Key('quiz-option-0')));
    await reveal(tester);
    expect(_border(tester, 0).dashed, isFalse);
    expect(_border(tester, 0).color, quizCorrectColor);
    expect(
      find.descendant(
        of: find.byKey(const Key('quiz-option-0')),
        matching: find.byIcon(Icons.check),
      ),
      findsOneWidget,
    );
    expect(find.text('2'), findsOneWidget);
    expect(_optionOpacity(tester, 0), 1);
    expect(_optionOpacity(tester, 2), lessThan(1));
    expect(_dontKnow(tester).onPressed, isNull);
    expect(_dontKnowOpacity(tester), lessThan(1));
    expect(find.text('Nice!'), findsOneWidget);
    expect(find.text('Great job!'), findsNothing);
    final firstIcon = tester.widget<Icon>(
      find.byKey(const Key('quiz-praise-icon')),
    );
    expect(firstIcon.icon, Icons.auto_awesome);
    expect(firstIcon.color, isNot(quizCorrectColor));
    await tester.pump(const Duration(milliseconds: 1200));
    expect(find.text('Nice!'), findsOneWidget);
    expect(find.text('Great job!'), findsNothing);
    expect(tone.pitches, <QuizTonePitch>[QuizTonePitch.high]);

    await tester.tap(find.byKey(const Key('set-study-easy')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('quiz-option-1')));
    await reveal(tester);
    expect(find.text('Great job!'), findsOneWidget);
    expect(find.text('Nice!'), findsNothing);
    final secondIcon = tester.widget<Icon>(
      find.byKey(const Key('quiz-praise-icon')),
    );
    expect(secondIcon.icon, Icons.celebration);
    expect(secondIcon.color, isNot(quizCorrectColor));
    expect(secondIcon.color, isNot(firstIcon.color));

    tone.pitches.clear();
    final wrong = await openQuiz(
      tester,
      words: <VocabularyWord>[_kind, _haus, _auto],
      store: progress,
    );
    await tester.tap(find.byKey(const Key('quiz-option-1')));
    await reveal(tester);
    expect(find.text("No sweat, you're still learning!"), findsOneWidget);
    expect(_border(tester, 0).dashed, isTrue);
    expect(_border(tester, 0).color, quizCorrectColor);
    expect(_border(tester, 1).dashed, isFalse);
    expect(_border(tester, 1).color, quizWrongColor);
    expect(
      find.descendant(
        of: find.byKey(const Key('quiz-option-1')),
        matching: find.byIcon(Icons.close),
      ),
      findsOneWidget,
    );
    expect(_optionOpacity(tester, 0), 1);
    expect(_optionOpacity(tester, 1), 1);
    expect(_optionOpacity(tester, 2), lessThan(1));
    expect(_dontKnow(tester).onPressed, isNull);
    expect(_dontKnowOpacity(tester), lessThan(1));
    expect(wrong.pitches, <QuizTonePitch>[QuizTonePitch.low]);
    final saved = progress.saved.length;
    await tester.tap(find.byKey(const Key('quiz-option-0')));
    await tester.pump();
    expect(progress.saved, hasLength(saved));
    expect(find.text("No sweat, you're still learning!"), findsOneWidget);

    final skipped = await openQuiz(
      tester,
      words: <VocabularyWord>[_kind, _haus, _auto],
      store: progress,
    );
    await tester.tap(find.byKey(const Key('quiz-dont-know')));
    await reveal(tester);
    expect(find.text('Give this one a try later!'), findsOneWidget);
    expect(_border(tester, 0).dashed, isTrue);
    expect(
      find.descendant(
        of: find.byKey(const Key('quiz-card')),
        matching: find.byIcon(Icons.close),
      ),
      findsNothing,
    );
    expect(_optionOpacity(tester, 0), 1);
    expect(_optionOpacity(tester, 1), lessThan(1));
    expect(_dontKnow(tester).onPressed, isNull);
    expect(_dontKnowOpacity(tester), lessThan(1));
    expect(skipped.pitches, isEmpty);
  });

  testWidgets('level controls rise after the result and then record', (
    tester,
  ) async {
    final progress = _QuizMemory()
      ..levels['setA'] = <int, StudyWordState>{
        0: StudyWordState(level: 4, dueAt: DateTime(2020)),
        1: StudyWordState(level: 1, dueAt: DateTime(2020)),
      };
    await openQuiz(
      tester,
      words: <VocabularyWord>[_kind, _haus],
      store: progress,
    );
    expect(find.byKey(const Key('set-study-easy')), findsNothing);

    await tester.tap(find.byKey(const Key('quiz-option-0')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 251));
    expect(find.byKey(const Key('set-study-easy')), findsOneWidget);
    expect(find.byKey(const Key('set-study-hard')), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.byKey(const Key('set-study-hard')));
    await tester.pump();
    expect(progress.saved, isEmpty);

    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('set-study-hard')));
    await tester.pumpAndSettle();
    expect(progress.saved.single.$3.level, 1);
    expect(
      tester.widget<Text>(find.byKey(const Key('quiz-term'))).data,
      'Haus',
    );
  });

  testWidgets('easy, familiar, studied, and skip follow flashcard', (
    tester,
  ) async {
    final easy = _QuizMemory()
      ..levels['setA'] = <int, StudyWordState>{
        0: StudyWordState(level: 1, dueAt: DateTime(2020)),
        1: StudyWordState(level: 1, dueAt: DateTime(2020)),
      };
    await openQuiz(tester, words: <VocabularyWord>[_kind, _haus], store: easy);
    await tester.tap(find.byKey(const Key('quiz-option-0')));
    await reveal(tester);
    await tester.tap(find.byKey(const Key('set-study-easy')));
    await tester.pumpAndSettle();
    expect(easy.saved.single.$3.level, 2);
    expect(
      tester.widget<Text>(find.byKey(const Key('quiz-term'))).data,
      'Haus',
    );

    final familiar = _QuizMemory()
      ..levels['setA'] = <int, StudyWordState>{
        0: StudyWordState(level: 4, dueAt: DateTime(2020)),
      };
    await openQuiz(tester, words: <VocabularyWord>[_kind], store: familiar);
    await tester.tap(find.byKey(const Key('quiz-option-0')));
    await reveal(tester);
    await tester.tap(find.byKey(const Key('set-study-familiar')));
    await tester.pumpAndSettle();
    expect(familiar.saved.single.$3.level, 4);
    expect(find.byKey(const Key('set-study-complete')), findsOneWidget);
    expect(find.byKey(const Key('quiz-term')), findsNothing);

    final fresh = _QuizMemory();
    await openQuiz(tester, words: <VocabularyWord>[_kind, _haus], store: fresh);
    await tester.tap(find.byKey(const Key('quiz-option-0')));
    await reveal(tester);
    expect(find.byKey(const Key('set-study-easy')), findsNothing);
    expect(find.text('Not yet studied'), findsOneWidget);
    expect(find.text('Studied'), findsOneWidget);
    await tester.tap(find.byKey(const Key('set-study-skip')));
    await tester.pumpAndSettle();
    expect(fresh.saved, isEmpty);
    expect(
      tester.widget<Text>(find.byKey(const Key('quiz-term'))).data,
      'Haus',
    );

    final studied = _QuizMemory();
    await openQuiz(tester, words: <VocabularyWord>[_kind], store: studied);
    await tester.tap(find.byKey(const Key('quiz-option-0')));
    await reveal(tester);
    await tester.tap(find.byKey(const Key('set-study-studied')));
    await tester.pumpAndSettle();
    expect(studied.saved.single.$3.level, 1);
    expect(find.byKey(const Key('set-study-complete')), findsOneWidget);
  });

  testWidgets('closing or leaving quiz before a rating keeps the level', (
    tester,
  ) async {
    final progress = _QuizMemory()
      ..levels['setA'] = <int, StudyWordState>{
        0: StudyWordState(level: 1, dueAt: DateTime(2020)),
      };
    await openQuiz(tester, words: <VocabularyWord>[_kind], store: progress);
    await tester.tap(find.byKey(const Key('quiz-option-0')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('set-study-mode-flashcard')));
    await tester.pumpAndSettle();
    expect(progress.saved, isEmpty);
    expect(find.text('Kind'), findsWidgets);
    expect(find.text('child'), findsNothing);

    await openQuiz(tester, words: <VocabularyWord>[_kind], store: progress);
    await tester.tap(find.byKey(const Key('quiz-option-0')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('set-study-practice-back')));
    await tester.pumpAndSettle();
    expect(progress.saved, isEmpty);
    expect(find.byKey(const Key('set-study-today-practice')), findsOneWidget);
  });

  testWidgets('disabled animations show the rating and still play the tone', (
    tester,
  ) async {
    final progress = _QuizMemory()
      ..levels['setA'] = <int, StudyWordState>{
        0: StudyWordState(level: 1, dueAt: DateTime(2020)),
      };
    final tone = await openQuiz(
      tester,
      words: <VocabularyWord>[_kind],
      store: progress,
      disableAnimations: true,
    );
    await tester.tap(find.byKey(const Key('quiz-option-0')));
    await tester.pump();
    expect(find.byKey(const Key('set-study-easy')), findsOneWidget);
    expect(tone.pitches, <QuizTonePitch>[QuizTonePitch.high]);
    await tester.tap(find.byKey(const Key('set-study-easy')));
    await tester.pump();
    expect(progress.saved.single.$3.level, 2);
  });

  testWidgets('finishing practice keeps every vocab word on the card preview', (
    tester,
  ) async {
    await prepare(tester);
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    final progress = _QuizMemory()
      ..levels['setA'] = <int, StudyWordState>{
        0: StudyWordState(level: 1, dueAt: DateTime(2020)),
      };
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SetStudyPage(
          set: VocabularySet(
            id: 'setA',
            title: 'German A1',
            description: '',
            words: <VocabularyWord>[_kind, _haus],
          ),
          onEdit: () {},
          progress: progress,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('set-study-today-practice')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('set-study-mode-flashcard')), findsOneWidget);
    await tester.tap(find.byKey(const Key('set-study-easy')));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('set-study-complete')), findsOneWidget);
    await tester.tap(find.byKey(const Key('set-study-practice-back')));
    await tester.pump();

    expect(find.byKey(const Key('set-study-word-0')), findsOneWidget);
    expect(find.byKey(const Key('set-study-word-1')), findsOneWidget);
    await tester.tap(find.byKey(const Key('set-study-next')));
    await tester.pump();
    expect(
      find.descendant(
        of: find.byKey(const Key('set-study-card')),
        matching: find.text('Haus'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('browse header stays fixed while the set page scrolls', (
    tester,
  ) async {
    await prepare(tester);
    final words = <VocabularyWord>[
      for (var index = 0; index < 20; index++)
        VocabularyWord(
          term: 'Word $index',
          definition: 'meaning $index',
          sentence: '',
          ipa: '',
          singularPlural: '',
          note: '',
        ),
    ];
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SetStudyPage(
          set: VocabularySet(
            id: 'setA',
            title: 'German A1',
            description: '',
            words: words,
          ),
          onEdit: () {},
          progress: _QuizMemory(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final practice = find.byKey(const Key('set-study-today-practice'));
    final learn = find.byKey(const Key('set-study-learn-new'));
    final card = find.byKey(const Key('set-study-word-12'));
    final practiceY = tester.getTopLeft(practice).dy;
    final learnY = tester.getTopLeft(learn).dy;
    final cardY = tester.getTopLeft(card).dy;

    await tester.drag(
      find.byKey(const Key('set-study-scroll')),
      const Offset(0, -280),
    );
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(practice).dy, practiceY);
    expect(tester.getTopLeft(learn).dy, learnY);
    expect(tester.getTopLeft(card).dy, lessThan(cardY));
  });
}

Finder _optionText(String fragment) {
  return find.descendant(
    of: find.byKey(const Key('quiz-card')),
    matching: find.textContaining(fragment),
  );
}

TextButton _dontKnow(WidgetTester tester) {
  return tester.widget<TextButton>(find.byKey(const Key('quiz-dont-know')));
}

double _dontKnowOpacity(WidgetTester tester) {
  final element = tester.element(find.byKey(const Key('quiz-dont-know')));
  return element.findAncestorWidgetOfExactType<Opacity>()!.opacity;
}

double _optionOpacity(WidgetTester tester, int index) {
  final element = tester.element(find.byKey(Key('quiz-option-$index')));
  return element.findAncestorWidgetOfExactType<Opacity>()!.opacity;
}

QuizOptionBorder _border(WidgetTester tester, int index) {
  return tester.widget<QuizOptionBorder>(
    find.descendant(
      of: find.byKey(Key('quiz-option-$index')),
      matching: find.byType(QuizOptionBorder),
    ),
  );
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

const _auto = VocabularyWord(
  term: 'Auto',
  definition: 'car',
  sentence: '',
  ipa: '',
  singularPlural: '',
  note: '',
);

const _baum = VocabularyWord(
  term: 'Baum',
  definition: 'tree',
  sentence: '',
  ipa: '',
  singularPlural: '',
  note: '',
);

const _bare = VocabularyWord(
  term: 'Bare',
  definition: 'child',
  sentence: '',
  ipa: '',
  singularPlural: '',
  note: '',
);

class _QuizMemory implements StudyProgressStore {
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
