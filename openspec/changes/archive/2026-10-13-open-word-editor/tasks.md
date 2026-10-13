# Tasks

## 1. Editor chrome

- [x] 1.1 Add the word editor getters to `lib/l10n/app_en.arb`, `app_vi.arb`, and `app_de.arb` using the strings in `openspec/changes/open-word-editor/specs/app-localization/spec.md`, then run `flutter gen-l10n`. `Chunking` and `IPA` stay those words in all three files. Extend `test/home_chrome_l10n_test.dart` so English, Vietnamese, and German return each of those strings. Verify `flutter test test/home_chrome_l10n_test.dart` passes.

## 2. Word editor

- [x] 2.1 Add the editor under `lib/features/word_editor/`. On open it shows an empty title, an empty description, and one expanded card numbered 1. Term, definition, sentence, IPA, singular and plural, and note are empty, and no type is selected. Details stay visible, and the Details chevron is not a button. English chrome matches the word-editor spec, including "Add new word" and "Enter term", and the screen does not show "ein Kind haben", "have a child", "All posts", "Enter your project title...", or "Add a discription...". Use the keys and the home palette from design.md. There is no sidebar and no home header. Add `test/features/word_editor/word_editor_test.dart` and verify `flutter test test/features/word_editor/word_editor_test.dart` passes.

- [x] 2.2 On the expanded card, activating Noun selects it and leaves Chunking, Verb, and Adj unselected. Activating Verb then selects Verb instead. Activating the selected type clears the selection. The selected chip uses `HomeColors.selectedFill` and `HomeColors.selected`. The type add control does not add a chip. Cover these cases in `test/features/word_editor/word_editor_test.dart` and verify that file passes.

- [x] 2.3 Activating Add new word collapses the current card and opens an empty expanded card above it, numbered one higher. Entering title "Animals", term "ein Kind haben", and definition "have a child" leaves the title as "Animals", shows those two strings on collapsed card 1 with the term on the left, and shows empty term and definition on expanded card 2. Activating Add new word twice on an empty editor shows expanded card 3 above collapsed card 2 above collapsed card 1. A collapsed card that had sentence "Das Kind" and Noun selected does not show "Enter sentence", "Noun", or "Add new word"; the expanded card still shows "Add new word". Cover these cases in the same test file and verify it passes.

- [x] 2.4 Activating Import, the search control, the header add control, or the copy or delete control on a collapsed card leaves the editor open and leaves that card's text and collapsed state unchanged. Import on the empty editor leaves one expanded card numbered 1 and no collapsed card. Cover these cases in the same test file and verify it passes.

- [x] 2.5 Done and the back control pop the route. Push the editor over a placeholder, enter "Kind" as the term, pop with Done, push again, and the new editor shows one empty card numbered 1 and does not show "Kind". The back control pops the same way. Cover both controls in the same test file and verify it passes.

## 3. New vocab opens the editor

- [x] 3.1 In `_NewVocabButton`, push the editor with `Navigator.push`. Update the fresh-launch case in `test/features/home/vocabulary_home_test.dart`: tapping New vocab shows "Add new word" and "Enter term" and does not show "Hot search" or "student". Enter title "German A1" and term "Kind", activate Done, and the home is back with Homepage selected, no folder name, no set name, "Hot search" and "student" shown, and `vocabulary_library` still unset. Then tap Save, as that case does now, and the library stays unset. From that home, open the editor again and activate the back control, and the home is back with "student" still shown. With a library that has a folder, New vocab then Done still shows that folder and Homepage. The wide and narrow header cases that only measure the New vocab button stay as they are. Verify `flutter test test/features/home/vocabulary_home_test.dart` passes.

## 4. Integration

- [x] 4.1 Run `flutter analyze` and `flutter test`. Verify analyze reports no issues and every test passes.
