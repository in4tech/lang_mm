import 'package:flutter/foundation.dart';

@immutable
class VocabularyFolder {
  const VocabularyFolder({required this.name, required this.sets});

  final String name;
  final List<String> sets;
}

@immutable
class VocabularyLibrary {
  const VocabularyLibrary({this.folders = const <VocabularyFolder>[]});

  static const empty = VocabularyLibrary();

  final List<VocabularyFolder> folders;
}
