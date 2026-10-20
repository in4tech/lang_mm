import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lang/features/home/quiz_tone.dart';
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

  Future<void> openRandom(
    WidgetTester tester, {
    required List<VocabularyWord> words,
    required List<PracticeExercise> draws,
    Map<int, StudyWordState>? levels,
    bool disableAnimations = false,
  }) async {
    await prepare(tester);
    if (disableAnimations) {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
    }
    final progress = _MemoryProgress();
    if (levels != null) {
      progress.levels['setA'] = levels;
    }
    var drawAt = 0;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SetStudyPage(
            key: UniqueKey(),
            set: VocabularySet(
              id: 'setA',
              title: 'German A1',
              description: '',
              words: words,
            ),
            onEdit: () {},
            progress: progress,
            quizTone: RecordingQuizTone(),
            drawExercise: () {
              final next = draws[drawAt.clamp(0, draws.length - 1)];
              if (drawAt < draws.length - 1) {
                drawAt += 1;
              }
              return next;
            },
            cues: <StudyCue>[
              for (var index = 0; index < words.length; index++)
                StudyCue(word: words[index], setId: 'setA', index: index),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('set-study-mode-random')));
    await tester.pumpAndSettle();
  }

  testWidgets('random forced quiz then typing across two words', (tester) async {
    await openRandom(
      tester,
      words: <VocabularyWord>[_kind, _haus],
      draws: <PracticeExercise>[
        PracticeExercise.quiz,
        PracticeExercise.typing,
      ],
      levels: <int, StudyWordState>{
        0: StudyWordState(level: 1, dueAt: DateTime(2020)),
        1: StudyWordState(level: 1, dueAt: DateTime(2020)),
      },
      disableAnimations: true,
    );

    expect(find.text('Choose an answer'), findsOneWidget);
    expect(find.byKey(const Key('set-study-next')), findsNothing);
    expect(find.byKey(const Key('set-study-prev')), findsNothing);

    await tester.tap(find.byKey(const Key('quiz-option-0')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('set-study-easy')));
    await tester.pumpAndSettle();

    expect(find.text('Your answer'), findsOneWidget);
    expect(find.text('Choose an answer'), findsNothing);
  });

  testWidgets('random forced flashcard flips and rates', (tester) async {
    await openRandom(
      tester,
      words: <VocabularyWord>[_kind, _haus],
      draws: <PracticeExercise>[
        PracticeExercise.flashcard,
        PracticeExercise.flashcard,
      ],
      levels: <int, StudyWordState>{
        0: StudyWordState(level: 1, dueAt: DateTime(2020)),
        1: StudyWordState(level: 1, dueAt: DateTime(2020)),
      },
      disableAnimations: true,
    );

    expect(find.text('child'), findsNothing);
    await tester.tap(find.byKey(const Key('set-study-card-tap')));
    await tester.pumpAndSettle();
    expect(find.text('child'), findsOneWidget);
    await tester.tap(find.byKey(const Key('set-study-easy')));
    await tester.pumpAndSettle();
    expect(find.text('Haus'), findsOneWidget);
  });

  testWidgets('leaving random for quiz is fixed quiz', (tester) async {
    await openRandom(
      tester,
      words: <VocabularyWord>[_kind, _haus],
      draws: <PracticeExercise>[PracticeExercise.flashcard],
      levels: <int, StudyWordState>{
        0: StudyWordState(level: 1, dueAt: DateTime(2020)),
      },
      disableAnimations: true,
    );

    await tester.tap(find.byKey(const Key('set-study-mode-quiz')));
    await tester.pumpAndSettle();
    expect(find.text('Choose an answer'), findsOneWidget);
  });

  testWidgets('choosing random again redraws', (tester) async {
    await openRandom(
      tester,
      words: <VocabularyWord>[_kind],
      draws: <PracticeExercise>[
        PracticeExercise.flashcard,
        PracticeExercise.quiz,
      ],
      levels: <int, StudyWordState>{
        0: StudyWordState(level: 1, dueAt: DateTime(2020)),
      },
      disableAnimations: true,
    );
    expect(find.text('Choose an answer'), findsNothing);

    await tester.tap(find.byKey(const Key('set-study-mode-quiz')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('set-study-mode-random')));
    await tester.pumpAndSettle();
    expect(find.text('Choose an answer'), findsOneWidget);
  });
}

class _MemoryProgress implements StudyProgressStore {
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
    levels.putIfAbsent(setId, () => <int, StudyWordState>{})[index] = state;
  }
}

const _kind = VocabularyWord(
  term: 'Kind',
  definition: 'child',
  sentence: 'Das Kind',
  ipa: 'kɪnt',
  singularPlural: 'das, -er',
  note: 'noun',
  type: 'noun',
);

const _haus = VocabularyWord(
  term: 'Haus',
  definition: 'house',
  sentence: 'Das Haus',
  ipa: 'haʊs',
  singularPlural: 'das, -̈er',
  note: 'noun',
  type: 'noun',
);
