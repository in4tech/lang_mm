# Tasks

## 1. Vocabulary library store

- [x] 1.1 Add `VocabularyLibrary` and a `SharedPreferences` store under `lib/library/`, with `loadVocabularyLibrary()` reading the `vocabulary_library` JSON document from design.md. Missing key loads empty. A valid document round-trips folder and set names, including an empty set list, and ignores unknown keys. A value that is not that shape, including a folder without a string `name` or a string array `sets`, loads empty and is left unchanged. The empty library contains no sample names and no suggestion-template names, and the model has no word or learned-count field. Verify with `flutter test test/library`.

## 2. Suggestion copy

- [x] 2.1 Add `hotSearch`, `suggestedSets`, `suggestedPractice`, `saveWord`, and `saveCount` to `lib/l10n/app_en.arb`, `app_vi.arb`, and `app_de.arb` using the strings in design.md, then run `flutter gen-l10n`. Extend `test/home_chrome_l10n_test.dart` so English, Vietnamese, and German return those strings, including `saveCount(80)`. Verify `flutter test test/home_chrome_l10n_test.dart` passes.

## 3. Home reads the library

- [x] 3.1 Add `suggestion_templates.dart` and the two-column suggestion layout under `lib/features/home/`. `VocabularyHome` shows that layout when no `HomeSample` is passed and the library has no folders: header, sidebar with no folders, Hot search chips, Suggested sets, the student card, and Suggested practice. It does not show the statistics heading, Today's vocabulary, Recent, 0/0, or Practice. Chip, Save, and row taps do nothing. `LangApp` takes the loaded library and `main` loads it before `runApp`, using an empty library when preferences cannot be opened. Update `test/widget_test.dart` and `test/features/home/vocabulary_home_test.dart` for that empty launch, including chip order and both lists. Tapping New vocab and Save leaves the sidebar empty, leaves "student" on screen, and does not write `vocabulary_library`. Verify `flutter test test/widget_test.dart test/features/home/vocabulary_home_test.dart` passes.

- [x] 3.2 Map a non-empty library to a `HomeSample`: stored folders expanded with their set names, blank statistics name, 0/0, 0%, no bars, six legend levels at 0%, no today rows, no recent cards, Homepage selected. Passing folder "My vocab" and set "German A1 vocabulary" shows those names in the sidebar, the zero statistics, Practice, and no Continue, and does not show "Hot search". Verify with the same widget tests as 3.1.

- [x] 3.3 Keep `HomeSample.current` as a fixture that is not the launch default and is not written by the store. `test/features/home/home_sample_test.dart` still asserts its pictured names and 5/20. Add a widget check that `VocabularyHome(sample: HomeSample.current)` still shows "5/20" and "das Auto fahren", and that a fresh `LangApp` does not. Verify `flutter test test/features/home/home_sample_test.dart test/features/home/vocabulary_home_test.dart` passes.

## 4. Language switch

- [x] 4.1 Update `test/features/home/vocabulary_home_language_test.dart`. An empty library switched to German still shows "student", "love", and "Love vocabulary", shows "Beliebte Suche", does not show "0/0", "German A1 vocabulary", or "das Auto fahren". A library with "My vocab" and "German A1 vocabulary" switched to Vietnamese still shows those names, stays at 0/0, does not show "Hot search" or "das Auto fahren", and shows Vietnamese chrome. Verify `flutter test test/features/home/vocabulary_home_language_test.dart` passes.

## 5. Integration

- [x] 5.1 Run `flutter analyze` and `flutter test`. Verify analyze reports no issues and every test passes.
