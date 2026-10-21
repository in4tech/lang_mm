import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lang/library/vocabulary_library.dart';
import 'package:lang/library/vocabulary_set.dart';

enum StudyMark { hard, familiar, easy }

enum StudyAction { easy, familiar, hard, studied }

class StudyWordState {
  const StudyWordState({
    required this.level,
    required this.dueAt,
    this.keptOn,
  });

  final int level;
  final DateTime dueAt;

  /// Local date (`yyyy-MM-dd`) this word stays in Today practice.
  final String? keptOn;

  @override
  bool operator ==(Object other) {
    return other is StudyWordState &&
        other.level == level &&
        other.dueAt == dueAt &&
        other.keptOn == keptOn;
  }

  @override
  int get hashCode => Object.hash(level, dueAt, keptOn);
}

bool studyStaysToday(StudyWordState state, DateTime now) {
  if (state.keptOn == localStudyDate(now)) {
    return true;
  }
  return !state.dueAt.isAfter(now);
}

class StudyWordRef {
  const StudyWordRef({required this.setId, required this.index});

  final String setId;
  final int index;
}

class StudyCue {
  const StudyCue({
    required this.word,
    required this.setId,
    required this.index,
  });

  final VocabularyWord word;
  final String? setId;
  final int index;
}

class StudySetInput {
  const StudySetInput({
    required this.setId,
    required this.wordCount,
    this.marks = const <int, StudyMark>{},
    this.levels = const <int, StudyWordState>{},
  });

  final String setId;
  final int wordCount;
  final Map<int, StudyMark> marks;
  final Map<int, StudyWordState> levels;
}

class StudySetProgress {
  const StudySetProgress({
    required this.marks,
    this.levels = const <int, StudyWordState>{},
    this.updatedAt,
  });

  final Map<int, StudyMark> marks;
  final Map<int, StudyWordState> levels;
  final DateTime? updatedAt;
}

class StudyHomeData {
  const StudyHomeData({
    this.progress = const <String, StudySetProgress>{},
    this.agenda = const <StudyWordRef>[],
  });

  static const empty = StudyHomeData();

  final Map<String, StudySetProgress> progress;
  final List<StudyWordRef> agenda;
}

Duration studyDelay(int level) {
  return switch (level) {
    1 => const Duration(hours: 1),
    2 => const Duration(days: 1),
    3 => const Duration(days: 3),
    4 => const Duration(days: 7),
    5 => const Duration(days: 15),
    _ => const Duration(days: 30),
  };
}

StudyWordState? levelAfter({
  required StudyAction action,
  required int? level,
  required DateTime at,
}) {
  final next = switch (action) {
    StudyAction.easy => level == null ? null : (level >= 6 ? 6 : level + 1),
    StudyAction.familiar => level,
    StudyAction.hard => level == null ? null : 1,
    StudyAction.studied => 1,
  };
  if (next == null || next < 1 || next > 6) {
    return null;
  }
  return StudyWordState(level: next, dueAt: at.add(studyDelay(next)));
}

StudyWordState levelFromStoredMark(StudyMark mark, DateTime readAt) {
  final level = switch (mark) {
    StudyMark.hard => 2,
    StudyMark.familiar => 4,
    StudyMark.easy => 6,
  };
  return StudyWordState(level: level, dueAt: readAt);
}

String studyMarkValue(StudyMark mark) {
  return switch (mark) {
    StudyMark.hard => 'hard',
    StudyMark.familiar => 'familiar',
    StudyMark.easy => 'easy',
  };
}

StudyMark? studyMarkFromValue(Object? value) {
  return switch (value) {
    'hard' => StudyMark.hard,
    'familiar' => StudyMark.familiar,
    'easy' => StudyMark.easy,
    _ => null,
  };
}

String progressDocumentId(String ownerId, String setId) => '${ownerId}_$setId';

String localStudyDate(DateTime instant) {
  final local = instant.toLocal();
  final year = local.year.toString().padLeft(4, '0');
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

String agendaDocumentId(String ownerId, DateTime instant) {
  return '${ownerId}_${localStudyDate(instant)}';
}

Map<String, Object> recordStudyMark({
  required String ownerId,
  required String setId,
  required Map<String, Object>? existing,
  required int index,
  required StudyMark mark,
}) {
  final marks = <String, Object>{};
  final previous = existing?['marks'];
  if (previous is Map) {
    for (final entry in previous.entries) {
      final value = studyMarkFromValue(entry.value);
      if (value != null) {
        marks['${entry.key}'] = studyMarkValue(value);
      }
    }
  }
  marks['$index'] = studyMarkValue(mark);
  return <String, Object>{
    'ownerId': ownerId,
    'setId': setId,
    'marks': marks,
  };
}

List<StudyWordRef> choosePracticeQueue(
  List<StudySetInput> sets,
  DateTime now, {
  String? setId,
}) {
  final due = <({StudyWordRef ref, DateTime dueAt, int order})>[];
  final fresh = <StudyWordRef>[];
  var order = 0;
  for (final set in sets) {
    if (set.setId.isEmpty) {
      continue;
    }
    if (setId != null && set.setId != setId) {
      continue;
    }
    for (var index = 0; index < set.wordCount; index++) {
      final ref = StudyWordRef(setId: set.setId, index: index);
      final state = set.levels[index];
      order += 1;
      if (state == null) {
        fresh.add(ref);
      } else if (studyStaysToday(state, now)) {
        due.add((ref: ref, dueAt: state.dueAt, order: order));
      }
    }
  }
  due.sort((a, b) {
    final byTime = a.dueAt.compareTo(b.dueAt);
    if (byTime != 0) {
      return byTime;
    }
    return a.order.compareTo(b.order);
  });
  return <StudyWordRef>[
    for (final item in due) item.ref,
    ...fresh.take(8),
  ];
}

List<StudyWordRef> chooseDayList(List<StudySetInput> sets) {
  final hard = <StudyWordRef>[];
  final familiar = <StudyWordRef>[];
  final unmarked = <StudyWordRef>[];
  for (final set in sets) {
    if (set.setId.isEmpty) {
      continue;
    }
    for (var index = 0; index < set.wordCount; index++) {
      final ref = StudyWordRef(setId: set.setId, index: index);
      switch (set.marks[index]) {
        case StudyMark.hard:
          hard.add(ref);
        case StudyMark.familiar:
          familiar.add(ref);
        case StudyMark.easy:
          break;
        case null:
          unmarked.add(ref);
      }
    }
  }
  return <StudyWordRef>[...hard, ...familiar, ...unmarked].take(8).toList();
}

Map<int, StudyMark> marksFromDocument(Object? value) {
  if (value is! Map) {
    return const <int, StudyMark>{};
  }
  final marks = <int, StudyMark>{};
  for (final entry in value.entries) {
    final index = int.tryParse('${entry.key}');
    final mark = studyMarkFromValue(entry.value);
    if (index == null || mark == null) {
      continue;
    }
    marks[index] = mark;
  }
  return marks;
}

DateTime? studyDueAt(Object? value) {
  return switch (value) {
    DateTime due => due,
    Timestamp due => due.toDate(),
    String due => DateTime.tryParse(due),
    _ => null,
  };
}

Map<String, Object> studyLevelUpdate({
  required int index,
  required StudyWordState state,
}) {
  if (state.level < 1 || state.level > 6) {
    throw ArgumentError.value(state.level, 'level');
  }
  return <String, Object>{
    'words.$index': <String, Object>{
      'level': state.level,
      'dueAt': state.dueAt,
      if (state.keptOn != null) 'keptOn': state.keptOn!,
    },
  };
}

Map<String, Object> applyStudyLevelUpdate(
  Map<String, Object>? existing,
  Map<String, Object> update,
) {
  final next = <String, Object>{...?existing};
  for (final entry in update.entries) {
    final parts = entry.key.split('.');
    if (parts.length == 2 && parts[0] == 'words' && entry.value is Map) {
      final current = next['words'];
      final words = <String, Object>{
        if (current is Map)
          for (final word in current.entries) '${word.key}': word.value,
      };
      words[parts[1]] = entry.value;
      next['words'] = words;
    } else {
      next[entry.key] = entry.value;
    }
  }
  return next;
}

Map<int, StudyWordState> levelsFromDocument({
  Object? words,
  Object? marks,
  required DateTime readAt,
}) {
  final levels = <int, StudyWordState>{};
  if (words is Map) {
    for (final entry in words.entries) {
      final index = int.tryParse('${entry.key}');
      final value = entry.value;
      if (index == null || value is! Map) {
        continue;
      }
      final level = value['level'];
      final dueAt = studyDueAt(value['dueAt']);
      final keptOn = value['keptOn'];
      if (level is! int || level < 1 || level > 6 || dueAt == null) {
        continue;
      }
      levels[index] = StudyWordState(
        level: level,
        dueAt: dueAt,
        keptOn: keptOn is String && keptOn.isNotEmpty ? keptOn : null,
      );
    }
  }
  if (marks is Map) {
    for (final entry in marks.entries) {
      final index = int.tryParse('${entry.key}');
      final mark = studyMarkFromValue(entry.value);
      if (index == null || mark == null || levels.containsKey(index)) {
        continue;
      }
      levels[index] = levelFromStoredMark(mark, readAt);
    }
  }
  return levels;
}

List<StudyWordRef> agendaFromDocument(Object? value) {
  if (value is! List) {
    return const <StudyWordRef>[];
  }
  final words = <StudyWordRef>[];
  for (final item in value) {
    if (item is! Map) {
      continue;
    }
    final setId = item['setId'];
    final index = item['index'];
    if (setId is! String || setId.isEmpty || index is! int) {
      continue;
    }
    words.add(StudyWordRef(setId: setId, index: index));
  }
  return words;
}

abstract class StudyProgressStore {
  Future<StudyHomeData> loadHome(List<StudySetInput> sets);

  Future<Map<int, StudyMark>> marksFor(String setId);

  Future<Map<int, StudyWordState>> levelsFor(String setId);

  Future<void> rate({
    required String setId,
    required int index,
    required StudyMark mark,
  });

  Future<void> saveLevel({
    required String setId,
    required int index,
    required StudyWordState state,
  });
}

class FirestoreStudyProgressStore implements StudyProgressStore {
  FirestoreStudyProgressStore({
    required this.ownerId,
    FirebaseFirestore? firestore,
    DateTime Function()? clock,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _clock = clock ?? DateTime.now;

  final String ownerId;
  final FirebaseFirestore _firestore;
  final DateTime Function() _clock;

  @override
  Future<StudyHomeData> loadHome(List<StudySetInput> sets) async {
    final progressQuery = await _firestore
        .collection('progress')
        .where('ownerId', isEqualTo: ownerId)
        .get();
    final progress = <String, StudySetProgress>{};
    for (final document in progressQuery.docs) {
      final data = document.data();
      final setId = data['setId'];
      if (setId is! String || setId.isEmpty) {
        continue;
      }
      final updatedAt = data['updatedAt'];
      final readAt = _clock();
      progress[setId] = StudySetProgress(
        marks: marksFromDocument(data['marks']),
        levels: levelsFromDocument(
          words: data['words'],
          marks: data['marks'],
          readAt: readAt,
        ),
        updatedAt: updatedAt is Timestamp ? updatedAt.toDate() : null,
      );
    }
    final readAt = _clock();
    final inputs = <StudySetInput>[
      for (final set in sets)
        StudySetInput(
          setId: set.setId,
          wordCount: set.wordCount,
          levels: progress[set.setId]?.levels ?? const <int, StudyWordState>{},
        ),
    ];
    return StudyHomeData(
      progress: progress,
      agenda: choosePracticeQueue(inputs, readAt),
    );
  }

  @override
  Future<Map<int, StudyMark>> marksFor(String setId) async {
    final snapshot = await _firestore
        .collection('progress')
        .doc(progressDocumentId(ownerId, setId))
        .get();
    if (!snapshot.exists) {
      return const <int, StudyMark>{};
    }
    return marksFromDocument(snapshot.data()?['marks']);
  }

  @override
  Future<Map<int, StudyWordState>> levelsFor(String setId) async {
    final snapshot = await _firestore
        .collection('progress')
        .doc(progressDocumentId(ownerId, setId))
        .get();
    if (!snapshot.exists) {
      return const <int, StudyWordState>{};
    }
    final data = snapshot.data();
    return levelsFromDocument(
      words: data?['words'],
      marks: data?['marks'],
      readAt: _clock(),
    );
  }

  @override
  Future<void> saveLevel({
    required String setId,
    required int index,
    required StudyWordState state,
  }) async {
    final update = studyLevelUpdate(index: index, state: state);
    final reference = _firestore
        .collection('progress')
        .doc(progressDocumentId(ownerId, setId));
    final snapshot = await reference.get();
    if (!snapshot.exists) {
      final created = applyStudyLevelUpdate(<String, Object>{
        'ownerId': ownerId,
        'setId': setId,
      }, update);
      created['updatedAt'] = FieldValue.serverTimestamp();
      await reference.set(created);
      return;
    }
    await reference.update(<String, Object>{
      ...update,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> rate({
    required String setId,
    required int index,
    required StudyMark mark,
  }) {
    return _firestore
        .collection('progress')
        .doc(progressDocumentId(ownerId, setId))
        .set(<String, Object>{
          'ownerId': ownerId,
          'setId': setId,
          'marks': <String, Object>{'$index': studyMarkValue(mark)},
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }
}

List<StudySetInput> studySetsIn(VocabularyLibrary library) {
  final sets = <StudySetInput>[];
  for (final folder in library.folders) {
    for (var index = 0; index < folder.sets.length; index++) {
      final set = folder.contentAt(index);
      final id = set?.id;
      if (set == null || id == null || id.isEmpty) {
        continue;
      }
      sets.add(StudySetInput(setId: id, wordCount: set.words.length));
    }
  }
  return sets;
}
