# Proposal

## Why

Done throws away every word the user just typed. The set never leaves the editor, and the sidebar stays empty, so New vocab cannot grow a vocabulary the user can come back to.

## What Changes

- **BREAKING** for Done after at least one card has a term. Done stores that set, then returns to the vocabulary home. The sidebar shows the set name immediately. Back still returns and drops the draft without storing anything.
- Add new word still only collapses the current card and opens an empty card above it. It does not store a set.
- A card with no term is left out, including a blank card left by Add new word. The expanded card is included when it has a term. Words are kept in card number order, card 1 first.
- The stored set keeps the title, the description, and each kept card's term, definition, sentence, IPA, singular and plural, note, and selected type. A card with no type stores no type.
- The set is stored in Cloud Firestore in the Firebase project `langmm-ca0d0`. The document has no owner. This change does not ask the user to sign in. The write sits behind one boundary so a later change can attach an account without rewriting the editor.
- The same successful Done adds the set name to one folder in the on-device library. The first successful save creates that folder when it is missing. The folder name is the "Your vocabulary set" label in the language active at creation: "Your vocabulary set", "Bộ từ vựng của bạn", or "Dein Vokabelset". Later saves add to that same folder after a language change. Folders already on the device are left as they are.
- The on-device library still stores names only. Words stay in Firestore.
- An empty title is stored and shown as the first kept term. The same title saved twice produces two sets and two sidebar rows.
- Done with no term stores nothing, creates no folder, and returns home. The suggestion columns stay.
- A failed store leaves the editor open, keeps the draft, and does not add a sidebar row.

Assumptions:

- A title or term that is only whitespace counts as empty.
- This change does not load words back onto the home, into Today's vocabulary, or into Recent. Those stay as they are once a folder exists: statistics at 0/0, an empty today list, and no recent cards.
- Documents stored now have no owner. Claiming them for an account is a later change.
- No new editor copy. A failed store adds no error string.
- The home already replaces the suggestion columns with the dashboard once the library has a folder. A successful save uses that existing rule.

## Capabilities

### New Capabilities

- `vocabulary-sets`: A finished set's words are stored in Cloud Firestore for project `langmm-ca0d0`, with no owner, and a failed store writes nothing.

### Modified Capabilities

- `word-editor`: Done with a term stores the set and leaves the editor. Back still drops the draft. Done with no term still leaves the library unchanged.
- `vocabulary-library`: A successful save adds the set name to the editor folder, creating that folder from the current "Your vocabulary set" label when it is missing. The library still does not store words.

## Impact

- `lib/features/word_editor/word_editor.dart`, where Done and the back control both call the same close path.
- A new set store that writes one Firestore document per successful Done. The editor depends on that store, not on the Firestore SDK directly.
- `lib/library/vocabulary_library.dart` and `lib/library/vocabulary_library_store.dart`, so the device remembers the editor folder and the set names under it.
- `pubspec.yaml` gains the Firebase packages used to initialize project `langmm-ca0d0` and write Firestore. The web app is registered in that project. No Firebase config exists in the repo today.
- Firestore rules for `langmm-ca0d0` allow the unsigned-in web client to create these set documents. The rule file is the place a later account check will replace that open create.
- `test/features/word_editor/word_editor_test.dart` and `test/features/home/vocabulary_home_test.dart`. The home case that enters "German A1" and "Kind", then Done, currently expects no folder and an unwritten library. That case now expects the editor folder and the set name. Done on an empty editor still leaves the library unwritten.
- `home-screen` and `app-localization` requirements stay as they are. The three folder labels already exist, and a library that has a folder already drives the sidebar and the dashboard.
