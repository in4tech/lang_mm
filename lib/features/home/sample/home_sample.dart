import 'package:flutter/material.dart';

@immutable
class HomeBar {
  const HomeBar({required this.color, required this.height, this.label});

  final Color color;
  final double height;
  final String? label;
}

@immutable
class HomeLevel {
  const HomeLevel({required this.color, required this.percent});

  final Color color;
  final int percent;
}

@immutable
class VocabPair {
  const VocabPair({required this.word, required this.form});

  final String word;
  final String form;
}

@immutable
class TodayRow {
  const TodayRow({required this.left, required this.right});

  final VocabPair left;
  final VocabPair right;
}

@immutable
class RecentSet {
  const RecentSet({
    required this.name,
    required this.percent,
    required this.color,
    this.id,
  });

  final String name;
  final int percent;
  final Color color;
  final String? id;
}

@immutable
class VocabFolder {
  const VocabFolder({
    required this.name,
    required this.expanded,
    this.sets = const <String>[],
  });

  final String name;
  final bool expanded;
  final List<String> sets;
}

@immutable
class HomeSample {
  const HomeSample({
    required this.statisticsSetName,
    required this.learnedCount,
    required this.totalCount,
    required this.percent,
    required this.bars,
    required this.levels,
    required this.today,
    required this.recent,
    required this.homepageSelected,
    required this.folders,
  });

  static const Color forgot = Color(0xFFEE3C31);
  static const Color hard = Color(0xFFED5D1D);
  static const Color learning = Color(0xFFE7A00C);
  static const Color familiar = Color(0xFF5BBF1A);
  static const Color good = Color(0xFF16AA59);
  static const Color mastered = Color(0xFF474EE5);
  static const Color progressGreen = Color(0xFF37AA78);

  static const VocabPair autoFahren = VocabPair(
    word: 'das Auto fahren',
    form: 'das, -s',
  );
  static const VocabPair frageVerstehen = VocabPair(
    word: 'die Frage verstehen',
    form: 'die, -n',
  );

  static const HomeSample current = HomeSample(
    statisticsSetName: 'German A1 vocabulary',
    learnedCount: 5,
    totalCount: 20,
    percent: 25,
    bars: <HomeBar>[
      HomeBar(color: forgot, height: 141, label: '3'),
      HomeBar(color: hard, height: 102, label: '2'),
      HomeBar(color: learning, height: 5),
      HomeBar(color: familiar, height: 5),
      HomeBar(color: good, height: 5),
      HomeBar(color: mastered, height: 5),
    ],
    levels: <HomeLevel>[
      HomeLevel(color: mastered, percent: 0),
      HomeLevel(color: good, percent: 0),
      HomeLevel(color: familiar, percent: 0),
      HomeLevel(color: learning, percent: 0),
      HomeLevel(color: hard, percent: 25),
      HomeLevel(color: forgot, percent: 75),
    ],
    today: <TodayRow>[
      TodayRow(left: autoFahren, right: frageVerstehen),
      TodayRow(left: autoFahren, right: frageVerstehen),
      TodayRow(left: autoFahren, right: frageVerstehen),
      TodayRow(left: autoFahren, right: frageVerstehen),
    ],
    recent: <RecentSet>[
      RecentSet(name: 'German A1 vocabulary', percent: 25, color: forgot),
      RecentSet(name: 'A2 vocabulary', percent: 50, color: learning),
      RecentSet(
        name: 'German B1 vocabulary',
        percent: 93,
        color: progressGreen,
      ),
      RecentSet(
        name: 'German B2 vocabulary',
        percent: 93,
        color: progressGreen,
      ),
    ],
    homepageSelected: true,
    folders: <VocabFolder>[
      VocabFolder(
        name: 'My vocab',
        expanded: true,
        sets: <String>['German A1 vocabulary', 'A2 vocabulary'],
      ),
      VocabFolder(name: 'My vocab 2', expanded: false),
    ],
  );

  final String statisticsSetName;
  final int learnedCount;
  final int totalCount;
  final int percent;
  final List<HomeBar> bars;
  final List<HomeLevel> levels;
  final List<TodayRow> today;
  final List<RecentSet> recent;
  final bool homepageSelected;
  final List<VocabFolder> folders;

  String get learnedFraction => '$learnedCount/$totalCount';
}
