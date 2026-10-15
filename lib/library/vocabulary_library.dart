import 'package:flutter/foundation.dart';
import 'package:lang/library/vocabulary_set.dart';

@immutable
class VocabularyFolder {
  const VocabularyFolder({
    required this.name,
    this.id,
    this.sets = const <String>[],
    this.contents = const <VocabularySet?>[],
  });

  final String name;
  final String? id;
  final List<String> sets;
  final List<VocabularySet?> contents;

  VocabularySet? contentAt(int index) {
    if (index < 0 || index >= contents.length) {
      return null;
    }
    return contents[index];
  }
}

@immutable
class VocabularyLibrary {
  const VocabularyLibrary({
    this.folders = const <VocabularyFolder>[],
    this.editorFolder,
  });

  static const empty = VocabularyLibrary();

  final List<VocabularyFolder> folders;
  final String? editorFolder;

  VocabularyLibrary addFolder(String name, {String? id}) {
    return VocabularyLibrary(
      folders: List<VocabularyFolder>.unmodifiable(<VocabularyFolder>[
        ...folders,
        VocabularyFolder(name: name, id: id),
      ]),
      editorFolder: editorFolder,
    );
  }

  VocabularyLibrary addSavedSet({
    required String name,
    required String folderLabel,
    VocabularySet? content,
    String? folderId,
  }) {
    final target = editorFolder ?? folderLabel;
    final folders = <VocabularyFolder>[];
    var found = false;
    for (final folder in this.folders) {
      if (folder.name == target) {
        found = true;
        folders.add(
          VocabularyFolder(
            name: folder.name,
            id: folder.id ?? folderId,
            sets: List<String>.unmodifiable(<String>[...folder.sets, name]),
            contents: List<VocabularySet?>.unmodifiable(<VocabularySet?>[
              ..._alignedContents(folder),
              content,
            ]),
          ),
        );
      } else {
        folders.add(folder);
      }
    }
    if (!found) {
      folders.add(
        VocabularyFolder(
          name: target,
          id: folderId,
          sets: List<String>.unmodifiable(<String>[name]),
          contents: List<VocabularySet?>.unmodifiable(<VocabularySet?>[
            content,
          ]),
        ),
      );
    }
    return VocabularyLibrary(
      folders: List<VocabularyFolder>.unmodifiable(folders),
      editorFolder: target,
    );
  }
}

class CloudFolderRecord {
  const CloudFolderRecord({
    required this.id,
    required this.name,
    required this.setIds,
    required this.editor,
    this.createdAt,
  });

  final String id;
  final String name;
  final List<String> setIds;
  final bool editor;
  final DateTime? createdAt;
}

class CloudSetRecord {
  const CloudSetRecord({required this.id, required this.set});

  final String id;
  final VocabularySet set;
}

VocabularyLibrary libraryFromCloud({
  required List<CloudFolderRecord> folders,
  required List<CloudSetRecord> sets,
}) {
  final setsById = <String, VocabularySet>{
    for (final record in sets) record.id: record.set,
  };
  final ordered = <CloudFolderRecord>[...folders]
    ..sort((a, b) {
      final aTime = a.createdAt;
      final bTime = b.createdAt;
      if (aTime == null && bTime == null) {
        return a.name.compareTo(b.name);
      }
      if (aTime == null) {
        return 1;
      }
      if (bTime == null) {
        return -1;
      }
      final byTime = aTime.compareTo(bTime);
      if (byTime != 0) {
        return byTime;
      }
      return a.name.compareTo(b.name);
    });
  String? editorFolder;
  final built = <VocabularyFolder>[];
  for (final folder in ordered) {
    if (folder.editor && editorFolder == null) {
      editorFolder = folder.name;
    }
    final names = <String>[];
    final contents = <VocabularySet?>[];
    final used = <String>{};
    for (final setId in folder.setIds) {
      final set = setsById[setId];
      if (set == null || set.folderId != folder.id) {
        continue;
      }
      used.add(setId);
      names.add(set.title);
      contents.add(set.withId(setId));
    }
    for (final record in sets) {
      if (used.contains(record.id) || record.set.folderId != folder.id) {
        continue;
      }
      names.add(record.set.title);
      contents.add(record.set.withId(record.id));
    }
    built.add(
      VocabularyFolder(
        name: folder.name,
        id: folder.id,
        sets: List<String>.unmodifiable(names),
        contents: List<VocabularySet?>.unmodifiable(contents),
      ),
    );
  }
  return VocabularyLibrary(
    folders: List<VocabularyFolder>.unmodifiable(built),
    editorFolder: editorFolder,
  );
}

List<VocabularySet?> _alignedContents(VocabularyFolder folder) {
  return <VocabularySet?>[
    for (var index = 0; index < folder.sets.length; index++)
      folder.contentAt(index),
  ];
}
