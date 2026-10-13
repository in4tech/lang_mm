# Design

## Context

See proposal.md for why New vocab opens an editor. `LangApp` sets `home` to `VocabularyHome`. `MaterialApp` already supplies a navigator. `_NewVocabButton` in `lib/features/home/widgets/home_header.dart` has an empty `onPressed`, and both the wide and narrow headers use that button. `VocabularyLibrary` stores folder names and set names only. Chrome strings live in `lib/l10n/app_en.arb`, `app_vi.arb`, and `app_de.arb`, and `test/home_chrome_l10n_test.dart` asserts them.

## Goals / Non-Goals

**Goals:**

- Open the editor in the center of the vocabulary home. The header and the sidebar stay.
- Keep the draft in the editor widget so closing it drops the draft.
- Paint the empty card and the collapsed summary row with the home palette.

**Non-Goals:**

- A router package, a photo field, or a write to `VocabularyLibrary`.
- Adding a fifth word type.

## Decisions

### New vocab swaps the center

`HomeHeader` takes `onNewVocab`. `_HomeFrame` sets `_editing` and replaces the child of `home-canvas` with `WordEditor`. The header and `HomeSidebar` stay, on both the wide frame and the narrow column. Done and the back control call `onClose`, which clears `_editing` and disposes the editor.

A full-screen route was considered. It would hide the header and the sidebar. The center swap keeps the chrome the home already has.

### The draft lives on the editor

The editor `State` holds the title, the description, and a list of word drafts. Each draft has term, definition, sentence, IPA, singular and plural, note, and a selected type id or none. The widget starts with one draft. Closing it disposes that state. The next open builds a new editor. Nothing is written to `VocabularyLibraryStore`.

A controller above the home was considered. The next visit has to be empty, so state that outlives the editor would have to be cleared on close anyway.

### New cards are appended and shown newest first

Add new word appends an empty draft and leaves the previous draft in the list. The last draft is the expanded card. The list is shown in reverse, so the expanded card is on top. A card's number is its index plus one. The first card is 1. After two adds the screen shows 3, then 2, then 1.

The collapsed card shows the term and the definition only, including when both are empty. It also shows a copy control and a delete control. Those two, Import, the search control, the header add control, and the type add control use an empty handler. The Details arrow hides and shows the IPA, singular-plural, and note fields. It starts open.

### The page reuses the home palette

Inside the home, the editor is the center column and the home scroll view scrolls it. On its own, it is a column at most 960 wide on `HomeColors.folderFill`. The title and the description sit in `HomeColors.selectedFill` boxes. The title label is inside the title box, above the text. Cards are white with `HomeColors.border`. Done uses `HomeColors.newVocab`. A selected type uses `HomeColors.selectedFill` and `HomeColors.selected`. Unselected types stay white. The back control is a chevron labeled with the back string, inside the center column.

Copy comes from the new `AppLocalizations` getters. The strings are the ones in `specs/app-localization/spec.md`. `Chunking` and `IPA` are the same in English, Vietnamese, and German.

Keys the tests can use: `word-editor-back`, `word-editor-title`, `word-editor-description`, `word-editor-import`, `word-editor-search`, `word-editor-add`, `word-editor-type-add`, and `word-card-<n>` for card number n. The expanded card's fields use `word-term`, `word-definition`, `word-sentence`, `word-ipa`, `word-singular-plural`, and `word-note`. A collapsed card's controls use `word-card-copy-<n>` and `word-card-delete-<n>`.

## Risks / Trade-offs

- [The empty-home widget test taps New vocab and then Save on the same home] → Save is not in the center while the editor is open. The header and sidebar stay. That test closes with Done before it taps Save, and still expects no `vocabulary_library` value.
- [The wide and narrow header tests measure the New vocab button and do not tap it] → Those assertions stay. The button's size and row do not change.
- [Vietnamese "Nhập" is also the start of several placeholders] → `find.text` is exact, so the Import label and "Nhập từ" stay distinct.
- [German reuses "Definition", "Verb", "IPA", "Chunking", and "Singular - Plural"] → German coverage asserts "Fertig" and "Neues Wort hinzufügen", which are not the English strings.
- [Add new word on an empty card still stacks a blank summary row] → Accepted. The spec requires the new card even when the current fields are empty.

## Migration Plan

No stored data. Shipping this build makes New vocab replace the center with the editor. Rolling back restores the empty handler. The `vocabulary_library` document is unchanged.
