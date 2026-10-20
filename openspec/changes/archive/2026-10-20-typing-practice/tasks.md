# Tasks

## 1. Copy and helpers

- [x] 1.1 Add `typingYourAnswer`, `typingHint`, and `typingCheck` to `app_en.arb`, `app_vi.arb`, and `app_de.arb` with the strings in `specs/app-localization/spec.md`, regenerate the localization classes, and extend the chrome/l10n test for all three languages. Verify that test passes.
- [x] 1.2 Add a pure helper that blanks whole-word term matches in a plain sentence as `---` (case-insensitive) and a checker that trims and lowercases both sides. Verify unit tests for multiple matches, a sentence without the term, `memorize` vs `memorized`, and correct/wrong Check comparisons including spaced and mixed-case input.

## 2. Typing card

- [x] 2.1 When the mode is Typing, show a Typing card instead of `_FlashcardStage`: meaning cue (IPA, type, definition, blanked sentence; omit empty), "Your answer", the field with the type-the-term hint, Check, and Don't know. Hide previous and next. Disable Check when the field is empty. Wire Enter to the same Check path. Verify widget tests for the Kind cue hiding the term, blanked sentence, omitted empty definition, empty Check inactive, Don't know present, and no previous or next.

## 3. Result

- [x] 3.1 Settle a correct Check, a wrong Check, and Don't know with wrong / try-later copy when needed, tones, locked field, and revealed term from `specs/study-session/spec.md`. Correct answers show no praise text. Ignore further Check, Don't know, and edits after a result. Verify widget tests for lowercase and spaced correct answers, wrong "Haus", Don't know with no tone, locked field, and a second Check leaving the level unchanged.

## 4. Level controls

- [x] 4.1 After the result settles, show Hard, Familiar, and Easy for a word at level 1 through 6, or Not yet studied and Studied for a new word, with the same rise timing as Quiz (immediate when animations are disabled). Verify levels are absent before a result, present after it, and that a new word hides the three ratings.
- [x] 4.2 Let `_rate` and `_skipNew` accept Typing only while a result is set, write through the existing level actions, and advance to the next Typing cue without setting `_exit`. Clear the result on that write, on leaving Typing, and on closing practice. Verify Easy records and shows the next cue, the last word shows congratulations, Studied / Not yet studied behave like Quiz, and closing or choosing Flashcard during the result keeps the level.
- [x] 4.3 When animations are disabled, show the final result and the level controls together, accept a rating immediately, and still request the tone. Verify that path with `disableAnimations: true` for a correct Typing Check on "Kind" at level 1.

## Workflow follow-up

- Archive the change after implementation and review.
- Sync delta specs into main `study-session` and `app-localization` specs on archive.
