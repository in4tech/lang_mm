import 'package:flutter_test/flutter_test.dart';
import 'package:lang/library/device_library.dart';
import 'package:lang/library/vocabulary_library.dart';
import 'package:lang/library/vocabulary_set.dart';

void main() {
  const word = VocabularyWord(
    term: 'Kind',
    definition: 'child',
    sentence: 'Das Kind',
    ipa: '',
    singularPlural: '',
    note: '',
  );

  test('debug reads the fixed owner and release reads the signed-in owner', () {
    expect(
      ownerIdForLibraryRead(debugMode: true, signedInOwnerId: 'other'),
      debugLibraryOwnerId,
    );
    expect(
      ownerIdForLibraryRead(debugMode: false, signedInOwnerId: 'signed-in'),
      'signed-in',
    );
  });

  test('cloud documents rebuild the library for this device', () {
    final library = libraryFromCloud(
      folders: <CloudFolderRecord>[
        CloudFolderRecord(
          id: 'folder-b',
          name: 'Travel',
          setIds: const <String>['set-2'],
          editor: false,
          createdAt: DateTime.utc(2026, 2, 1),
        ),
        CloudFolderRecord(
          id: 'folder-a',
          name: 'Your vocabulary set',
          setIds: const <String>['set-1', 'missing'],
          editor: true,
          createdAt: DateTime.utc(2026, 1, 1),
        ),
      ],
      sets: <CloudSetRecord>[
        CloudSetRecord(
          id: 'set-1',
          set: const VocabularySet(
            title: 'German A1',
            description: 'basics',
            folderId: 'folder-a',
            words: <VocabularyWord>[word],
          ),
        ),
        CloudSetRecord(
          id: 'set-2',
          set: const VocabularySet(
            title: 'Airport',
            description: '',
            folderId: 'folder-b',
            words: <VocabularyWord>[word],
          ),
        ),
        CloudSetRecord(
          id: 'set-3',
          set: const VocabularySet(
            title: 'Extra',
            description: '',
            folderId: 'folder-a',
            words: <VocabularyWord>[word],
          ),
        ),
      ],
    );

    expect(library.editorFolder, 'Your vocabulary set');
    expect(library.folders.map((folder) => folder.name), <String>[
      'Your vocabulary set',
      'Travel',
    ]);
    expect(library.folders.first.id, 'folder-a');
    expect(library.folders.first.sets, <String>['German A1', 'Extra']);
    expect(library.folders.first.contentAt(0)?.folderId, 'folder-a');
    expect(library.folders[1].sets, <String>['Airport']);
  });

  test('an empty device keeps the empty local library', () async {
    const local = VocabularyLibrary.empty;

    final library = await libraryForDevice(
      local: local,
      readCloud: () async => VocabularyLibrary.empty,
      store: _Store(),
    );

    expect(identical(library, local), isTrue);
  });

  test('an empty cloud uploads the local library', () async {
    const local = VocabularyLibrary(
      folders: <VocabularyFolder>[VocabularyFolder(name: 'Travel')],
    );
    final store = _Store();

    final library = await libraryForDevice(
      local: local,
      readCloud: () async => VocabularyLibrary.empty,
      store: store,
    );

    expect(identical(library, local), isFalse);
    expect(library.folders.single.id, 'folder-1');
    expect(store.created, <(String, bool)>[('Travel', false)]);
  });

  test('a cloud library replaces the local copy', () async {
    const local = VocabularyLibrary(
      folders: <VocabularyFolder>[VocabularyFolder(name: 'Old')],
    );
    const cloud = VocabularyLibrary(
      editorFolder: 'Your vocabulary set',
      folders: <VocabularyFolder>[
        VocabularyFolder(name: 'Your vocabulary set', id: 'folder-9'),
      ],
    );
    final store = _Store();

    final library = await libraryForDevice(
      local: local,
      readCloud: () async => cloud,
      store: store,
    );

    expect(library.folders.single.id, 'folder-9');
    expect(store.created, isEmpty);
    expect(store.saved, isEmpty);
  });

  test('a cloud library keeps a local unpin', () async {
    const local = VocabularyLibrary(
      folders: <VocabularyFolder>[
        VocabularyFolder(name: 'Travel', id: 'folder-9', pinned: false),
      ],
    );
    const cloud = VocabularyLibrary(
      folders: <VocabularyFolder>[
        VocabularyFolder(name: 'Travel', id: 'folder-9'),
      ],
    );

    final library = await libraryForDevice(
      local: local,
      readCloud: () async => cloud,
      store: _Store(),
    );

    expect(library.folders.single.pinned, isFalse);
  });

  test('a removed folder stays out of the cloud library', () async {
    const cloud = VocabularyLibrary(
      editorFolder: 'Travel',
      folders: <VocabularyFolder>[
        VocabularyFolder(name: 'Travel', id: 'folder-9'),
        VocabularyFolder(name: 'Kitchen', id: 'folder-2'),
      ],
    );

    final library = await libraryForDevice(
      local: VocabularyLibrary.empty,
      readCloud: () async => cloud,
      store: _Store(),
      removedFolderIds: const <String>{'folder-9'},
    );

    expect(library.folders.single.name, 'Kitchen');
    expect(library.editorFolder, isNull);
  });

  test('a failed cloud read keeps the local library', () async {
    const local = VocabularyLibrary(
      folders: <VocabularyFolder>[VocabularyFolder(name: 'Travel')],
    );

    final library = await libraryForDevice(
      local: local,
      readCloud: () async => throw Exception('offline'),
      store: _Store(),
    );

    expect(identical(library, local), isTrue);
  });

  test('local sets are copied under the device account', () async {
    final local = VocabularyLibrary(
      editorFolder: 'Your vocabulary set',
      folders: <VocabularyFolder>[
        VocabularyFolder(
          name: 'Your vocabulary set',
          sets: const <String>['German A1'],
          contents: const <VocabularySet?>[
            VocabularySet(
              title: 'German A1',
              description: 'basics',
              words: <VocabularyWord>[word],
            ),
          ],
        ),
      ],
    );
    final store = _Store();

    final library = await libraryForDevice(
      local: local,
      readCloud: () async => VocabularyLibrary.empty,
      store: store,
    );

    expect(store.created, <(String, bool)>[('Your vocabulary set', true)]);
    expect(store.saved.single.folderId, 'folder-1');
    expect(store.saved.single.title, 'German A1');
    expect(library.editorFolder, 'Your vocabulary set');
    expect(library.folders.single.id, 'folder-1');
    expect(library.folders.single.contentAt(0)?.words.single.term, 'Kind');
  });
}

class _Store implements VocabularySetStore {
  final created = <(String, bool)>[];
  final saved = <VocabularySet>[];

  @override
  Future<String> createFolder(
    String name, {
    bool editor = false,
    bool pinned = true,
  }) async {
    created.add((name, editor));
    return 'folder-${created.length}';
  }

  @override
  Future<void> save(VocabularySet set) async {
    saved.add(set);
  }

  @override
  Future<void> updateWords(VocabularySet set) async {}

  @override
  Future<void> renameFolder(String id, String name) async {}

  @override
  Future<void> deleteFolder(String id) async {}

  @override
  Future<void> setFolderPinned(String id, bool pinned) async {}
}
