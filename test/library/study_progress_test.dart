import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lang/library/study_progress.dart';

void main() {
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

  test('progress and agenda rules belong to the signed-in user', () {
    final rules = File('firestore.rules').readAsStringSync();

    expect(rules, contains('match /progress/{progressId}'));
    expect(rules, contains('match /agenda/{agendaId}'));
    expect(rules, contains("request.auth.uid + '_' + request.resource.data.setId"));
    expect(rules, contains("request.auth.uid + '_' + request.resource.data.date"));
    expect(rules, contains("hasOnly(['hard', 'familiar', 'easy'])"));
    expect(rules, contains('resource.data.words.size() == 0'));
    expect(rules, contains('request.resource.data.words.size() <= 8'));
    expect(rules, contains('allow delete: if false;'));
    expect(rules, contains('match /sets/{setId}'));
    expect(rules, contains('match /folders/{folderId}'));
  });
}
