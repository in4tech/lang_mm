import 'package:lang/library/vocabulary_library.dart';
import 'package:lang/library/vocabulary_set.dart';

Future<VocabularyLibrary> libraryForDevice({
  required VocabularyLibrary local,
  required Future<VocabularyLibrary> Function() readCloud,
  required VocabularySetStore store,
  Set<String> removedFolderIds = const <String>{},
}) async {
  final VocabularyLibrary cloud;
  try {
    cloud = await readCloud();
  } catch (_) {
    return local;
  }
  if (cloud.folders.isNotEmpty || cloud.unfiledSets.isNotEmpty) {
    return _withoutRemoved(cloud, removedFolderIds);
  }
  if (local.folders.isEmpty && local.unfiledSets.isEmpty) {
    return local;
  }
  try {
    return await _upload(store, local);
  } catch (_) {
    return local;
  }
}

VocabularyLibrary _withoutRemoved(
  VocabularyLibrary library,
  Set<String> removed,
) {
  if (removed.isEmpty) {
    return library;
  }
  final folders = <VocabularyFolder>[
    for (final folder in library.folders)
      if (folder.id == null || !removed.contains(folder.id)) folder,
  ];
  final editor = library.editorFolder;
  return VocabularyLibrary(
    editorFolder: folders.any((folder) => folder.name == editor) ? editor : null,
    folders: List<VocabularyFolder>.unmodifiable(folders),
    unfiledSets: library.unfiledSets,
  );
}

Future<VocabularyLibrary> _upload(
  VocabularySetStore store,
  VocabularyLibrary local,
) async {
  final folders = <VocabularyFolder>[];
  for (final folder in local.folders) {
    final editor = folder.name == local.editorFolder;
    final id = await store.createFolder(
      folder.name,
      editor: editor,
      pinned: folder.pinned,
    );
    final names = <String>[];
    final contents = <VocabularySet?>[];
    for (var index = 0; index < folder.sets.length; index++) {
      final content = folder.contentAt(index);
      if (content == null) {
        names.add(folder.sets[index]);
        contents.add(null);
        continue;
      }
      final stored = VocabularySet(
        title: content.title,
        description: content.description,
        words: content.words,
        folderId: id,
      );
      final setId = await store.save(stored);
      names.add(stored.title);
      contents.add(stored.withId(setId));
    }
    folders.add(
      VocabularyFolder(
        name: folder.name,
        id: id,
        pinned: folder.pinned,
        sets: List<String>.unmodifiable(names),
        contents: List<VocabularySet?>.unmodifiable(contents),
      ),
    );
  }
  final unfiled = <VocabularySet>[];
  for (final set in local.unfiledSets) {
    final id = await store.save(set);
    unfiled.add(set.withId(id));
  }
  return VocabularyLibrary(
    folders: List<VocabularyFolder>.unmodifiable(folders),
    unfiledSets: List<VocabularySet>.unmodifiable(unfiled),
    editorFolder: local.editorFolder,
  );
}
