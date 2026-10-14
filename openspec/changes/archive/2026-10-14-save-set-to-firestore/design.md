# Design

## Context

See proposal.md for why Done stores a set. Done and the back control in `lib/features/word_editor/word_editor.dart` both call `_close`. The draft list is in editor state: the last draft is expanded, the list is painted newest first, and a card's number is its index plus one. A selected type is already the id `chunking`, `noun`, `verb`, or `adj`.

`VocabularyLibrary` is folder names and set-name lists in `SharedPreferences` under `vocabulary_library`. `loadVocabularyLibrary` runs in `main` and `LangApp` passes the value into `VocabularyHome`. The home does not write the library. There is no Firebase dependency and no client config for project `langmm-ca0d0`.

## Goals / Non-Goals

**Goals:**

- Keep the Firestore SDK behind one store the editor calls.
- Write one document per successful Done, with no owner field.
- Remember the editor folder on the device so a later Done uses it after a language change.
- Let widget tests save through a fake store.

**Non-Goals:**

- A sign-in screen, reading words back onto the home, or claiming documents that have no owner.
- New editor copy, including an error string.
- Changing Add new word, Import, or the collapsed-card controls.

## Decisions

### The editor calls a set store

`VocabularySetStore` has `Future<void> save(VocabularySet set)`. `FirestoreVocabularySetStore` is what `main` builds after `Firebase.initializeApp` for project `langmm-ca0d0`. `WordEditor` takes the store in its constructor. Widget tests pass a fake that records the set or throws. The editor widget does not construct Firebase.

Calling the Firestore SDK from the editor was considered. An account later would then edit the editor. The store is the only place that will add `ownerId`.

### One document in `sets`

`save` adds a document with an automatic id to the collection `sets`:

```
title: string
description: string
createdAt: server timestamp
words: [
  {
    term, definition, sentence, ipa, singularPlural, note
    type: included only when a type is selected
  }
]
```

The map has no `ownerId` key. `title` and `term` are trimmed. A title that is empty after trimming becomes the first kept term. A word whose trimmed term is empty is left out. Word order is the draft list order, card 1 first, which is the reverse of the painted order. Description, sentence, IPA, singular and plural, and note are stored as entered. A missing type omits the `type` key.

A subcollection of words was considered. This change writes the set once and never edits a word, so one document is enough.

### Done and Back diverge

Back still calls `onClose` and writes nothing. Done with no kept word calls `onClose` and writes nothing. Done with a kept word awaits `save`. On success the home updates the library, writes `SharedPreferences`, then closes the editor. On failure the editor stays open and the draft is unchanged. Firestore is written before the library. A library write that fails after Firestore succeeded leaves the editor open; a second Done can store a second set.

### The library remembers the editor folder

The saved JSON gains `editorFolder`, the folder name chosen at creation. `VocabularyLibrary` carries that string. A pure update takes the set name and the current `vocabularySet` label:

- No `editorFolder` yet: create a folder named with the current label, store that name as `editorFolder`, and put the set name in it.
- `editorFolder` already set: append the set name to that folder. The current label is ignored. If that folder row is missing, recreate it under the stored name.
- Every other folder stays as it is. A repeated name is appended again.

Old JSON without `editorFolder` still decodes, with the marker absent. A non-string `editorFolder` fails the decode, so the unreadable-library rule still loads empty and leaves the saved value in place.

`_HomeFrame` keeps the library it was given and replaces it after a successful save, so the sidebar and the dashboard update in the same session. The next launch reads the marker back through the existing restore path.

### Firebase is initialized in main

`pubspec.yaml` gains `firebase_core` and `cloud_firestore`. The web client config for project `langmm-ca0d0` is committed as client options. A service-account key is not committed. `main` initializes Firebase before `runApp` and passes the Firestore store through `LangApp` into `VocabularyHome`. Widget tests never call `main`, so they never initialize Firebase.

### Rules allow an unsigned-in create

`firestore.rules` for `sets/{setId}` allows create when `request.auth` is null and the document has no `ownerId` key. Read, update, and delete stay closed. The home does not read the collection. A later account change replaces that create with `ownerId == request.auth.uid` in this file and in `FirestoreVocabularySetStore`.

## Risks / Trade-offs

- [Anyone who can open the GitHub Pages app can create a `sets` document while create is unsigned-in] → The rule file is the switch. This change does not add a public read.
- [Documents have no owner, so the first account cannot see them until a later claim] → Accepted. The store is the seam. Claiming is out of this change.
- [The sidebar name lives on the device. Another browser does not show the set] → Accepted. Words are in Firestore. Names stay in `SharedPreferences` until accounts scope the library.
- [A library write can fail after Firestore succeeds, and retrying Done stores a second set] → The editor stays open, which matches the failed-save rule for the library. The duplicate set is the cost of writing Firestore first.
- [Saving while the debug sample toggle is showing the sample still writes the real library] → The sidebar keeps showing the sample until the toggle returns to the library home. The empty-home path is the one the specs cover.
- [The home test that types "German A1" and "Kind" then taps Done expects no folder] → That case now expects folder "Your vocabulary set" and set "German A1", and the suggestion columns are gone. Done on an empty editor still leaves `vocabulary_library` unset.
- [The word-editor test "done and back drop the draft" taps Done after typing "Kind"] → That test passes a fake store, expects the stored term "Kind", and still expects the editor to close.

## Migration Plan

No word documents exist yet. Existing `vocabulary_library` values have no `editorFolder` and keep decoding. Shipping the web build starts sending successful Done actions to `langmm-ca0d0` once the rules are published. Rolling back the app stops new writes. Documents already created remain in `sets` until someone deletes them in the Firebase console. Tightening the rules later does not require a new document shape.
