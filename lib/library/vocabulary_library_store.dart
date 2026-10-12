import 'dart:convert';

import 'package:lang/library/vocabulary_library.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class VocabularyLibraryStore {
  static const storageKey = 'vocabulary_library';

  Future<VocabularyLibrary> read();

  Future<void> write(VocabularyLibrary library);
}

class SharedPreferencesVocabularyLibraryStore
    implements VocabularyLibraryStore {
  SharedPreferencesVocabularyLibraryStore(this._preferences);

  final SharedPreferences _preferences;

  @override
  Future<VocabularyLibrary> read() async {
    final raw = _preferences.getString(VocabularyLibraryStore.storageKey);
    if (raw == null) {
      return VocabularyLibrary.empty;
    }
    return _decode(raw) ?? VocabularyLibrary.empty;
  }

  @override
  Future<void> write(VocabularyLibrary library) {
    return _preferences.setString(
      VocabularyLibraryStore.storageKey,
      jsonEncode(<String, Object>{
        'folders': <Object>[
          for (final folder in library.folders)
            <String, Object>{'name': folder.name, 'sets': folder.sets},
        ],
      }),
    );
  }
}

VocabularyLibrary? _decode(String raw) {
  final Object? decoded;
  try {
    decoded = jsonDecode(raw);
  } on FormatException {
    return null;
  }
  if (decoded is! Map) {
    return null;
  }
  final foldersValue = decoded['folders'];
  if (foldersValue is! List) {
    return null;
  }
  final folders = <VocabularyFolder>[];
  for (final item in foldersValue) {
    if (item is! Map) {
      return null;
    }
    final name = item['name'];
    final setsValue = item['sets'];
    if (name is! String || setsValue is! List) {
      return null;
    }
    final sets = <String>[];
    for (final setName in setsValue) {
      if (setName is! String) {
        return null;
      }
      sets.add(setName);
    }
    folders.add(
      VocabularyFolder(name: name, sets: List<String>.unmodifiable(sets)),
    );
  }
  return VocabularyLibrary(
    folders: List<VocabularyFolder>.unmodifiable(folders),
  );
}

Future<VocabularyLibrary> loadVocabularyLibrary() async {
  try {
    final preferences = await SharedPreferences.getInstance();
    return await SharedPreferencesVocabularyLibraryStore(preferences).read();
  } catch (_) {
    return VocabularyLibrary.empty;
  }
}
