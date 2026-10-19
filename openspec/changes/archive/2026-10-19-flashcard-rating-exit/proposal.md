# Proposal

## Why

In practice, Flashcard replaces the card the moment Hard, Familiar, or Easy is pressed, so the three ratings feel the same. The card should leave toward the button that was pressed, and the next term should already be waiting underneath.

## What Changes

- While practice is open in Flashcard, Easy turns the current card on its vertical axis as it moves right. Hard does the same toward the left. Familiar slides the card straight up and does not turn it.
- The face showing when the button is pressed stays on the leaving card. The turn does not reveal the other face.
- The rating is recorded when the button is pressed. Another Hard, Familiar, or Easy press during the motion does nothing.
- The next remaining word's term face sits underneath and is revealed as the card leaves. On the last remaining word, the card leaves and then the congratulations page is shown.
- When animations are disabled, the next term or the congratulations page appears at once, as it does today.
- A tap and Space still flip the same word between its term and its meaning. A new word's two swipes, Random, Quiz, Typing, and the set page outside practice stay as they are.

Assumptions:

- The motion lasts about 300 ms. The turn is about 70 to 80 degrees.
- The motion belongs to the practice visit in Flashcard. Rating controls on the set page outside that visit do not play it.

## Capabilities

### New Capabilities

### Modified Capabilities

- `study-session`: A Flashcard rating in practice plays an exit motion before the next term face or the congratulations page.

## Impact

- `lib/features/home/widgets/set_study_page.dart` owns the practice card and records the rating before the word advances.
- `test/features/home/vocabulary_home_test.dart` covers the next term after a rating and needs to allow the motion to finish.
