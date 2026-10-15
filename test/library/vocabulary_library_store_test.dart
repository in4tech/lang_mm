import 'package:flutter_test/flutter_test.dart';
import 'package:lang/library/vocabulary_library.dart';
import 'package:lang/library/vocabulary_library_store.dart';
import 'package:lang/library/vocabulary_set.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const sampleNames = <String>[
    'My vocab',
    'My vocab 2',
    'German A1 vocabulary',
    'A2 vocabulary',
    'German B1 vocabulary',
    'das Auto fahren',
    'student',
    'Love vocabulary',
    'Practice "love"',
  ];

  Future<SharedPreferencesVocabularyLibraryStore> open(
    Map<String, Object> values,
  ) async {
    SharedPreferences.setMockInitialValues(values);
    final preferences = await SharedPreferences.getInstance();
    return SharedPreferencesVocabularyLibraryStore(preferences);
  }

  List<String> namesIn(VocabularyLibrary library) {
    return <String>[
      for (final folder in library.folders) ...<String>[
        folder.name,
        ...folder.sets,
      ],
    ];
  }

  test(
    'a missing library is empty and has no sample or template names',
    () async {
      final store = await open(<String, Object>{});

      final library = await store.read();

      expect(library.folders, isEmpty);
      expect(library.editorFolder, isNull);
      expect(namesIn(library), isNot(containsAll(sampleNames)));
      for (final name in sampleNames) {
        expect(namesIn(library), isNot(contains(name)));
      }
    },
  );

  test('a saved library round-trips folder and set names', () async {
    final store = await open(<String, Object>{});
    const library = VocabularyLibrary(
      folders: <VocabularyFolder>[
        VocabularyFolder(
          name: 'My vocab',
          sets: <String>['German A1 vocabulary'],
        ),
        VocabularyFolder(name: 'Travel', id: 'folder-1', sets: <String>[]),
      ],
    );

    await store.write(library);
    final loaded = await store.read();

    expect(loaded.folders, hasLength(2));
    expect(loaded.folders[0].name, 'My vocab');
    expect(loaded.folders[0].sets, <String>['German A1 vocabulary']);
    expect(loaded.folders[1].name, 'Travel');
    expect(loaded.folders[1].id, 'folder-1');
    expect(loaded.folders[0].id, isNull);
    expect(loaded.folders[1].sets, isEmpty);
    expect(loaded.editorFolder, isNull);
  });

  test('a saved set id round-trips and a missing id still loads', () async {
    final store = await open(<String, Object>{});
    const word = VocabularyWord(
      term: 'Kind',
      definition: 'child',
      sentence: '',
      ipa: '',
      singularPlural: '',
      note: '',
    );
    final library = VocabularyLibrary(
      folders: <VocabularyFolder>[
        VocabularyFolder(
          name: 'My vocab',
          sets: const <String>['German A1', 'Haus'],
          contents: <VocabularySet?>[
            const VocabularySet(
              id: 'setA',
              title: 'German A1',
              description: '',
              words: <VocabularyWord>[word],
            ),
            const VocabularySet(
              title: 'Haus',
              description: '',
              words: <VocabularyWord>[word],
            ),
          ],
        ),
      ],
    );

    await store.write(library);
    final loaded = await store.read();
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(VocabularyLibraryStore.storageKey);

    expect(loaded.folders.single.contentAt(0)?.id, 'setA');
    expect(loaded.folders.single.contentAt(1)?.id, isNull);
    expect(raw, isNot(contains('learnedCount')));
    expect(raw, isNot(contains('today')));
  });

  test('a saved set keeps its words', () async {
    final store = await open(<String, Object>{});
    const word = VocabularyWord(
      term: 'Kind',
      definition: 'child',
      sentence: 'Das Kind',
      ipa: '/kɪnt/',
      singularPlural: 'Kind, Kinder',
      note: 'people',
      type: 'noun',
      imageUrl: 'https://example.com/kind.jpg',
    );
    final library = VocabularyLibrary.empty.addSavedSet(
      name: 'German A1',
      folderLabel: 'Your vocabulary set',
      content: const VocabularySet(
        title: 'German A1',
        description: 'basics',
        words: <VocabularyWord>[word],
      ),
    );

    await store.write(library);
    final loaded = await store.read();
    final stored = loaded.folders.single.contentAt(0);

    expect(loaded.folders.single.sets, <String>['German A1']);
    expect(stored?.title, 'German A1');
    expect(stored?.description, 'basics');
    expect(stored?.words.single.term, 'Kind');
    expect(stored?.words.single.definition, 'child');
    expect(stored?.words.single.sentence, 'Das Kind');
    expect(stored?.words.single.ipa, '/kɪnt/');
    expect(stored?.words.single.singularPlural, 'Kind, Kinder');
    expect(stored?.words.single.note, 'people');
    expect(stored?.words.single.type, 'noun');
    expect(stored?.words.single.imageUrl, 'https://example.com/kind.jpg');
  });

  test('editorFolder round-trips with its folders', () async {
    final store = await open(<String, Object>{});
    const library = VocabularyLibrary(
      editorFolder: 'Bộ từ vựng của bạn',
      folders: <VocabularyFolder>[
        VocabularyFolder(
          name: 'Bộ từ vựng của bạn',
          sets: <String>['German A1'],
        ),
      ],
    );

    await store.write(library);
    final loaded = await store.read();

    expect(loaded.editorFolder, 'Bộ từ vựng của bạn');
    expect(loaded.folders.single.name, 'Bộ từ vựng của bạn');
    expect(loaded.folders.single.sets, <String>['German A1']);
  });

  test('JSON without editorFolder loads with the marker absent', () async {
    final store = await open(<String, Object>{
      VocabularyLibraryStore.storageKey:
          '{"folders":[{"name":"Travel","sets":[]}]}',
    });

    final loaded = await store.read();

    expect(loaded.editorFolder, isNull);
    expect(loaded.folders.single.name, 'Travel');
  });

  test('unknown keys are ignored and the saved value stays', () async {
    const raw =
        '{"extra":1,"folders":[{"name":"My vocab","sets":["German A1 vocabulary"],"words":["das Auto"]}]}';
    final store = await open(<String, Object>{
      VocabularyLibraryStore.storageKey: raw,
    });

    final loaded = await store.read();
    final preferences = await SharedPreferences.getInstance();

    expect(loaded.folders.single.name, 'My vocab');
    expect(loaded.folders.single.sets, <String>['German A1 vocabulary']);
    expect(preferences.getString(VocabularyLibraryStore.storageKey), raw);
  });

  test('an unreadable library loads empty and is left unchanged', () async {
    const cases = <String>[
      'not-json',
      '{"folders":{"name":"My vocab"}}',
      '{"folders":[{"name":"My vocab"}]}',
      '{"folders":[{"sets":["German A1 vocabulary"]}]}',
      '{"folders":[{"name":"My vocab","sets":[1]}]}',
      '{"folders":[{"name":"My vocab","sets":[],"id":1}]}',
      '{"folders":[],"editorFolder":1}',
    ];

    for (final raw in cases) {
      final store = await open(<String, Object>{
        VocabularyLibraryStore.storageKey: raw,
      });

      final loaded = await store.read();
      final preferences = await SharedPreferences.getInstance();

      expect(loaded.folders, isEmpty, reason: raw);
      expect(loaded.editorFolder, isNull, reason: raw);
      expect(preferences.getString(VocabularyLibraryStore.storageKey), raw);
    }
  });

  test('a new folder keeps its firestore id', () {
    final saved = VocabularyLibrary.empty.addFolder('Travel', id: 'folder-2');

    expect(saved.folders.single.name, 'Travel');
    expect(saved.folders.single.id, 'folder-2');
    expect(saved.editorFolder, isNull);
  });

  test('the first save stores the firestore folder id', () {
    final saved = VocabularyLibrary.empty.addSavedSet(
      name: 'Animals',
      folderLabel: 'Your vocabulary set',
      folderId: 'folder-9',
    );

    expect(saved.folders.single.id, 'folder-9');
    expect(saved.editorFolder, 'Your vocabulary set');
  });

  test('a later save keeps the stored folder id', () {
    const library = VocabularyLibrary(
      editorFolder: 'Your vocabulary set',
      folders: <VocabularyFolder>[
        VocabularyFolder(name: 'Your vocabulary set', id: 'folder-9'),
      ],
    );

    final saved = library.addSavedSet(
      name: 'Animals',
      folderLabel: 'Your vocabulary set',
      folderId: 'folder-9',
    );

    expect(saved.folders.single.id, 'folder-9');
  });

  test('the first save creates the editor folder from the label', () {
    const labels = <String>[
      'Your vocabulary set',
      'Bộ từ vựng của bạn',
      'Dein Vokabelset',
    ];

    for (final label in labels) {
      final saved = VocabularyLibrary.empty.addSavedSet(
        name: 'German A1',
        folderLabel: label,
      );

      expect(saved.editorFolder, label);
      expect(saved.folders, hasLength(1));
      expect(saved.folders.single.name, label);
      expect(saved.folders.single.sets, <String>['German A1']);
    }
  });

  test('a later save keeps the existing editor folder', () {
    const library = VocabularyLibrary(
      editorFolder: 'Bộ từ vựng của bạn',
      folders: <VocabularyFolder>[
        VocabularyFolder(
          name: 'Bộ từ vựng của bạn',
          sets: <String>['German A1'],
        ),
      ],
    );

    final saved = library.addSavedSet(
      name: 'Animals',
      folderLabel: 'Your vocabulary set',
    );

    expect(saved.editorFolder, 'Bộ từ vựng của bạn');
    expect(saved.folders, hasLength(1));
    expect(saved.folders.single.sets, <String>['German A1', 'Animals']);
    expect(
      saved.folders.map((folder) => folder.name),
      isNot(contains('Your vocabulary set')),
    );
  });

  test('an existing folder is not the destination', () {
    const library = VocabularyLibrary(
      folders: <VocabularyFolder>[
        VocabularyFolder(
          name: 'My vocab',
          sets: <String>['German A1 vocabulary'],
        ),
      ],
    );

    final saved = library.addSavedSet(
      name: 'Animals',
      folderLabel: 'Your vocabulary set',
    );

    expect(saved.folders, hasLength(2));
    expect(saved.folders[0].name, 'My vocab');
    expect(saved.folders[0].sets, <String>['German A1 vocabulary']);
    expect(saved.folders[1].name, 'Your vocabulary set');
    expect(saved.folders[1].sets, <String>['Animals']);
    expect(saved.editorFolder, 'Your vocabulary set');
  });

  test('the same set name is listed twice', () {
    final once = VocabularyLibrary.empty.addSavedSet(
      name: 'Animals',
      folderLabel: 'Your vocabulary set',
    );

    final twice = once.addSavedSet(
      name: 'Animals',
      folderLabel: 'Your vocabulary set',
    );

    expect(twice.folders.single.sets, <String>['Animals', 'Animals']);
  });

  test('a missing editor folder row is recreated under the stored name', () {
    const library = VocabularyLibrary(editorFolder: 'Bộ từ vựng của bạn');

    final saved = library.addSavedSet(
      name: 'Animals',
      folderLabel: 'Your vocabulary set',
    );

    expect(saved.editorFolder, 'Bộ từ vựng của bạn');
    expect(saved.folders.single.name, 'Bộ từ vựng của bạn');
    expect(saved.folders.single.sets, <String>['Animals']);
  });

  test('loadVocabularyLibrary reads the same document', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      VocabularyLibraryStore.storageKey:
          '{"folders":[{"name":"Travel","sets":[]}]}',
    });

    final library = await loadVocabularyLibrary();

    expect(library.folders.single.name, 'Travel');
    expect(library.folders.single.sets, isEmpty);
  });
}
