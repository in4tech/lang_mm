import 'package:flutter_test/flutter_test.dart';
import 'package:lang/features/home/typing_answer.dart';

void main() {
  group('blankTermInSentence', () {
    test('blanks multiple whole-word matches case-insensitively', () {
      expect(
        blankTermInSentence(
          'I memorize five words; I also Memorize daily.',
          'memorize',
        ),
        'I --- five words; I also --- daily.',
      );
    });

    test('leaves a sentence without the term unchanged', () {
      expect(blankTermInSentence('Guten Tag', 'Kind'), 'Guten Tag');
    });

    test('does not blank a longer word that only starts with the term', () {
      expect(
        blankTermInSentence('I memorized five words.', 'memorize'),
        'I memorized five words.',
      );
    });

    test('blanks Kind inside a German sentence', () {
      expect(
        blankTermInSentence('Das Kind schläft', 'Kind'),
        'Das --- schläft',
      );
    });
  });

  group('typingAnswerMatches', () {
    test('accepts lowercase and spaced input', () {
      expect(typingAnswerMatches('kind', 'Kind'), isTrue);
      expect(typingAnswerMatches(' Kind ', 'Kind'), isTrue);
      expect(typingAnswerMatches('KIND', 'Kind'), isTrue);
    });

    test('rejects a different term', () {
      expect(typingAnswerMatches('Haus', 'Kind'), isFalse);
      expect(typingAnswerMatches('kin', 'Kind'), isFalse);
      expect(typingAnswerMatches('', 'Kind'), isFalse);
    });
  });
}
