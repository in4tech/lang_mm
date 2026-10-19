import 'dart:convert';

import 'package:lang/library/vocabulary_library.dart';
import 'package:lang/library/vocabulary_set.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class VocabularyLibraryStore {
  static const storageKey = 'vocabulary_library';
  static const removedFoldersKey = 'vocabulary_library_removed_folders';

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
    final payload = <String, Object>{
      'folders': <Object>[
        for (final folder in library.folders)
          <String, Object>{
            'name': folder.name,
            if (folder.id != null) 'id': folder.id!,
            'pinned': folder.pinned,
            'sets': <Object>[
              for (var index = 0; index < folder.sets.length; index++)
                _storedSet(folder, index),
            ],
          },
      ],
    };
    final editorFolder = library.editorFolder;
    if (editorFolder != null) {
      payload['editorFolder'] = editorFolder;
    }
    return _preferences.setString(
      VocabularyLibraryStore.storageKey,
      jsonEncode(payload),
    );
  }

  Set<String> removedFolderIds() {
    return (_preferences.getStringList(
              VocabularyLibraryStore.removedFoldersKey,
            ) ??
            const <String>[])
        .toSet();
  }

  Future<void> rememberRemovedFolder(String id) async {
    final current =
        _preferences.getStringList(VocabularyLibraryStore.removedFoldersKey) ??
        <String>[];
    if (current.contains(id)) {
      return;
    }
    await _preferences.setStringList(
      VocabularyLibraryStore.removedFoldersKey,
      <String>[...current, id],
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
  final editorFolderValue = decoded['editorFolder'];
  if (editorFolderValue != null && editorFolderValue is! String) {
    return null;
  }
  final folders = <VocabularyFolder>[];
  for (final item in foldersValue) {
    if (item is! Map) {
      return null;
    }
    final name = item['name'];
    final setsValue = item['sets'];
    final id = item['id'];
    if (name is! String ||
        setsValue is! List ||
        (id != null && id is! String)) {
      return null;
    }
    final sets = <String>[];
    final contents = <VocabularySet?>[];
    for (final setName in setsValue) {
      if (setName is String) {
        sets.add(setName);
        contents.add(null);
        continue;
      }
      final stored = vocabularySetFromDocument(setName);
      if (stored == null) {
        return null;
      }
      sets.add(stored.title);
      contents.add(stored);
    }
    folders.add(
      VocabularyFolder(
        name: name,
        id: id is String ? id : null,
        pinned: item['pinned'] != false,
        sets: List<String>.unmodifiable(sets),
        contents: List<VocabularySet?>.unmodifiable(contents),
      ),
    );
  }
  return VocabularyLibrary(
    folders: List<VocabularyFolder>.unmodifiable(folders),
    editorFolder: editorFolderValue is String ? editorFolderValue : null,
  );
}

Object _storedSet(VocabularyFolder folder, int index) {
  final set = folder.contentAt(index);
  if (set == null) {
    return folder.sets[index];
  }
  final document = vocabularySetDocument(set);
  final id = set.id;
  if (id == null || id.isEmpty) {
    return document;
  }
  return <String, Object>{...document, 'id': id};
}

Future<VocabularyLibrary> loadVocabularyLibrary() async {
  try {
    final preferences = await SharedPreferences.getInstance();
    return await SharedPreferencesVocabularyLibraryStore(preferences).read();
  } catch (_) {
    return VocabularyLibrary.empty;
  }
}
