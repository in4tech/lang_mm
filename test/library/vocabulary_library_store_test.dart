import 'package:flutter_test/flutter_test.dart';
import 'package:lang/library/vocabulary_library.dart';
import 'package:lang/library/vocabulary_library_store.dart';
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
        VocabularyFolder(name: 'Travel', sets: <String>[]),
      ],
    );

    await store.write(library);
    final loaded = await store.read();

    expect(loaded.folders, hasLength(2));
    expect(loaded.folders[0].name, 'My vocab');
    expect(loaded.folders[0].sets, <String>['German A1 vocabulary']);
    expect(loaded.folders[1].name, 'Travel');
    expect(loaded.folders[1].sets, isEmpty);
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
    ];

    for (final raw in cases) {
      final store = await open(<String, Object>{
        VocabularyLibraryStore.storageKey: raw,
      });

      final loaded = await store.read();
      final preferences = await SharedPreferences.getInstance();

      expect(loaded.folders, isEmpty, reason: raw);
      expect(preferences.getString(VocabularyLibraryStore.storageKey), raw);
    }
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
