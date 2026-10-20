# Design

## Context

See proposal.md for why. Typing today is a branch of `_Flashcard` / `_cardLines` in `set_study_page.dart`: it shows `term` + sentence, mounts a `TextField` with `editorDefinitionHint`, and never reads `_typing` for a check. `_rate` and `_skipNew` already accept Quiz only when a result is set; Typing is still excluded. Quiz owns a sibling `QuizCard`, result enum, praise streak, tones via `quizTone`, and post-result `_QuizRatings` / `_QuizNewWordActions`. `sentencePlain` already strips rich sentence markup. There is no term-blanking helper yet.

## Goals / Non-Goals

**Goals:**

- Mirror Quiz’s session write path: local result → level controls → `_rate` / `_skipNew` → `_advance`.
- Reuse Quiz wrong/skip copy, tones, and rise timing (including `disableAnimations`). No praise text on a correct Typing answer.
- Keep Random’s arrows and no-rating behavior unchanged.

**Non-Goals:**

- Fuzzy matching, accent folding, or accepting `singularPlural` as an alternate answer.
- Speak-on-cue before the term is revealed (would spoil the answer).
- A multi-question scroll sheet like Quizlet’s test page.
- New SRS rules in `study_progress.dart`.

## Decisions

### Typing is a sibling of QuizCard, not a `_Flashcard` branch

When the mode is Typing, the practice column builds a Typing card instead of `_FlashcardStage` (same pattern as Quiz). The card owns the cue, field, Check, Don't know, and result presentation. Previous and next arrows stay hidden for Typing, matching Quiz.

Alternative: keep Typing inside `_Flashcard` and only raise `minHeight`. Rejected because the cue, check, and lock behavior do not fit the flashcard face model.

### Cue blanks whole-word term matches

Build the sentence cue from `sentencePlain`. Replace each whole-word occurrence of the term with `---`, matching case-insensitively (same lowercase rule as Check). Non-matching sentences stay as-is. Empty IPA, type, definition, or sentence are omitted. The term itself is never shown on the cue before a result; after a result the revealed term is shown with the feedback.

Alternative: hide the sentence entirely. Rejected — exploration chose blanking.

### Check compares trimmed lowercase strings

`Check` and Enter submit only when the field has non-whitespace content. Correctness is `field.trim().toLowerCase() == term.trim().toLowerCase()`. No other normalization.

### Result and rating reuse the Quiz gate

Hold a Typing result: none, correct, wrong, or don't know. Correct requests the high tone and reveals the term with no praise line. Wrong requests the low tone. Don't know requests no tone. Further Check / Don't know / edits are ignored until the word advances.

After the result settles (same 250 ms / 240 ms rise as Quiz, or immediate when animations are disabled), show Hard / Familiar / Easy or Not yet studied / Studied. `_rate` and `_skipNew` accept Typing only while a result is set, clear it, and advance without a Flashcard exit turn. Leaving Typing or closing practice clears the result without writing.

### Localization

Add `typingYourAnswer`, `typingHint`, and `typingCheck` in `app_en.arb` / `app_vi.arb` / `app_de.arb`. Reuse `quizDontKnow`, `quizWrongResult`, and `quizTryLater`.

## Risks / Trade-offs

- [Blanking misses compound forms or punctuation-adjacent matches] → Spec is whole-word only; document that `memorized` stays unblanked when the term is `memorize`.
- [`_rate` still rejects Typing] → Extend the Quiz result gate to Typing the same way.
- [Shared TextEditingController leaks text across words] → Clear on advance / mode change (already done for `_typing.clear()`).
- [Widget tests hang on real tones] → Inject the same fake `quizTone` pattern as Quiz tests.

## Migration Plan

No stored level shape changes. Rollback is reverting the Typing card branch, l10n keys, and tests.

## Open Questions

None that block specs or tasks. Exact Check button styling can follow the primary theme button used elsewhere.
