# Tasks

## 1. Copy and tones

- [x] 1.1 Add `quizChooseAnswer`, `quizDontKnow`, `quizWrongResult`, and `quizTryLater` to `app_en.arb`, `app_vi.arb`, and `app_de.arb` with the strings in `specs/app-localization/spec.md`, regenerate the localization classes, and extend `test/home_chrome_l10n_test.dart` for all three languages. Verify that test passes.
- [x] 1.2 Add `audioplayers`, commit `assets/sounds/quiz_correct.wav` and `assets/sounds/quiz_wrong.wav`, register both in `pubspec.yaml`, and add a tone player plus a fake that records the request. Verify a test where the correct request records the high tone, the wrong request records the low tone, and a failed play does not throw.

## 2. Quiz question

- [x] 2.1 When the mode is Quiz, show a Quiz card instead of `_FlashcardStage`: the existing Term label, the speak button, the term, "Choose an answer", numbered options from the open set, and Don't know. Take the current word plus up to three later words in the set, shuffle only the display, and use one column when two do not fit. Hide previous, next, and the level controls before a result. Update the existing Quiz expectation that the card shows the definition "house". Verify widget tests for a four-word set, a two-word set, an omitted empty IPA, numbers 1 and 2, Don't know, no previous or next, Easy absent, and the term "Haus" on screen.

## 3. Result

- [x] 3.1 Settle a correct choice, a wrong choice, and Don't know over 250 ms with the borders, check, X, dimmed numbered options, and result sentence from `specs/study-session/spec.md`. Request the matching tone through the injected player, and ignore another choice or Don't know. Verify widget tests for each result, for no tone on Don't know, and for a second choice leaving level 4 unchanged.

## 4. Level controls

- [x] 4.1 After the result settles, show Hard, Familiar, and Easy for a word at level 1 through 6, or Not yet studied and Studied for a new word. Rise 12 px and fade in over 240 ms, staggered by 50 ms, and ignore a control until its rise finishes. Verify that Easy is absent before the answer and present after it, that a new word hides the three ratings, and that a press during the rise leaves level 4 unchanged.
- [x] 4.2 Let `_rate` and `_skipNew` accept Quiz only while a result is set, write through the existing level actions, and advance without setting `_exit`. Clear the result on that write, on leaving Quiz, and on closing practice. Verify Easy stores level 2 and shows "Haus", Hard stores level 1, Familiar keeps level 4, Studied stores level 1, Not yet studied keeps the word new and shows "Haus", the last word shows the congratulations page, the rated word is not asked again, and closing or choosing Flashcard during the result keeps level 1.
- [x] 4.3 When animations are disabled, show the final result and the level controls together, accept a rating immediately, and still request the tone. Verify that path with `disableAnimations: true` for a correct choice on "Kind" at level 1.
