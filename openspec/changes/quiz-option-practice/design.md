# Design

## Context

See proposal.md for why. Quiz is a branch of `_cardLines` in `set_study_page.dart`: it shows the definition, and `_FlashcardStage` still draws previous and next because those arrows are hidden only in Flashcard. `_rate` and `_skipNew` return immediately unless the mode is Flashcard. `levelAfter` already implements Easy, Familiar, Hard, and studied. The practice column already shows `_RatingButton` for a word at level 1 through 6, and the Not yet studied / Studied row for a new word. `MediaQuery.disableAnimationsOf` already skips the flip, the Random slide, and the Flashcard exit. There is no effect-sound package and no sound asset. The Term label already exists as `editorTerm`.

## Goals / Non-Goals

**Goals:**

- Keep Quiz inside the current practice column and reuse `levelAfter`, `saveLevel`, and the session advance.
- Play the result, then the level controls, and skip both motions when animations are disabled.
- Let widget tests observe the requested tone without an audio device.

**Non-Goals:**

- The Flashcard exit turn or slide on a Quiz rating.
- A report flag, a Continue bar, number-key answers, or bringing a missed word back.
- A new level rule in `study_progress.dart`.

## Decisions

### The question is a sibling of the flashcard stage

When the mode is Quiz, the practice column builds a Quiz card instead of `_FlashcardStage`. Typing and Random keep that stage, including their arrows. The Quiz card shows `editorTerm`, the existing speak button, the term, and the prompt. Options sit in two columns when the card is at least twice a single option wide, and in one column otherwise. Don't know sits at the trailing end of the card. There is no flag control.

The option line is the IPA, the stored type, and the definition, then the sentence after an em dash when a sentence exists. Empty parts are left out.

Alternative: keep rendering Quiz through `_cardLines`. Rejected because that path is a flat definition and the stage would still own the arrows and the flip.

### Distractors come from the open set

When the question appears, take the current word plus up to three other words from the open set. Walk forward from the current word and take the next others, so a session that contains one due word can still use the rest of the set. Fewer other words means fewer options. Shuffle only the display order. Keep that list until the word advances or the learner leaves Quiz. Identity is the word's position, so two equal terms stay distinct.

Alternative: draw distractors only from the session queue. Rejected because a one-word review would have no other choice even when the set has more words.

### The result is local, and the rating reuses Flashcard's write

The Quiz card holds one result: none, correct, wrong, or don't know. Choosing the current word's option sets correct and requests the high tone. Choosing another sets wrong and requests the low tone. Don't know sets don't know and requests nothing. A further choice or Don't know returns. The result does not call `_rate` or `_skipNew`.

After the result has settled, the column shows the same Hard, Familiar, and Easy buttons used in Flashcard, or the same Not yet studied and Studied row for a new word. Activating one calls the existing write. `_rate` and `_skipNew` accept Quiz only when a result is set, then clear it. Quiz does not set `_exit`, so the card does not turn or slide. `_advance` still opens the next term or the congratulations page, and a finished word stays out of the session.

Leaving Quiz or closing practice clears the result and does not write. The level and reminder stay as they were.

Alternative: map correct to Easy and wrong to a new minus-one action. Rejected because the learner picks the level after seeing the answer.

### The result settles, then the controls rise

The result runs for 250 ms: the border and the check or X scale from 0.6 to 1, the other options fade, and the result sentence replaces the prompt. The controls then rise 12 px and fade in over 240 ms, Hard or Not yet studied first, each later control 50 ms after the previous one. A control ignores presses until its own rise finishes. The press ring on Hard, Familiar, and Easy stays as it is.

When animations are disabled, the final result and the controls are shown together and accept presses immediately. The tone is still requested.

Green is `#12B76A`. Orange is `#F79009`. The revealed correct option uses a dashed green border. The chosen correct option uses a solid green border. The chosen wrong option uses a solid orange border. These stay Quiz-local colors in both themes.

### Two tones go through a replaceable player

Add `audioplayers` and commit `assets/sounds/quiz_correct.wav` and `assets/sounds/quiz_wrong.wav`. The correct tone is higher than the wrong tone. A small player type requests one or the other. Widget tests supply a fake that records the request, so the suite does not open a device audio session. A play failure is ignored.

Alternative: synthesize the tone in Dart. Rejected because a short asset is easier to replace and does not need an audio graph in the widget.

## Risks / Trade-offs

- [A Quiz rating sets `_exit` and the option card tries to turn] → Quiz advances inside `_rate` without assigning `_exit`.
- [`_rate` still bails unless the mode is Flashcard] → The mode guard allows Quiz only while a result is set.
- [Widget tests hang on a real player] → Tests inject the fake. Production constructs the asset player.
- [Shuffled options make a text finder ambiguous] → Tests that use a four-word set assert the set of options, not a slot.
- [Switching to Quiz after an in-flight Flashcard exit advances first] → `_selectMode` already completes that exit before changing mode. Quiz then asks the word that exit revealed.

## Migration Plan

No stored level or reminder changes shape. Rollback is reverting the Quiz branch, the two assets, and the `audioplayers` dependency.

## Open Questions

The exact waveform of the two tones can be replaced later. The contract stays a short high tone for correct and a short low tone for wrong.
