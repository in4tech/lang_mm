import 'package:flutter_test/flutter_test.dart';
import 'package:lang/features/home/home_from_library.dart';
import 'package:lang/library/study_progress.dart';
import 'package:lang/library/vocabulary_library.dart';
import 'package:lang/library/vocabulary_set.dart';

void main() {
  const kind = VocabularyWord(
    term: 'Kind',
    definition: 'child',
    sentence: 'Das Kind',
    ipa: 'kɪnt',
    singularPlural: '',
    note: '',
  );
  const haus = VocabularyWord(
    term: 'Haus',
    definition: 'house',
    sentence: 'Das Haus',
    ipa: 'haʊs',
    singularPlural: '',
    note: '',
  );
  const auto = VocabularyWord(
    term: 'Auto',
    definition: 'car',
    sentence: '',
    ipa: '',
    singularPlural: '',
    note: '',
  );

  final library = VocabularyLibrary(
    folders: <VocabularyFolder>[
      VocabularyFolder(
        name: 'My vocab',
        sets: <String>['German A1'],
        contents: <VocabularySet?>[
          VocabularySet(
            id: 'setA',
            title: 'German A1',
            description: '',
            words: <VocabularyWord>[kind, haus, auto],
          ),
        ],
      ),
    ],
  );

  final progress = <String, StudySetProgress>{
    'setA': StudySetProgress(
      marks: const <int, StudyMark>{},
      levels: <int, StudyWordState>{
        0: StudyWordState(level: 1, dueAt: DateTime(2020)),
        1: StudyWordState(level: 6, dueAt: DateTime(2020)),
      },
    ),
  };

  test('statisticsWordsAtLevel filters by level', () {
    expect(
      statisticsWordsAtLevel(
        library: library,
        progress: progress,
        level: 1,
        allSets: false,
        setId: 'setA',
      ).map((word) => word.term),
      <String>['Kind'],
    );
    expect(
      statisticsWordsAtLevel(
        library: library,
        progress: progress,
        level: 6,
        allSets: false,
        setId: 'setA',
      ).map((word) => word.term),
      <String>['Haus'],
    );
    expect(
      statisticsWordsAtLevel(
        library: library,
        progress: progress,
        level: 3,
        allSets: false,
        setId: 'setA',
      ),
      isEmpty,
    );
  });
}
