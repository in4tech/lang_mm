import 'package:lang/features/home/sample/home_sample.dart';
import 'package:lang/library/vocabulary_library.dart';

HomeSample homeSampleFromLibrary(VocabularyLibrary library) {
  return HomeSample(
    statisticsSetName: '',
    learnedCount: 0,
    totalCount: 0,
    percent: 0,
    bars: const <HomeBar>[],
    levels: const <HomeLevel>[
      HomeLevel(color: HomeSample.mastered, percent: 0),
      HomeLevel(color: HomeSample.good, percent: 0),
      HomeLevel(color: HomeSample.familiar, percent: 0),
      HomeLevel(color: HomeSample.learning, percent: 0),
      HomeLevel(color: HomeSample.hard, percent: 0),
      HomeLevel(color: HomeSample.forgot, percent: 0),
    ],
    today: const <TodayRow>[],
    recent: const <RecentSet>[],
    homepageSelected: true,
    folders: <VocabFolder>[
      for (final folder in library.folders)
        VocabFolder(name: folder.name, expanded: true, sets: folder.sets),
    ],
  );
}
