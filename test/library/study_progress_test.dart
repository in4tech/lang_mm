import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lang/library/study_progress.dart';

void main() {
  final at = DateTime(2026, 10, 15, 15);

  test('easy raises a level and familiar keeps it', () {
    final raised = levelAfter(action: StudyAction.easy, level: 1, at: at);
    final stayed = levelAfter(action: StudyAction.familiar, level: 4, at: at);
    final topped = levelAfter(action: StudyAction.easy, level: 6, at: at);

    expect(raised, StudyWordState(level: 2, dueAt: at.add(const Duration(days: 1))));
    expect(levelAfter(action: StudyAction.easy, level: 2, at: at)?.dueAt, at.add(const Duration(days: 3)));
    expect(levelAfter(action: StudyAction.easy, level: 4, at: at)?.dueAt, at.add(const Duration(days: 15)));
    expect(stayed, StudyWordState(level: 4, dueAt: at.add(const Duration(days: 7))));
    expect(topped, StudyWordState(level: 6, dueAt: at.add(const Duration(days: 30))));
  });

  test('hard returns to level 1 and a studied new word starts there', () {
    final dropped = levelAfter(action: StudyAction.hard, level: 4, at: at);
    final studied = levelAfter(action: StudyAction.studied, level: null, at: at);

    expect(dropped, StudyWordState(level: 1, dueAt: at.add(const Duration(hours: 1))));
    expect(studied, StudyWordState(level: 1, dueAt: at.add(const Duration(hours: 1))));
    expect(levelAfter(action: StudyAction.easy, level: null, at: at), isNull);
    expect(levelAfter(action: StudyAction.hard, level: null, at: at), isNull);
    expect(levelAfter(action: StudyAction.familiar, level: null, at: at), isNull);
  });

  test('a due word precedes a new word and a future word is omitted', () {
    final now = DateTime(2026, 10, 15, 12);
    final list = choosePracticeQueue(<StudySetInput>[
      StudySetInput(
        setId: 'setA',
        wordCount: 3,
        levels: <int, StudyWordState>{
          0: StudyWordState(level: 2, dueAt: now),
          2: StudyWordState(level: 2, dueAt: now.add(const Duration(days: 1))),
        },
      ),
    ], now);

    expect(list.map((word) => word.index), <int>[0, 1]);
  });

  test('new words stop at eight', () {
    final list = choosePracticeQueue(const <StudySetInput>[
      StudySetInput(setId: 'setA', wordCount: 10),
    ], DateTime(2026, 10, 15));

    expect(list, hasLength(8));
    expect(list.last.index, 7);
  });

  test('the home queue starts with a due word from a later set', () {
    final now = DateTime(2026, 10, 15);
    final list = choosePracticeQueue(<StudySetInput>[
      const StudySetInput(setId: 'setA', wordCount: 1, levels: <int, StudyWordState>{}),
      StudySetInput(
        setId: 'setB',
        wordCount: 1,
        levels: <int, StudyWordState>{
          0: StudyWordState(level: 2, dueAt: now),
        },
      ),
    ], now, setId: null);

    expect(list.first.setId, 'setB');
    expect(list.first.index, 0);
    expect(list, hasLength(2));
  });

  test('a set queue ignores another set', () {
    final now = DateTime(2026, 10, 15);
    final list = choosePracticeQueue(<StudySetInput>[
      StudySetInput(
        setId: 'setB',
        wordCount: 1,
        levels: <int, StudyWordState>{
          0: StudyWordState(level: 1, dueAt: now),
        },
      ),
      const StudySetInput(setId: 'setA', wordCount: 1),
    ], now, setId: 'setA');

    expect(list.map((word) => word.setId), <String>['setA']);
  });

  test('a stored easy mark is read as level 6 and due now', () {
    final readAt = DateTime(2026, 10, 15, 9);

    expect(
      levelFromStoredMark(StudyMark.hard, readAt),
      StudyWordState(level: 2, dueAt: readAt),
    );
    expect(
      levelFromStoredMark(StudyMark.familiar, readAt),
      StudyWordState(level: 4, dueAt: readAt),
    );
    expect(
      levelFromStoredMark(StudyMark.easy, readAt),
      StudyWordState(level: 6, dueAt: readAt),
    );
  });

  test('easy replaces hard at position 0 of setA', () {
    final hard = recordStudyMark(
      ownerId: 'uid',
      setId: 'setA',
      existing: null,
      index: 0,
      mark: StudyMark.hard,
    );
    final easy = recordStudyMark(
      ownerId: 'uid',
      setId: 'setA',
      existing: hard,
      index: 0,
      mark: StudyMark.easy,
    );

    expect(easy['setId'], 'setA');
    expect(easy['marks'], <String, Object>{'0': 'easy'});
    expect(progressDocumentId('uid', 'setA'), 'uid_setA');
  });

  test('familiar is stored at position 1', () {
    final document = recordStudyMark(
      ownerId: 'uid',
      setId: 'setA',
      existing: null,
      index: 1,
      mark: StudyMark.familiar,
    );

    expect(document['marks'], <String, Object>{'1': 'familiar'});
  });

  test('hard Kind comes before unmarked Haus', () {
    final list = chooseDayList(<StudySetInput>[
      const StudySetInput(
        setId: 'setA',
        wordCount: 2,
        marks: <int, StudyMark>{0: StudyMark.hard},
      ),
    ]);

    expect(list.map((word) => word.index), <int>[0, 1]);
    expect(list.every((word) => word.setId == 'setA'), isTrue);
  });

  test('the ninth candidate is left out', () {
    final list = chooseDayList(const <StudySetInput>[
      StudySetInput(setId: 'setA', wordCount: 9),
    ]);

    expect(list, hasLength(8));
    expect(list.last.index, 7);
  });

  test('an easy word is left out', () {
    final list = chooseDayList(const <StudySetInput>[
      StudySetInput(
        setId: 'setA',
        wordCount: 2,
        marks: <int, StudyMark>{0: StudyMark.easy},
      ),
    ]);

    expect(list.map((word) => word.index), <int>[1]);
  });

  test('agenda ids use the signed-in uid and the local date', () {
    expect(
      agendaDocumentId('uid', DateTime(2026, 10, 14, 23)),
      'uid_2026-10-14',
    );
  });

  test('a second rating keeps the first word', () {
    final at = DateTime(2026, 10, 15, 15);
    final first = studyLevelUpdate(
      index: 0,
      state: StudyWordState(level: 2, dueAt: at),
    );
    final second = studyLevelUpdate(
      index: 1,
      state: StudyWordState(level: 4, dueAt: at.add(const Duration(days: 7))),
    );
    final document = applyStudyLevelUpdate(
      applyStudyLevelUpdate(<String, Object>{
        'ownerId': 'uid',
        'setId': 'setA',
        'marks': <String, Object>{'0': 'easy'},
      }, first),
      second,
    );
    final levels = levelsFromDocument(
      words: document['words'],
      marks: document['marks'],
      readAt: at,
    );

    expect(first.keys, <String>['words.0']);
    expect(levels[0], StudyWordState(level: 2, dueAt: at));
    expect(levels[1]!.level, 4);
  });

  test('a level outside 1 to 6 is refused before a write', () {
    expect(
      () => studyLevelUpdate(
        index: 0,
        state: StudyWordState(level: 0, dueAt: DateTime(2026, 10, 15)),
      ),
      throwsArgumentError,
    );
    expect(
      () => studyLevelUpdate(
        index: 0,
        state: StudyWordState(level: 7, dueAt: DateTime(2026, 10, 15)),
      ),
      throwsArgumentError,
    );
  });

  test('progress and agenda rules belong to the signed-in user', () {
    final rules = File('firestore.rules').readAsStringSync();

    expect(rules, contains('match /progress/{progressId}'));
    expect(rules, contains('match /agenda/{agendaId}'));
    expect(rules, contains("request.auth.uid + '_' + request.resource.data.setId"));
    expect(rules, contains("request.auth.uid + '_' + request.resource.data.date"));
    expect(rules, contains("hasOnly(['hard', 'familiar', 'easy'])"));
    expect(rules, contains("hasOnly(['marks', 'words', 'updatedAt'])"));
    expect(rules, contains('request.resource.data.words is map'));
    expect(rules, contains('resource.data.words.size() == 0'));
    expect(rules, contains('request.resource.data.words.size() <= 8'));
    expect(rules, contains('allow delete: if false;'));
    expect(rules, contains('match /sets/{setId}'));
    expect(rules, contains('match /folders/{folderId}'));
  });
}
