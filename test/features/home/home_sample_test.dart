import 'package:flutter_test/flutter_test.dart';
import 'package:lang/features/home/sample/home_sample.dart';

void main() {
  const sample = HomeSample.current;

  test('German A1 statistics match the pictured sample', () {
    expect(sample.statisticsSetName, 'German A1 vocabulary');
    expect(sample.learnedFraction, '5/20');
    expect(sample.percent, 25);
    expect(sample.bars.map((bar) => bar.label).toList(), <String?>[
      '3',
      '2',
      null,
      null,
      null,
      null,
    ]);
    expect(sample.levels.map((level) => level.percent).toList(), <int>[
      0,
      0,
      0,
      0,
      25,
      75,
    ]);
  });

  test('today lists four identical pairs', () {
    expect(sample.today, hasLength(4));
    for (final row in sample.today) {
      expect(row.left.word, 'das Auto fahren');
      expect(row.left.form, 'das, -s');
      expect(row.right.word, 'die Frage verstehen');
      expect(row.right.form, 'die, -n');
    }
  });

  test('recent sets and sidebar selection match the picture', () {
    expect(sample.recent.map((set) => (set.name, set.percent)).toList(), [
      ('German A1 vocabulary', 25),
      ('A2 vocabulary', 50),
      ('German B1 vocabulary', 93),
      ('German B2 vocabulary', 93),
    ]);
    expect(sample.homepageSelected, isTrue);
    expect(sample.folders.first.name, 'My vocab');
    expect(sample.folders.first.expanded, isTrue);
    expect(sample.folders.first.sets, <String>[
      'German A1 vocabulary',
      'A2 vocabulary',
    ]);
    expect(sample.folders.last.name, 'My vocab 2');
    expect(sample.folders.last.expanded, isFalse);
    expect(sample.folders.last.sets, isEmpty);
  });
}
