# Proposal

## Why

Quiz in practice only shows a definition and never asks the learner to choose. The mode should be a multiple-choice question on the current term, with a clear right or wrong result, and the same level actions Flashcard already uses once the answer is visible.

## What Changes

- **BREAKING** Quiz no longer shows the definition alone, and previous and next no longer move between words in Quiz. The prompt is the current term, with the existing Term label and speak control. The learner chooses among that word and other words from the same set.
- A correct choice, a wrong choice, and Don't know each settle into their own result, with a short sound for correct and wrong. Don't know is silent and does not bring the word back later in the session.
- After the result has settled, a word that already has a level offers Hard, Familiar, and Easy. A new word offers Not yet studied and Studied. Those controls rise into place. Activating one records the same level action as Flashcard and moves to the next remaining word, or to the congratulations page on the last word.
- Choosing an option or Don't know does not itself change a level. Random and Typing stay as they are. The report flag from the reference screen is out of scope.

## Capabilities

### New Capabilities

### Modified Capabilities

- `study-session`: Quiz becomes option practice, and its level controls record the same actions as Flashcard.
- `app-localization`: The Quiz prompt, Don't know, and the two result sentences have copy in Vietnamese, English, and German.

## Impact

- `lib/features/home/widgets/set_study_page.dart` replaces the Quiz definition card and allows Quiz to record a rating only after a result.
- `lib/library/study_progress.dart` stays the source of Easy, Familiar, Hard, and studied. Quiz calls those actions and does not add a new level rule.
- `lib/l10n/app_en.arb`, `app_vi.arb`, and `app_de.arb` gain the Quiz copy. The Term label reuses `editorTerm`.
- Two new sound assets and a small player. The app has speech today and no effect player.
- `test/features/home/vocabulary_home_test.dart` currently expects Quiz to show the next word's definition and to hide Easy. Those expectations change.
