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

HomeSample homeSampleFromLibrary(
  VocabularyLibrary library, {
  Map<String, StudySetProgress> progress = const <String, StudySetProgress>{},
  List<StudyWordRef> agenda = const <StudyWordRef>[],
  bool allSets = true,
}) {
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
    return progress[id]?.marks.isNotEmpty ?? false;
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
      counts.add(set, progress[set.id]?.marks ?? const <int, StudyMark>{});
    }
  }
  final today = _todayRows(library, agenda);
  final recent = _recent(marked, progress);
  return HomeSample(
    statisticsSetName: focus?.title ?? '',
    learnedCount: counts.easy,
    totalCount: marked.isEmpty ? 0 : counts.total,
    percent: studyPercent(counts.easy, marked.isEmpty ? 0 : counts.total),
    bars: marked.isEmpty ? const <HomeBar>[] : counts.bars(),
    levels: counts.levels(marked.isEmpty ? 0 : counts.total),
    today: today,
    recent: recent,
    homepageSelected: true,
    folders: <VocabFolder>[
      for (final folder in library.folders)
        VocabFolder(name: folder.name, expanded: false, sets: folder.sets),
    ],
  );
}

class _LevelCounts {
  int easy = 0;
  int familiar = 0;
  int hard = 0;
  int unmarked = 0;
  int total = 0;

  void add(VocabularySet set, Map<int, StudyMark> marks) {
    for (var index = 0; index < set.words.length; index++) {
      total += 1;
      switch (marks[index]) {
        case StudyMark.easy:
          easy += 1;
        case StudyMark.familiar:
          familiar += 1;
        case StudyMark.hard:
          hard += 1;
        case null:
          unmarked += 1;
      }
    }
  }

  List<HomeLevel> levels(int total) {
    return <HomeLevel>[
      HomeLevel(color: HomeSample.mastered, percent: studyPercent(easy, total)),
      const HomeLevel(color: HomeSample.good, percent: 0),
      HomeLevel(
        color: HomeSample.familiar,
        percent: studyPercent(familiar, total),
      ),
      const HomeLevel(color: HomeSample.learning, percent: 0),
      HomeLevel(color: HomeSample.hard, percent: studyPercent(hard, total)),
      HomeLevel(
        color: HomeSample.forgot,
        percent: studyPercent(unmarked, total),
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

    return <HomeBar>[
      bar(HomeSample.forgot, unmarked),
      bar(HomeSample.hard, hard),
      bar(HomeSample.learning, 0),
      bar(HomeSample.familiar, familiar),
      bar(HomeSample.good, 0),
      bar(HomeSample.mastered, easy),
    ];
  }
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
        percent: studyPercent(
          (progress[set.id]?.marks.values ?? const <StudyMark>[])
              .where((mark) => mark == StudyMark.easy)
              .length,
          set.words.length,
        ),
        color: studyProgressColor(
          studyPercent(
            (progress[set.id]?.marks.values ?? const <StudyMark>[])
                .where((mark) => mark == StudyMark.easy)
                .length,
            set.words.length,
          ),
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
