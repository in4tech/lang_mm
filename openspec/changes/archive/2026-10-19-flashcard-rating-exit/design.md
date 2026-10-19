# Design

## Context

See proposal.md for why. In practice, `_rate` writes the level, counts the session, and advances in one `setState`. `_FlashcardStage` only animates a tap or Space flip on the vertical axis, and it resets that flip when the word changes. The next word is already computed as a peek, and it is drawn behind the card only in Random. The rating buttons sit beside the stage, not inside it. `MediaQuery.disableAnimationsOf` already skips the flip and the Random slide.

## Goals / Non-Goals

**Goals:**

- Record the rating before the card moves, and advance only after the motion ends.
- Keep the face that was showing on the leaving card, with the next term face underneath.
- Reuse the stage's existing reduced-motion check.

**Non-Goals:**

- A motion for the new-word swipes, or for Hard, Familiar, and Easy on the set page outside practice.
- Changing the tap and Space flip, the level math, or the stored progress shape.

## Decisions

### Record first, advance when the card has left

While practice is open, `_rate` writes the level and the session count immediately, then asks the stage to play an exit. It does not advance and does not bump the face token until the stage reports that the motion finished. A press while an exit is already running returns before another write. Outside practice, `_rate` still advances in that same `setState`, because that page has no exit.

Closing practice clears the pending completion. The write has already happened, and the completion must not then mark the session finished. A mode change during the exit advances first, then applies the mode, so the rated word does not stay on screen.

Alternative: advance in the same `setState` and let the stage keep a snapshot of the old word. Rejected because the last word replaces the whole practice column with the congratulations page, so the card would unmount before it could leave.

### The stage plays one exit over the current face

The stage gains an exit value and a completion callback. The exit transform wraps the existing face flip, so a card already showing its meaning keeps that face. Easy and Hard add a vertical-axis turn of 75 degrees, under 90 so the other face never comes around, while the card moves by its own width to the right or the left. Familiar moves up by the card's own height and does not turn. The motion lasts 300 ms on an ease-in curve and runs once. The stack does not clip, so the card can leave its bounds. Tap and Space do not flip while the exit is running.

When another word remains, that word's term face is the first child of the stack for the duration of the exit. On the last word the stack has only the leaving card, and completion shows the congratulations page.

When animations are disabled, the stage calls completion without running the controller, matching the flip and the Random slide.

Alternative: a full 180 degree flip. Rejected because it would reveal the other face, which the rating motion must not do. Alternative: drive the exit from the rating button's own controller. Rejected because the button does not own the card.

## Risks / Trade-offs

- [A repeating controller keeps `pumpAndSettle` from returning] → The exit runs forward once, then completion advances and clears it.
- [Completion after the stage is disposed shows the summary after close] → Completion checks that the practice visit is still open.
- [Bumping the face token at the press resets the leaving face] → The token changes only when the word advances.
- [The session position stays put until the motion ends] → Accepted. The position matches the word still on screen.
