import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lang/library/vocabulary_library.dart';
import 'package:lang/library/vocabulary_set.dart';

enum StudyMark { hard, familiar, easy }

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
  });

  final String setId;
  final int wordCount;
  final Map<int, StudyMark> marks;
}

class StudySetProgress {
  const StudySetProgress({
    required this.marks,
    this.updatedAt,
  });

  final Map<int, StudyMark> marks;
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

  Future<void> rate({
    required String setId,
    required int index,
    required StudyMark mark,
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
      progress[setId] = StudySetProgress(
        marks: marksFromDocument(data['marks']),
        updatedAt: updatedAt is Timestamp ? updatedAt.toDate() : null,
      );
    }
    final agenda = await _agendaFor(sets, progress);
    return StudyHomeData(progress: progress, agenda: agenda);
  }

  Future<List<StudyWordRef>> _agendaFor(
    List<StudySetInput> sets,
    Map<String, StudySetProgress> progress,
  ) async {
    final instant = _clock();
    final date = localStudyDate(instant);
    final reference = _firestore.collection('agenda').doc(
      agendaDocumentId(ownerId, instant),
    );
    final snapshot = await reference.get();
    final inputs = <StudySetInput>[
      for (final set in sets)
        StudySetInput(
          setId: set.setId,
          wordCount: set.wordCount,
          marks: progress[set.setId]?.marks ?? set.marks,
        ),
    ];
    final chosen = chooseDayList(inputs);
    if (!snapshot.exists) {
      await reference.set(<String, Object>{
        'ownerId': ownerId,
        'date': date,
        'words': _wordMaps(chosen),
        'createdAt': FieldValue.serverTimestamp(),
      });
      return chosen;
    }
    final stored = agendaFromDocument(snapshot.data()?['words']);
    if (stored.isEmpty && chosen.isNotEmpty) {
      await reference.update(<String, Object>{'words': _wordMaps(chosen)});
      return chosen;
    }
    return stored;
  }

  List<Map<String, Object>> _wordMaps(List<StudyWordRef> words) {
    return <Map<String, Object>>[
      for (final word in words)
        <String, Object>{'setId': word.setId, 'index': word.index},
    ];
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
