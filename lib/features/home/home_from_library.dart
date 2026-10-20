import 'package:flutter/material.dart';
import 'package:lang/features/home/sample/home_sample.dart';
import 'package:lang/library/study_progress.dart';
import 'package:lang/library/vocabulary_library.dart';
import 'package:lang/library/vocabulary_set.dart';

int studyPercent(int count, int total) {
  if (total <= 0) {
    return 0;
  }
  return ((count * 100) / total).round();
}

Color studyProgressColor(int percent) {
  if (percent < 50) {
    return HomeSample.forgot;
  }
  if (percent < 90) {
    return HomeSample.learning;
  }
  return HomeSample.progressGreen;
}

Map<int, StudyWordState> studyStates(StudySetProgress? progress, DateTime now) {
  final levels = <int, StudyWordState>{
    if (progress != null) ...progress.levels,
  };
  if (progress == null) {
    return levels;
  }
  for (final entry in progress.marks.entries) {
    levels.putIfAbsent(
      entry.key,
      () => levelFromStoredMark(entry.value, now),
    );
  }
  return levels;
}

bool studyHasLevel(StudySetProgress? progress) {
  if (progress == null) {
    return false;
  }
  return progress.levels.isNotEmpty || progress.marks.isNotEmpty;
}

List<StudySetInput> studyInputs(
  VocabularyLibrary library,
  Map<String, StudySetProgress> progress,
  DateTime now,
) {
  final inputs = <StudySetInput>[];
  for (final folder in library.folders) {
    for (var index = 0; index < folder.sets.length; index++) {
      final set = folder.contentAt(index);
      final id = set?.id;
      if (set == null || id == null || id.isEmpty) {
        continue;
      }
      inputs.add(
        StudySetInput(
          setId: id,
          wordCount: set.words.length,
          levels: studyStates(progress[id], now),
        ),
      );
    }
  }
  return inputs;
}

HomeSample homeSampleFromLibrary(
  VocabularyLibrary library, {
  Map<String, StudySetProgress> progress = const <String, StudySetProgress>{},
  DateTime? now,
  bool allSets = true,
}) {
  final clock = now ?? DateTime.now();
  final sets = <VocabularySet>[
    for (final folder in library.folders)
      for (var index = 0; index < folder.sets.length; index++)
        if (folder.contentAt(index) != null) folder.contentAt(index)!,
  ];
  final marked = sets.where((set) {
    final id = set.id;
    if (id == null) {
      return false;
    }
    return studyHasLevel(progress[id]);
  }).toList();
  VocabularySet? focus;
  if (!allSets && marked.isNotEmpty) {
    marked.sort((a, b) {
      final aTime = progress[a.id]?.updatedAt;
      final bTime = progress[b.id]?.updatedAt;
      if (aTime == null && bTime == null) {
        return 0;
      }
      if (aTime == null) {
        return -1;
      }
      if (bTime == null) {
        return 1;
      }
      return aTime.compareTo(bTime);
    });
    focus = marked.last;
  }
  final scope = focus == null ? sets : <VocabularySet>[focus];
  final counts = _LevelCounts();
  if (marked.isNotEmpty) {
    for (final set in scope) {
      counts.add(set, studyStates(progress[set.id], clock));
    }
  }
  final today = _todayRows(
    library,
    choosePracticeQueue(studyInputs(library, progress, clock), clock),
  );
  final recent = _recent(marked, progress);
  return HomeSample(
    statisticsSetName: focus?.title ?? '',
    statisticsSetId: focus?.id,
    statisticsAll: allSets,
    learnedCount: counts.mastered,
    totalCount: marked.isEmpty ? 0 : counts.total,
    percent: studyPercent(counts.mastered, marked.isEmpty ? 0 : counts.total),
    bars: marked.isEmpty ? const <HomeBar>[] : counts.bars(),
    levels: counts.levels(marked.isEmpty ? 0 : counts.total),
    today: today,
    recent: recent,
    homepageSelected: true,
    folders: <VocabFolder>[
      for (final folder in library.folders)
        if (folder.pinned)
          VocabFolder(name: folder.name, expanded: false, sets: folder.sets),
    ],
  );
}

class _LevelCounts {
  final counts = List<int>.filled(6, 0);
  int total = 0;

  int get mastered => counts[5];

  void add(VocabularySet set, Map<int, StudyWordState> levels) {
    for (var index = 0; index < set.words.length; index++) {
      total += 1;
      final level = levels[index]?.level;
      if (level != null && level >= 1 && level <= 6) {
        counts[level - 1] += 1;
      }
    }
  }

  List<HomeLevel> levels(int total) {
    final colors = <Color>[
      HomeSample.forgot,
      HomeSample.hard,
      HomeSample.learning,
      HomeSample.familiar,
      HomeSample.good,
      HomeSample.mastered,
    ];
    return <HomeLevel>[
      for (var level = 6; level >= 1; level--)
        HomeLevel(
          color: colors[level - 1],
          percent: studyPercent(counts[level - 1], total),
        ),
    ];
  }

  List<HomeBar> bars() {
    HomeBar bar(Color color, int count) {
      return HomeBar(
        color: color,
        height: count * 28,
        label: count > 0 ? '$count' : null,
      );
    }

    final colors = <Color>[
      HomeSample.forgot,
      HomeSample.hard,
      HomeSample.learning,
      HomeSample.familiar,
      HomeSample.good,
      HomeSample.mastered,
    ];
    return <HomeBar>[
      for (var index = 0; index < counts.length; index++)
        bar(colors[index], counts[index]),
    ];
  }
}

int _masteredCount(VocabularySet set, Map<String, StudySetProgress> progress) {
  final states = studyStates(progress[set.id], DateTime.now());
  var count = 0;
  for (var index = 0; index < set.words.length; index++) {
    if (states[index]?.level == 6) {
      count += 1;
    }
  }
  return count;
}

List<TodayRow> _todayRows(VocabularyLibrary library, List<StudyWordRef> agenda) {
  final pairs = <VocabPair>[];
  for (final ref in agenda) {
    final word = _wordAt(library, ref);
    if (word == null) {
      continue;
    }
    pairs.add(VocabPair(word: word.term, form: word.singularPlural));
  }
  final rows = <TodayRow>[];
  for (var index = 0; index < pairs.length; index += 2) {
    final right = index + 1 < pairs.length
        ? pairs[index + 1]
        : const VocabPair(word: '', form: '');
    rows.add(TodayRow(left: pairs[index], right: right));
  }
  return rows;
}

List<RecentSet> _recent(
  List<VocabularySet> marked,
  Map<String, StudySetProgress> progress,
) {
  final ordered = <VocabularySet>[...marked];
  ordered.sort((a, b) {
    final aTime = progress[a.id]?.updatedAt;
    final bTime = progress[b.id]?.updatedAt;
    if (aTime == null && bTime == null) {
      return 0;
    }
    if (aTime == null) {
      return 1;
    }
    if (bTime == null) {
      return -1;
    }
    return bTime.compareTo(aTime);
  });
  return <RecentSet>[
    for (final set in ordered)
      RecentSet(
        id: set.id,
        name: set.title,
        percent: studyPercent(_masteredCount(set, progress), set.words.length),
        color: studyProgressColor(
          studyPercent(_masteredCount(set, progress), set.words.length),
        ),
      ),
  ];
}

VocabularyWord? _wordAt(VocabularyLibrary library, StudyWordRef ref) {
  for (final folder in library.folders) {
    for (var index = 0; index < folder.sets.length; index++) {
      final set = folder.contentAt(index);
      if (set?.id != ref.setId || set == null) {
        continue;
      }
      if (ref.index < 0 || ref.index >= set.words.length) {
        return null;
      }
      return set.words[ref.index];
    }
  }
  return null;
}

List<StudyCue> cuesForAgenda(
  VocabularyLibrary library,
  List<StudyWordRef> agenda,
) {
  final cues = <StudyCue>[];
  for (final ref in agenda) {
    final word = _wordAt(library, ref);
    if (word == null) {
      continue;
    }
    cues.add(StudyCue(word: word, setId: ref.setId, index: ref.index));
  }
  return cues;
}

List<VocabularyWord> statisticsWords({
  required VocabularyLibrary library,
  required Map<String, StudySetProgress> progress,
  required bool learned,
  bool allSets = true,
  String? setId,
  DateTime? now,
}) {
  final clock = now ?? DateTime.now();
  final words = <VocabularyWord>[];
  for (final set in _statisticsSets(
    library: library,
    allSets: allSets,
    setId: setId,
  )) {
    final levels = studyStates(progress[set.id], clock);
    for (var index = 0; index < set.words.length; index++) {
      final mastered = levels[index]?.level == 6;
      if (mastered == learned) {
        words.add(set.words[index]);
      }
    }
  }
  return words;
}

/// Words whose stored level equals [level] (1–6) in the statistics scope.
List<VocabularyWord> statisticsWordsAtLevel({
  required VocabularyLibrary library,
  required Map<String, StudySetProgress> progress,
  required int level,
  bool allSets = true,
  String? setId,
  DateTime? now,
}) {
  if (level < 1 || level > 6) {
    return const <VocabularyWord>[];
  }
  final clock = now ?? DateTime.now();
  final words = <VocabularyWord>[];
  for (final set in _statisticsSets(
    library: library,
    allSets: allSets,
    setId: setId,
  )) {
    final levels = studyStates(progress[set.id], clock);
    for (var index = 0; index < set.words.length; index++) {
      if (levels[index]?.level == level) {
        words.add(set.words[index]);
      }
    }
  }
  return words;
}

List<VocabularySet> _statisticsSets({
  required VocabularyLibrary library,
  required bool allSets,
  String? setId,
}) {
  if (!allSets) {
    if (setId == null) {
      return const <VocabularySet>[];
    }
    final set = setWithId(library, setId);
    return set == null ? const <VocabularySet>[] : <VocabularySet>[set];
  }
  final sets = <VocabularySet>[];
  for (final folder in library.folders) {
    for (var index = 0; index < folder.sets.length; index++) {
      final set = folder.contentAt(index);
      if (set != null) {
        sets.add(set);
      }
    }
  }
  return sets;
}

VocabularySet? setWithId(VocabularyLibrary library, String id) {
  for (final folder in library.folders) {
    for (var index = 0; index < folder.sets.length; index++) {
      final set = folder.contentAt(index);
      if (set?.id == id) {
        return set;
      }
    }
  }
  return null;
}
