# Proposal

## Why

New vocab is on the vocabulary home and does nothing. There is no screen where a user can start a set and type a word, so the button cannot lead anywhere.

## What Changes

- **BREAKING** for the home action that keeps New vocab on the vocabulary home. Activating New vocab opens the word editor. Search, Practice, Library, Notification, All, a hot-search chip, Save, and a suggestion row still stay on the home and still add nothing.
- The editor opens with the set title and description empty, and with one expanded word card. That card's term, definition, sentence, IPA, singular-plural, and note are empty, and no type is selected. It does not open with the three filled cards from the reference.
- Those three cards are the look of words already added. Activating Add new word collapses the current card into a summary row, term on the left and definition on the right, and opens a new empty expanded card above it. The new card's number is one higher. The first card is numbered 1.
- Done and the back control return to the vocabulary home and drop the draft. The saved library is unchanged: no new folder, set, or word.
- Import, the editor search, the header add control, the type add control, and the controls on a collapsed card are visible and do nothing.
- Editor chrome has Vietnamese, English, and German copy. The back control reads "All posts" in English. "Enter your project title..." and "Add a discription..." are not used.

Assumptions:

- The draft exists only while the editor is open. This change does not store words, and it does not change the rule that the library stores folder names and set names only.
- A collapsed row shows the term and definition the user typed. It does not show a photo. The photo on the reference card is not a field in this change.
- The back control is a leading chevron labeled "All posts" in English. Done is the labeled button that leaves.
- Details start open on the expanded card. The arrow hides them and shows them again.
- The title and the description use a filled background. The title label sits inside the title field.
- One type may be selected: Chunking, Noun, Verb, or Adj. The empty card starts with none. The type add control does not add a chip.

## Capabilities

### New Capabilities

- `word-editor`: The screen New vocab opens, with one empty card on entry, a collapsed summary row after a word is added, and a draft that is dropped on the way back to the home.

### Modified Capabilities

- `home-screen`: New vocab opens the word editor instead of staying on the vocabulary home. Returning still adds no folder, set, or word.
- `app-localization`: Word editor chrome has copy in Vietnamese, English, and German.

## Impact

- `lib/features/home/widgets/home_header.dart`, where New vocab's handler is empty.
- A new word editor under `lib/features/word_editor/`, pushed on the existing navigator. No new router package.
- `lib/l10n/app_en.arb`, `app_vi.arb`, and `app_de.arb` for the editor chrome.
- `test/features/home/vocabulary_home_test.dart`, which taps New vocab and expects the home, "student", and an unwritten library to remain. That tap now opens the editor. The return path still leaves the library unwritten.
- The durable `home-screen` requirement "Home actions stay on the home screen" currently names New vocab. This change takes New vocab out of that stay-on-home list. `vocabulary-library` is unchanged.
