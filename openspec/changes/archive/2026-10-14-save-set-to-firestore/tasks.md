# Tasks

## 1. Editor folder

- [x] 1.1 Add `editorFolder` to `VocabularyLibrary` and to the JSON in `lib/library/vocabulary_library_store.dart`. A saved library with `editorFolder` "Bộ từ vựng của bạn" round-trips that marker and its folders. JSON with no `editorFolder` still loads, and the marker is absent. A non-string `editorFolder` loads as empty and leaves the saved value in place, same as the unreadable cases already in `test/library/vocabulary_library_store_test.dart`. The existing round-trip of "My vocab" and "Travel", the unknown-keys case, and the unreadable cases still pass. Verify `flutter test test/library/vocabulary_library_store_test.dart` passes.

- [x] 1.2 Add a pure update that takes the set name and the current "Your vocabulary set" label. With no editor folder, English label "Your vocabulary set" creates that folder and puts "German A1" in it; Vietnamese "Bộ từ vựng của bạn" and German "Dein Vokabelset" do the same for those labels. When the editor folder is already "Bộ từ vựng của bạn", saving "Animals" with the English label appends to that folder and does not create "Your vocabulary set". A library that has "My vocab" / "German A1 vocabulary" and no editor folder keeps "My vocab" unchanged and puts "Animals" in the new English folder. Saving "Animals" twice lists it twice. If the marker is set and that folder row is missing, the update recreates the folder under the stored name. Cover these cases in `test/library/vocabulary_library_store_test.dart` and verify that file passes.

## 2. Set document

- [x] 2.1 Add `VocabularySet` and a pure map for the `sets` document, as in design.md, under `lib/library/`. The map uses trimmed title and term, card-1-first order, and no `ownerId` key. A selected type stores `noun` (the existing chip id). No selected type omits `type`. Description, sentence, IPA, singular and plural, and note are stored as entered. An empty title becomes the first kept term, including a title of only spaces. A card whose term is empty or only spaces is left out. No kept term produces no document. Add `test/library/vocabulary_set_test.dart` for the filled card ("German A1", "Basics", "Kind", "child", "Das Kind", "kɪnt", "Kind - Kinder", "noun", type `noun`), the Kind-then-Haus order, the blank card after Add new word, the whitespace term, the blank title, the whitespace title, and the missing type. Verify `flutter test test/library/vocabulary_set_test.dart` passes.

## 3. Done and Back

- [x] 3.1 Split Done from Back in `lib/features/word_editor/word_editor.dart`. `WordEditor` takes a `VocabularySetStore`. Back calls `onClose` and does not call `save`. Add new word does not call `save`. Done with no kept term calls `onClose` and does not call `save`. Done with a kept term awaits `save`, then closes. A thrown `save` leaves the editor open and leaves the term in place. Update `test/features/word_editor/word_editor_test.dart`: the case that enters "Kind" and taps Done passes a fake store, expects that store to receive term "Kind", then expects the editor to close and the next open to be one empty card. Back with "Kind" does not call `save` and still closes. A fake that throws on Done leaves "Kind" on the open editor. A term of only spaces closes without calling `save`. The existing Add new word cases still pass. Verify `flutter test test/features/word_editor/word_editor_test.dart` passes.

## 4. Sidebar

- [x] 4.1 Pass the set store from `VocabularyHome` into the editor. On a successful save, update the in-memory library with the current `vocabularySet` label, write it through `SharedPreferencesVocabularyLibraryStore`, then close the editor. On a failed save, stay in the editor and do not write the library. In `test/features/home/vocabulary_home_test.dart`, Done on the empty editor from a home with no folders still shows "Hot search" and "student", leaves `vocabulary_library` unset, and the suggestion Save control still leaves it unset. Back after entering "Kind" on that empty home still shows "student" and leaves the library unset. Entering title "German A1" and term "Kind", then Done, with a fake store that succeeds, shows "Your vocabulary set" and "German A1", shows "0/0", and does not show "Hot search" or "student". The saved JSON has `editorFolder` "Your vocabulary set" and set "German A1", and does not contain "Kind". A fake that throws after entering "Kind" stays on the editor, still shows "Kind", and leaves `vocabulary_library` unset. The case that already has folder "My vocab" and taps Done on the empty editor still shows "My vocab" and "German A1 vocabulary". Verify `flutter test test/features/home/vocabulary_home_test.dart` passes.

## 5. Firestore

- [x] 5.1 Add `firebase_core` and `cloud_firestore` to `pubspec.yaml`. Add the web client config for Firebase project `langmm-ca0d0` in `lib/firebase_options.dart`. Do not commit a service-account key. `main` calls `Firebase.initializeApp` with those options and passes `FirestoreVocabularySetStore` through `LangApp` into `VocabularyHome`. That store writes the map from task 2.1 to collection `sets` and sets `createdAt` to a server timestamp. Verify `lib/firebase_options.dart` contains project id `langmm-ca0d0`, `flutter pub get` succeeds, and `flutter test test/library/vocabulary_set_test.dart` still passes.

- [x] 5.2 Add `firestore.rules` so `sets/{setId}` allows create only when `request.auth` is null and the document has no `ownerId` key, and read, update, and delete are denied. Point `firebase.json` at that file. Verify the rules file states those conditions. Publish the rules to project `langmm-ca0d0` and verify the publish command exits 0.

## 6. Integration

- [x] 6.1 Run `flutter analyze` and `flutter test`. Verify analyze reports no issues and every test passes.
