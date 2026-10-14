import 'package:flutter_test/flutter_test.dart';
import 'package:lang/library/vocabulary_set.dart';

void main() {
  VocabularyCardDraft card({
    String term = '',
    String definition = '',
    String sentence = '',
    String ipa = '',
    String singularPlural = '',
    String note = '',
    String? type,
    String? imageUrl,
  }) {
    return VocabularyCardDraft(
      term: term,
      definition: definition,
      sentence: sentence,
      ipa: ipa,
      singularPlural: singularPlural,
      note: note,
      type: type,
      imageUrl: imageUrl,
    );
  }

  Map<String, Object>? documentFor({
    String title = '',
    String description = '',
    required List<VocabularyCardDraft> cards,
  }) {
    final set = buildVocabularySet(
      title: title,
      description: description,
      cards: cards,
    );
    if (set == null) {
      return null;
    }
    return vocabularySetDocument(set);
  }

  Map<String, Object> wordAt(Map<String, Object> document, int index) {
    final words = document['words']! as List<Object>;
    return words[index] as Map<String, Object>;
  }

  test('a filled card becomes a document without an owner', () {
    final document = documentFor(
      title: 'German A1',
      description: 'Basics',
      cards: <VocabularyCardDraft>[
        card(
          term: 'Kind',
          definition: 'child',
          sentence: 'Das Kind',
          ipa: 'kɪnt',
          singularPlural: 'Kind - Kinder',
          note: 'noun',
          type: 'noun',
        ),
      ],
    );

    expect(document, isNotNull);
    expect(document!.containsKey('ownerId'), isFalse);
    expect(document['title'], 'German A1');
    expect(document['description'], 'Basics');
    expect(wordAt(document, 0), <String, Object>{
      'term': 'Kind',
      'definition': 'child',
      'sentence': 'Das Kind',
      'ipa': 'kɪnt',
      'singularPlural': 'Kind - Kinder',
      'note': 'noun',
      'type': 'noun',
    });
  });

  test('words stay in card number order', () {
    final document = documentFor(
      title: 'Home',
      cards: <VocabularyCardDraft>[
        card(term: 'Kind'),
        card(term: 'Haus'),
      ],
    );

    expect(wordAt(document!, 0)['term'], 'Kind');
    expect(wordAt(document, 1)['term'], 'Haus');
  });

  test('a blank card is left out', () {
    final document = documentFor(
      cards: <VocabularyCardDraft>[
        card(term: 'Kind'),
        card(),
      ],
    );

    final words = document!['words']! as List<Object>;
    expect(words, hasLength(1));
    expect(wordAt(document, 0)['term'], 'Kind');
  });

  test('a whitespace term produces no document', () {
    expect(
      documentFor(cards: <VocabularyCardDraft>[card(term: '   ')]),
      isNull,
    );
  });

  test('a blank title uses the first term', () {
    final document = documentFor(
      cards: <VocabularyCardDraft>[card(term: 'Kind')],
    );

    expect(document!['title'], 'Kind');
  });

  test('a whitespace title uses the first term', () {
    final document = documentFor(
      title: '   ',
      cards: <VocabularyCardDraft>[card(term: 'Kind')],
    );

    expect(document!['title'], 'Kind');
  });

  test('an image link is stored on the word', () {
    final document = documentFor(
      cards: <VocabularyCardDraft>[
        card(term: 'Kind', imageUrl: ' https://example.com/kind.jpg '),
      ],
    );

    expect(wordAt(document!, 0)['imageUrl'], 'https://example.com/kind.jpg');
  });

  test('a blank image link is omitted', () {
    final document = documentFor(
      cards: <VocabularyCardDraft>[card(term: 'Kind', imageUrl: '   ')],
    );

    expect(wordAt(document!, 0).containsKey('imageUrl'), isFalse);
  });

  test('a folder id is stored on the set', () {
    const set = VocabularySet(
      title: 'German A1',
      description: 'Basics',
      folderId: 'folder-1',
      words: <VocabularyWord>[
        VocabularyWord(
          term: 'Kind',
          definition: 'child',
          sentence: 'Das Kind',
          ipa: '',
          singularPlural: '',
          note: '',
        ),
      ],
    );

    final document = vocabularySetDocument(set);
    final loaded = vocabularySetFromDocument(document);

    expect(document['folderId'], 'folder-1');
    expect(loaded?.folderId, 'folder-1');
  });

  test('a missing type omits the type key', () {
    final document = documentFor(
      cards: <VocabularyCardDraft>[card(term: 'Kind')],
    );

    expect(wordAt(document!, 0).containsKey('type'), isFalse);
  });
}
