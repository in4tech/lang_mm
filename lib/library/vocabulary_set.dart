import 'package:flutter/foundation.dart';

@immutable
class VocabularyCardDraft {
  const VocabularyCardDraft({
    required this.term,
    required this.definition,
    required this.sentence,
    required this.ipa,
    required this.singularPlural,
    required this.note,
    this.type,
    this.imageUrl,
  });

  final String term;
  final String definition;
  final String sentence;
  final String ipa;
  final String singularPlural;
  final String note;
  final String? type;
  final String? imageUrl;
}

@immutable
class VocabularyWord {
  const VocabularyWord({
    required this.term,
    required this.definition,
    required this.sentence,
    required this.ipa,
    required this.singularPlural,
    required this.note,
    this.type,
    this.imageUrl,
    this.starred = false,
  });

  final String term;
  final String definition;
  final String sentence;
  final String ipa;
  final String singularPlural;
  final String note;
  final String? type;
  final String? imageUrl;
  final bool starred;

  VocabularyWord copyWith({bool? starred}) {
    return VocabularyWord(
      term: term,
      definition: definition,
      sentence: sentence,
      ipa: ipa,
      singularPlural: singularPlural,
      note: note,
      type: type,
      imageUrl: imageUrl,
      starred: starred ?? this.starred,
    );
  }
}

@immutable
class VocabularySet {
  const VocabularySet({
    required this.title,
    required this.description,
    required this.words,
    this.folderId,
    this.id,
  });

  final String title;
  final String description;
  final List<VocabularyWord> words;
  final String? folderId;
  final String? id;

  VocabularySet withId(String id) {
    return VocabularySet(
      id: id,
      title: title,
      description: description,
      words: words,
      folderId: folderId,
    );
  }
}

String? _keptImage(String? imageUrl) {
  final trimmed = imageUrl?.trim() ?? '';
  if (trimmed.isEmpty) {
    return null;
  }
  return trimmed;
}

abstract class VocabularySetStore {
  Future<String> save(VocabularySet set);

  Future<void> addSetToFolder(String folderId, String setId) async {}

  Future<void> updateWords(VocabularySet set) async {}

  Future<String> createFolder(
    String name, {
    bool editor = false,
    bool pinned = true,
  });

  Future<void> renameFolder(String id, String name) async {}

  Future<void> deleteFolder(String id) async {}

  Future<void> setFolderPinned(String id, bool pinned) async {}
}

VocabularySet? buildVocabularySet({
  required String title,
  required String description,
  required List<VocabularyCardDraft> cards,
}) {
  final words = <VocabularyWord>[];
  for (final card in cards) {
    final term = card.term.trim();
    if (term.isEmpty) {
      continue;
    }
    words.add(
      VocabularyWord(
        term: term,
        definition: card.definition,
        sentence: card.sentence,
        ipa: card.ipa,
        singularPlural: card.singularPlural,
        note: card.note,
        type: card.type,
        imageUrl: _keptImage(card.imageUrl),
      ),
    );
  }
  if (words.isEmpty) {
    return null;
  }
  final trimmedTitle = title.trim();
  return VocabularySet(
    title: trimmedTitle.isEmpty ? words.first.term : trimmedTitle,
    description: description,
    words: List<VocabularyWord>.unmodifiable(words),
  );
}

VocabularySet? vocabularySetFromDocument(Object? value) {
  if (value is! Map) {
    return null;
  }
  final title = value['title'];
  final description = value['description'];
  final wordsValue = value['words'];
  final folderId = value['folderId'];
  final id = value['id'];
  if (title is! String ||
      description is! String ||
      wordsValue is! List ||
      (folderId != null && folderId is! String) ||
      (id != null && id is! String)) {
    return null;
  }
  final words = <VocabularyWord>[];
  for (final item in wordsValue) {
    if (item is! Map) {
      return null;
    }
    final term = item['term'];
    final definition = item['definition'];
    final sentence = item['sentence'];
    final ipa = item['ipa'];
    final singularPlural = item['singularPlural'];
    final note = item['note'];
    final type = item['type'];
    final imageUrl = item['imageUrl'];
    final starred = item['starred'];
    if (term is! String ||
        definition is! String ||
        sentence is! String ||
        ipa is! String ||
        singularPlural is! String ||
        note is! String ||
        (type != null && type is! String) ||
        (imageUrl != null && imageUrl is! String) ||
        (starred != null && starred is! bool)) {
      return null;
    }
    words.add(
      VocabularyWord(
        term: term,
        definition: definition,
        sentence: sentence,
        ipa: ipa,
        singularPlural: singularPlural,
        note: note,
        type: type is String ? type : null,
        imageUrl: imageUrl is String ? imageUrl : null,
        starred: starred == true,
      ),
    );
  }
  return VocabularySet(
    title: title,
    description: description,
    words: List<VocabularyWord>.unmodifiable(words),
    folderId: folderId is String ? folderId : null,
    id: id is String && id.isNotEmpty ? id : null,
  );
}

Map<String, Object> vocabularySetDocument(VocabularySet set) {
  return <String, Object>{
    'title': set.title,
    'description': set.description,
    if (set.folderId != null) 'folderId': set.folderId!,
    'words': <Object>[
      for (final word in set.words)
        <String, Object>{
          'term': word.term,
          'definition': word.definition,
          'sentence': word.sentence,
          'ipa': word.ipa,
          'singularPlural': word.singularPlural,
          'note': word.note,
          if (word.type != null) 'type': word.type!,
          if (word.imageUrl != null) 'imageUrl': word.imageUrl!,
          if (word.starred) 'starred': true,
        },
    ],
  };
}
